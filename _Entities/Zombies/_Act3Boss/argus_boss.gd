extends Zombie
# argus_boss.gd
#
# Act 3 Boss, Argus. Placed in one spawner through a wave table; that instance is the
# ORIGINAL and owns the whole fight. On arrival it spawns:
#   - a COPY of itself at the same spot in the other dimension (so Argus exists in both,
#     each in its own dimension's colour), sharing the original's health component, so
#     every damage path drains one pool;
#   - two Heralds (herald_zombie.gd): Green lane `green_herald_lane`, Purple lane
#     `purple_herald_lane`.
#
# Argus walks `walk_distance` px from his spawn point, then stands playing "Idle"; he
# never attacks (the copy just mirrors the original's x).
# He is immune in a dimension while that dimension's Herald is alive:
#   - a Herald goes down -> vulnerable in its dimension for `herald_down_time`, after
#     which the Herald revives where it fell and Argus turns immune again;
#   - if the other Herald goes down inside that window -> both stay down for
#     `both_down_time` and Argus is vulnerable in both dimensions.
# At 0 shared health both Argus instances fade out and the Heralds die for good.
# Mowers and other direct die() calls can't kill him while he has health left.

const GREEN_HUE := 125.0
const DEFAULT_HERALD_SCENE := "res://_Entities/Zombies/_HeraldZombie/HeraldZombie.tscn"
const PURPLE_HUE := -86.0

@export_category("Argus")
## How far (px) Argus walks from his spawn point before planting himself.
@export var walk_distance: float = 250.0
## Leave empty to use HeraldZombie.tscn (loaded at runtime, not preloaded).
@export var herald_scene: PackedScene
@export var green_herald_lane: int = 2
@export var purple_herald_lane: int = 7
## A single downed Herald stays down this long (Argus vulnerable in its dimension meanwhile).
@export var herald_down_time: float = 8.0
## Both Heralds down at once: both stay down this long (Argus vulnerable in both dimensions).
@export var both_down_time: float = 15.0

## Set on the copy before it enters the tree.
var is_copy := false
var original: Zombie = null   # on the copy
var copy: Zombie = null       # on the original

var _heralds := {}            # dimension -> Herald (original only)
var _down_left := {}          # dimension -> seconds left while that Herald is down
var _both_down := false
var _both_left := 0.0
var _spawn_x := 0.0
var _dying := false


func _ready() -> void:
	super()
	_spawn_x = position.x
	animatedSprite.play(&"Idle")
	if not is_copy:
		# Deferred: the spawner is still mid add_child.
		_start_fight.call_deferred()


func tick(delta: float) -> void:
	if _dying:
		return

	# --- base housekeeping (intentionally duplicated from BaseZombie.tick, as in Rohan) ---
	if not _spawn_setup_done:
		time_since_spawn += delta
		if time_since_spawn > 0.1:
			_on_JustNowSpawned_timeout()
			_spawn_setup_done = true
	if hit_flash_active:
		time_since_hit += delta
		if time_since_hit >= hit_flash_duration:
			hit_flash_active = false
			time_since_hit = 0
			_on_ResetThisColor_timeout()
	if is_debuffed:
		time_since_debuff_applied += delta
		if time_since_debuff_applied >= debuff_duration:
			time_since_debuff_applied = 0
			_on_DebuffDegrade_timeout()

	if is_copy:
		if is_instance_valid(original):
			position.x = original.position.x
		return

	healthComp.tick(delta)   # shared pool: only the original ticks it
	if _spawn_x - position.x < walk_distance:
		speedComp.tick(delta)
		position.x = maxf(position.x, _spawn_x - walk_distance)
	_tick_heralds(delta)


# ============================================================
# Setting up the fight (original only)
# ============================================================

func _start_fight() -> void:
	_spawn_copy()
	_spawn_herald(Dim.GREEN, green_herald_lane)
	_spawn_herald(Dim.PURPLE, purple_herald_lane)


func _spawn_copy() -> void:
	var dimension := Dim.other(Dim.of(self))
	var layer := _game_layer(dimension)
	if layer == null:
		return
	var twin: Zombie = (load(scene_file_path) as PackedScene).instantiate()
	twin.set(&"is_copy", true)
	twin.set(&"original", self)
	# Group before entering the tree: _ready reads it for collision layers.
	twin.add_to_group(dimension)
	twin.position = position
	layer.add_child(twin, true)
	twin.healthComp = healthComp   # one shared health pool
	twin.set_hue_shift(_hue(dimension))
	copy = twin


