extends Zombie
# rohan_boss_zombie.gd
#
# Act 1 Boss — finite state machine.
#   MOVE   : advance like a normal zombie (plays "idle"; Rohan has no Walk anim).
#   ATTACK : melee a demon directly in front; every `piercing_cooldown` seconds the
#            next strike is a "piercing_attack" instead of the looping "attack".
#   DASH   : a demon was spotted in DashZone (but not in melee range and no buff/attack
#            available) — close the gap and hit it. Only entered from MOVE.
#   BUFF   : play "buff" and call _buff_zombie() on every allied zombie in BuffZone.
#
# Damage is sourced from attackComp.attack_power so the inherited silence() (which
# halves attack_power) reduces Rohan's damage automatically. attackComp._init also
# configures DMGRayCast2D's collision mask for the current dimension, so we reuse the
# ray for melee detection. The state machine owns animation/movement/cadence directly
# because the shared ZombieSpriteComp only knows "Walk"/"Attack", which Rohan lacks.

enum State { MOVE, ATTACK, DASH, BUFF }

@export_category("Rohan Boss")
@export var piercing_cooldown: float = 9.0    # always counts down, in every state
@export var buff_cooldown: float = 20.0       # only counts down while in MOVE
@export var dash_speed: float = 110.0
@export var dash_stop_gap: float = 32.0        # stop this far in front of the dash target

var _state: State = State.MOVE
var _piercing_cd: float = 0.0
var _buff_cd: float = 0.0

# ATTACK
var _attack_elapsed: float = 0.0
var _first_attack_done: bool = false
var _piercing_active: bool = false

# DASH
var _dash_target = null
var _dash_struck: bool = false

@onready var dash_zone: Area2D = $DashZone
@onready var buff_zone: Area2D = $BuffZone
@onready var piercing_zone : Area2D = $PierceZone


func _ready() -> void:
	super()
	if Global.gameIsStarted && self.is_demo == false:
		pass
		#Global.unlock_zombie("Rohan")
	_piercing_cd = piercing_cooldown
	_buff_cd = buff_cooldown
	_setup_zone_masks()
	_play(&"idle")


# Rohan owns its per-frame behavior. The base tick() drives the shared sprite's
# Walk/Attack logic (which Rohan's SpriteFrames don't have), so we override tick()
# and reproduce only the base housekeeping we still need (per the agreed approach).
func tick(delta: float) -> void:
	if animatedSprite.isDead:
		return

	# --- base housekeeping (intentionally duplicated from BaseZombie.tick) ---
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
	healthComp.tick(delta)

	# --- state machine ---
	_piercing_cd = maxf(0.0, _piercing_cd - delta)   # always counts down
	match _state:
		State.MOVE:
			_tick_move(delta)
		State.ATTACK:
			_tick_attack(delta)
		State.DASH:
			_tick_dash(delta)
		State.BUFF:
			_tick_buff(delta)


# --- States ---

func _tick_move(delta: float) -> void:
	_buff_cd = maxf(0.0, _buff_cd - delta)   # only decrements in MOVE
	# Detection/zone queries are invalid for the first physics frames after spawn,
	# so gate them on the base spawn-setup flag.
	if _spawn_setup_done:
		if _buff_cd <= 0.0 and _has_allies_in_buff_zone():
			_enter_buff()
			return
		if _demon_in_attack_range() != null:           # priority: BUFF > ATTACK > DASH
			_enter_attack()
			return
		var dash_target = _nearest_demon_in_dash_zone()
		if dash_target != null:
			_enter_dash(dash_target)
			return
	speedComp.tick(delta)
	_play(&"idle")


func _tick_attack(delta: float) -> void:
	if _piercing_active:
		return   # let the one-shot piercing animation play out
	var target = _demon_in_attack_range()
	if target == null:
		_enter_move()
		return
	if _piercing_cd <= 0.0:
		_start_piercing(target)
		return
	_play(&"attack")
	_attack_elapsed += delta
	var safe_speed := maxf(attack_speed, 0.01)
	var interval := (attack_damage_point / safe_speed) if not _first_attack_done else (1.0 / safe_speed)
	if _attack_elapsed >= interval:
		_attack_elapsed = 0.0
		_first_attack_done = true
		_strike(target)


func _tick_dash(delta: float) -> void:
	if not is_instance_valid(_dash_target):
		_enter_move()
		return
	var target_x: float = _dash_target.global_position.x + dash_stop_gap
	global_position.x = move_toward(global_position.x, target_x, dash_speed * delta)
	if not _dash_struck and absf(global_position.x - target_x) <= 1.0:
		_strike(_dash_target)
		_dash_struck = true
		_enter_move()   # MOVE re-evaluates next tick → demon now in melee range → ATTACK


