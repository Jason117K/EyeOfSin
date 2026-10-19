extends Zombie
# act2_boss_zombie.gd
#
# Act 2 Boss — three phases, and twins from phase 2 on.
#
# PHASE 1: walk the lane; when a demon is in front, melee it with a random pick of
#   Attack_Phase1 / Attack_Phase1_Alt (each plays once and lands its hit on a set frame).
#   At 0 HP die() is intercepted: death_phase_1 plays (untouchable), then phase 2 begins
#   and a twin is spawned in the opposite dimension, already in phase 2.
# PHASE 2: same walk/attack loop with the phase-2 animations. At 0 HP a twin goes DOWN:
#   it freezes on death_phase_2's first frame and waits `twin_wait_time`.
#     - If the other twin hits 0 inside that window, both play death_phase_2 and
#       transform into phase 3 together.
#     - If the window runs out, the downed twin revives at full phase-2 health.
#   A twin without a living partner transforms straight away.
# PHASE 3: same loop; at 0 HP the real death runs and the boss is freed once
#   death_phase_3 has finished.
#
# Like Rohan, the boss owns its per-frame behaviour: tick() keeps only the base
# housekeeping and never runs the shared attack/sprite components. The sprite's
# animation_finished / frame_changed are connected here in code; the scene must NOT
# connect them to ZombieSpriteComp, whose handler calls die() on any "death*" animation.
# Attack and death animations have to be non-looping so animation_finished fires.

enum State { WALK, ATTACK, DOWN, TRANSITION, DEAD }

# --- Per-phase settings (p1_ / p2_ / p3_; read through _phase_value) ---
# Hit frames count from 0 and must be 1 or more (frame 0 is where every attack starts).
@export_group("Phase 1")
@export var p1_health: float = 1500.0
@export var p1_speed: float = 8.0
@export var p1_sprite_position: Vector2 = Vector2(-12, 4)
@export var p1_ray_position: Vector2 = Vector2(2, 0)
@export var p1_ray_target: Vector2 = Vector2(-13, 0)
@export var p1_fire_position: Vector2 = Vector2(2, -11)
@export var p1_syn_mark_position: Vector2 = Vector2(-1, -12)
@export var p1_attack_damage: float = 100.0
@export var p1_attack_hit_frame: int = 6
@export var p1_alt_attack_damage: float = 200.0
@export var p1_alt_attack_hit_frame: int = 7

@export_group("Phase 2")
@export var p2_health: float = 1000.0
@export var p2_speed: float = 10.0
@export var p2_sprite_position: Vector2 = Vector2(-12, 4)
@export var p2_ray_position: Vector2 = Vector2(2, 0)
@export var p2_ray_target: Vector2 = Vector2(-13, 0)
@export var p2_fire_position: Vector2 = Vector2(2, -11)
@export var p2_syn_mark_position: Vector2 = Vector2(-1, -12)
@export var p2_attack_damage: float = 75.0
@export var p2_attack_hit_frame: int = 6
@export var p2_alt_attack_damage: float = 150.0
@export var p2_alt_attack_hit_frame: int = 5

@export_group("Phase 3")
@export var p3_health: float = 1500.0
@export var p3_speed: float = 6.0
@export var p3_sprite_position: Vector2 = Vector2(-12, 4)
@export var p3_ray_position: Vector2 = Vector2(2, 0)
@export var p3_ray_target: Vector2 = Vector2(-13, 0)
@export var p3_fire_position: Vector2 = Vector2(2, -11)
@export var p3_syn_mark_position: Vector2 = Vector2(-1, -12)
@export var p3_attack_damage: float = 150.0
@export var p3_attack_hit_frame: int = 8
@export var p3_alt_attack_damage: float = 300.0
@export var p3_alt_attack_hit_frame: int = 9

@export_group("Twins")
## How long a downed phase-2 twin waits for its partner before reviving.
@export var twin_wait_time: float = 10.0
## Set on the copy before it enters the tree, so it starts in phase 2.
@export var starts_in_phase_two := false

var twin: Zombie = null