func _spawn_herald(dimension: StringName, lane: int) -> void:
	var layer := _game_layer(dimension)
	if layer == null:
		return
	var spawner := layer.get_node_or_null("ZombieSpawner%d" % lane) as Node2D
	if spawner == null:
		push_warning("Argus: no ZombieSpawner%d in the %s dimension; Herald not spawned" % [lane, dimension])
		return
	var scene: PackedScene = herald_scene if herald_scene != null else load(DEFAULT_HERALD_SCENE)
	var herald: Zombie = scene.instantiate()
	herald.set(&"argus", self)
	herald.add_to_group(dimension)
	herald.position = spawner.position + Vector2(25, 0)   # same spot ZombieSpawner uses
	layer.add_child(herald, true)
	herald.set_hue_shift(_hue(dimension))
	_heralds[dimension] = herald


func _game_layer(dimension: StringName) -> Node:
	var controller := Global.get_game_controller()
	var level: Node = controller.get_green_dimension() if dimension == Dim.GREEN else controller.get_purple_dimension()
	return level.get_node_or_null("GameLayer") if level != null else null


func _hue(dimension: StringName) -> float:
	return GREEN_HUE if dimension == Dim.GREEN else PURPLE_HUE


# ============================================================
# Heralds (original only)
# ============================================================

## Called by a Herald when it goes down.
func on_herald_down(herald: Node) -> void:
	if _dying:
		return
	var dimension := Dim.of(herald)
	if _down_left.has(Dim.other(dimension)):
		# The other Herald is still down: both stay down for the longer window.
		_down_left.clear()
		_both_down = true
		_both_left = both_down_time
	else:
		_down_left[dimension] = herald_down_time


func _tick_heralds(delta: float) -> void:
	if _both_down:
		_both_left -= delta
		if _both_left <= 0.0:
			_both_down = false
			_revive_herald(Dim.GREEN)
			_revive_herald(Dim.PURPLE)
		return
	for dimension: StringName in _down_left.keys():
		_down_left[dimension] -= delta
		if _down_left[dimension] <= 0.0:
			_down_left.erase(dimension)
			_revive_herald(dimension)


func _revive_herald(dimension: StringName) -> void:
	var herald: Variant = _heralds.get(dimension)   # may be freed: no typed Node here
	if is_instance_valid(herald):
		herald.call(&"revive")


## True while Argus can be damaged in `dimension` (its Herald is down).
func is_vulnerable_in(dimension: StringName) -> bool:
	return _both_down or _down_left.has(dimension)


func _vulnerable_here() -> bool:
	if not is_copy:
		return is_vulnerable_in(Dim.of(self))
	return is_instance_valid(original) and original.call(&"is_vulnerable_in", Dim.of(self))


# ============================================================
# Damage and death
# ============================================================

# Hits (and bleeds) only land in a dimension whose Herald is down.
func take_damage(is_link_damage : bool = false, damage: float = 1.0, piercing: bool = false) -> void:
	if _dying or not _vulnerable_here():
		return
	super(is_link_damage, damage, piercing)


func bleed(bleed_damage: float) -> void:
	if _dying or not _vulnerable_here():
		return
	super(bleed_damage)


# Only the original dies on its own, and only once the shared health is gone
# (a mower's direct die() does nothing). It takes the copy and the Heralds with it.
func die() -> void:
	if is_copy or _dying or healthComp.health > 0:
		return
	if is_instance_valid(copy):
		copy.call(&"die_with_original")
	for herald: Variant in _heralds.values():
		if is_instance_valid(herald):
			herald.call(&"final_death")
	_die_and_fade()


## Called on the copy by the original when Argus is defeated.
func die_with_original() -> void:
	_die_and_fade()


func _die_and_fade() -> void:
	if _dying:
		return
	_dying = true
	if death_blood.animation_finished.is_connected(free_zombie):
		death_blood.animation_finished.disconnect(free_zombie)
	super.die()   # deregister, death signals, blood
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)


# ============================================================
# Overrides
# ============================================================

# Lucretia's grasp can't turn Argus.
func switch_sides() -> void:
	pass


func get_zombie_name() -> String:
	return " ARGUS "


func get_special_description() -> String:
	return "*Immune while his Heralds live"


#Temporary Will Replace
func get_zombie_icon() -> CompressedTexture2D:
	return Global.rohan_icon