func _tick_buff(_delta: float) -> void:
	pass   # buff is applied on entry; just wait for the "buff" animation to finish


# --- Transitions ---

func _enter_move() -> void:
	_state = State.MOVE
	_dash_target = null
	_dash_struck = false
	_piercing_active = false


func _enter_attack() -> void:
	_state = State.ATTACK
	_attack_elapsed = 0.0
	_first_attack_done = false
	_piercing_active = false
	_play(&"attack")


func _enter_dash(target) -> void:
	_state = State.DASH
	_dash_target = target
	_dash_struck = false
	animatedSprite.play(&"dash_attack")   # one-shot


func _enter_buff() -> void:
	_state = State.BUFF
	_buff_cd = buff_cooldown
	_apply_buff()
	animatedSprite.play(&"buff")          # one-shot


func _start_piercing(target) -> void:
	_piercing_active = true
	_piercing_cd = piercing_cooldown
	animatedSprite.play(&"piercing_attack")   # one-shot
	#_strike(target)



# AnimatedSprite2D.animation_finished is wired to this node in the scene. Only the
# non-looping action animations reach here ("idle"/"attack" loop forever).
func _on_AnimatedSprite_animation_finished() -> void:
	match animatedSprite.animation:
		&"dash_attack":
			if _state == State.DASH:
				if not _dash_struck and is_instance_valid(_dash_target):
					_strike(_dash_target)
				_enter_move()
		&"buff":
			if _state == State.BUFF:
				_enter_move()
		&"piercing_attack":
			_piercing_active = false
			for demon in piercing_zone.get_overlapping_areas():
				if demon.is_in_group("Demons"):
					_strike(demon)
			if _state != State.ATTACK:
				_enter_move()


# --- Helpers ---

func _strike(target) -> void:
	if not is_instance_valid(target):
		return
	if target.is_in_group("Portal") or not target.has_method("take_damage"):
		return
	target.take_damage(attackComp.attack_power)
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)
	# TODO: if the boss needs them, port the retaliation interactions
	# (eat_zombie / spinalOcculumWyrm / lightning_maw) from
	# ZombieAttackRefCountedComponent._on_AttackTimer_timeout.


func _demon_in_attack_range():
	if attack_ray.is_colliding():
		var c = attack_ray.get_collider()
		if c != null and c.is_in_group("Demons") and not c.is_in_group("Portal"):
			return c
	return null


func _nearest_demon_in_dash_zone():
	var nearest = null
	var nearest_dist := INF
	for area in dash_zone.get_overlapping_areas():
		if area.is_in_group("Demons") and not area.is_in_group("Portal"):
			var d := absf(area.global_position.x - global_position.x)
			if d < nearest_dist:
				nearest_dist = d
				nearest = area
	return nearest


func _has_allies_in_buff_zone() -> bool:
	for area in buff_zone.get_overlapping_areas():
		if area != self and area.is_in_group("Zombie"):
			return true
	return false


func _apply_buff() -> void:
	for area in buff_zone.get_overlapping_areas():
		if area != self and area.is_in_group("Zombie") and area.has_method("_buff_zombie"):
			area._buff_zombie()


func _play(anim: StringName) -> void:
	if animatedSprite.animation != anim:
		animatedSprite.play(anim)


func _setup_zone_masks() -> void:
	# Masks are assigned in code per dimension (README convention): DashZone detects
	# enemy demons (Purple=2 / Green=3); BuffZone detects allied zombies (Purple=4 / Green=5).
	var demon_bit := 3 if is_in_group("Green") else 2
	var zombie_bit := 5 if is_in_group("Green") else 4
	_set_single_mask(dash_zone, demon_bit)
	_set_single_mask(buff_zone, zombie_bit)
	_set_single_mask(piercing_zone,demon_bit)


func _set_single_mask(area: Area2D, bit: int) -> void:
	for i in range(1, 6):
		area.set_collision_mask_value(i, false)
	area.set_collision_mask_value(bit, true)


# --- Inherited overrides kept from the original boss script ---

func get_zombie_name() -> String:
	return " ROHAN "


func silence() -> void:
	super()
	attackComp.silence()


#Temporary Will Replace
func get_special_description() -> String:
	return unhallower_special_description


#Temporary Will Replace
func get_zombie_icon() -> CompressedTexture2D:
	return Global.unhallower_icon