var _phase: int = 1
var _state: State = State.WALK
var _hurtboxes: Array[CollisionShape2D] = []
var _down_elapsed: float = 0.0
var _damage_mult: float = 1.0

# ATTACK
var _attack_is_alt := false
var _attack_hit_done := false


func _ready() -> void:
	super()
	_hurtboxes = [$HurtBoxComponent, $HurtBoxComponent_Phase2, $HurtBoxComponent_Phase3]
	animatedSprite.animation_finished.connect(_on_sprite_animation_finished)
	animatedSprite.frame_changed.connect(_on_sprite_frame_changed)
	_enter_phase(2 if starts_in_phase_two else 1)


func tick(delta: float) -> void:
	if _state == State.DEAD:
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

	match _state:
		State.WALK:
			healthComp.tick(delta)
			_tick_walk(delta)
		State.ATTACK:
			healthComp.tick(delta)
			if _demon_in_front() == null and not animatedSprite.is_playing():
				_enter_walk()
		State.DOWN:
			_down_elapsed += delta
			if _down_elapsed >= twin_wait_time:
				_revive()
		State.TRANSITION:
			pass   # the death animation owns the boss until it finishes


# ============================================================
# Phases
# ============================================================

func _phase_value(key: String) -> Variant:
	return get("p%d_%s" % [_phase, key])


func _enter_phase(phase: int) -> void:
	_phase = phase
	for i in _hurtboxes.size():
		_hurtboxes[i].set_deferred("disabled", i != phase - 1)
	hurtbox = _hurtboxes[phase - 1]

	animatedSprite.position = _phase_value("sprite_position")
	attack_ray.position = _phase_value("ray_position")
	attack_ray.target_position = _phase_value("ray_target")
	fire_fx.position = _phase_value("fire_position")
	syn_mark_sprite.position = _phase_value("syn_mark_position")

	healthComp.resetHealth(_phase_value("health"))
	speed = _phase_value("speed")
	speedComp.originalSpeed = speed
	speedComp.speed = speed
	# Shown on the info bar (get_damage); the actual hits use the per-attack damages.
	attackComp.attack_power = float(_phase_value("attack_damage")) * _damage_mult
	_enter_walk()


func _set_untouchable(untouchable: bool) -> void:
	hurtbox.set_deferred("disabled", untouchable)


# ============================================================
# Walk / attack
# ============================================================

func _tick_walk(delta: float) -> void:
	if _spawn_setup_done and _demon_in_front() != null:
		_start_attack()
		return
	speedComp.tick(delta)


func _enter_walk() -> void:
	_state = State.WALK
	animatedSprite.play("Walk_Phase%d" % _phase)


# Picks one of the phase's two attacks at random and plays it once.
func _start_attack() -> void:
	_state = State.ATTACK
	_attack_is_alt = randi() % 2 == 1
	_attack_hit_done = false
	animatedSprite.stop()   # replaying the same finished one-shot must restart at frame 0
	animatedSprite.play(_attack_animation())


func _attack_animation() -> StringName:
	return StringName(("Attack_Phase%d_Alt" if _attack_is_alt else "Attack_Phase%d") % _phase)


func _on_sprite_frame_changed() -> void:
	if _state != State.ATTACK or _attack_hit_done:
		return
	if animatedSprite.animation != _attack_animation():
		return
	var hit_frame: int = _phase_value("alt_attack_hit_frame" if _attack_is_alt else "attack_hit_frame")
	if animatedSprite.frame == hit_frame:
		_attack_hit_done = true
		var damage: float = _phase_value("alt_attack_damage" if _attack_is_alt else "attack_damage")
		_strike(_demon_in_front(), damage * _damage_mult)


func _on_sprite_animation_finished() -> void:
	match _state:
		State.ATTACK:
			if _demon_in_front() != null:
				_start_attack()
			else:
				_enter_walk()
		State.TRANSITION:
			if animatedSprite.animation == &"death_phase_1":
				_enter_phase(2)
				_spawn_twin()
			elif animatedSprite.animation == &"death_phase_2":
				_enter_phase(3)
		State.DEAD:
			if animatedSprite.animation == &"death_phase_3":
				queue_free()


func _strike(target: Node, damage: float) -> void:
	if not is_instance_valid(target):
		return
	if target.is_in_group("Portal") or not target.has_method("take_damage"):
		return
	target.take_damage(damage)
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)


func _demon_in_front() -> Node:
	if attack_ray.is_colliding():
		var collider := attack_ray.get_collider() as Node
		if collider != null and collider.is_in_group("Demons") and not collider.is_in_group("Portal"):
			return collider
	return null


# ============================================================
# Health hits zero (die() intercept)
# ============================================================

func die() -> void:
	match _phase:
		1:
			if _state != State.TRANSITION:
				_begin_transition(&"death_phase_1")
		2:
			_on_phase_two_zero()
		3:
			_final_death()


func _begin_transition(death_animation: StringName) -> void:
	_state = State.TRANSITION
	_set_untouchable(true)
	animatedSprite.play(death_animation)


func _on_phase_two_zero() -> void:
	if _state == State.DOWN or _state == State.TRANSITION:
		return
	if _twin_alive() and twin.call(&"is_down"):
		twin.call(&"begin_transform")
		begin_transform()
	elif not _twin_alive():
		begin_transform()
	else:
		_go_down()


# Frozen on the first frame of the death animation, waiting for the twin.
func _go_down() -> void:
	_state = State.DOWN
	_down_elapsed = 0.0
	_set_untouchable(true)
	animatedSprite.animation = &"death_phase_2"
	animatedSprite.stop()


func _revive() -> void:
	healthComp.resetHealth(p2_health)
	_set_untouchable(false)
	_enter_walk()


## True while this twin is down and waiting for its partner (called by the twin).
func is_down() -> bool:
	return _state == State.DOWN


## Plays the phase-2 death animation from its first frame, then enters phase 3.
func begin_transform() -> void:
	_begin_transition(&"death_phase_2")


func _twin_alive() -> bool:
	return is_instance_valid(twin) and not twin.is_dead


# Real death: the base handles deregistering, signals and the blood effect, but the
# boss is freed when death_phase_3 ends rather than when the short blood effect ends.
func _final_death() -> void:
	if _state == State.DEAD:
		return
	_state = State.DEAD
	if death_blood.animation_finished.is_connected(free_zombie):
		death_blood.animation_finished.disconnect(free_zombie)
	super.die()
	animatedSprite.play(&"death_phase_3")


# Damage can't land while the boss is down, transforming or dead.
func take_damage(is_link_damage : bool = false, damage: float = 1.0, piercing: bool = false) -> void:
	if _state == State.DOWN or _state == State.TRANSITION or _state == State.DEAD:
		return
	super(is_link_damage, damage, piercing)


# ============================================================
# Twin
# ============================================================

# Spawns a phase-2 copy at the same spot in the opposite dimension.
func _spawn_twin() -> void:
	if _twin_alive():
		return
	var dimension := Dim.other(Dim.of(self))
	var controller := Global.get_game_controller()
	var level: Node = controller.get_green_dimension() if dimension == Dim.GREEN else controller.get_purple_dimension()
	if level == null or level.get_node_or_null("GameLayer") == null:
		return
	var copy: Zombie = (load(scene_file_path) as PackedScene).instantiate()
	copy.set(&"starts_in_phase_two", true)
	copy.set(&"twin", self)
	# Group before entering the tree: _ready reads it for collision layers and ray masks.
	copy.add_to_group(dimension)
	copy.position = position
	level.get_node("GameLayer").add_child(copy, true)
	copy.set_hue_shift(125.0 if dimension == Dim.GREEN else -86.0)
	twin = copy


# ============================================================
# Overrides
# ============================================================

# Lucretia's grasp can't turn the boss.
func switch_sides() -> void:
	pass


func silence() -> void:
	if is_silenced:
		return
	super()
	_damage_mult = 0.5
	attackComp.attack_power = float(_phase_value("attack_damage")) * _damage_mult


func get_zombie_name() -> String:
	return " ACT 2 BOSS "


func get_special_description() -> String:
	return "*Three phases; splits into twins"


#Temporary Will Replace
func get_zombie_icon() -> CompressedTexture2D:
	return Global.rohan_icon
