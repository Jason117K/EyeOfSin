extends Zombie
# rohan_boss_zombie.gd
#
# Act 1 Boss — two-phase finite state machine.
#
# PHASE 1 (State enum): MOVE / ATTACK / DASH / BUFF (unchanged).
#   MOVE   : advance like a normal zombie (plays "idle").
#   ATTACK : melee a demon in front; every `piercing_cooldown` seconds a one-shot
#            "piercing_attack" AoEs every demon in PierceZone.
#   DASH   : close the gap to a demon spotted in DashZone, only from MOVE.
#   BUFF   : play "buff" and call _buff_zombie() on allied zombies in BuffZone.
#
# When phase-1 health first hits 0, die() is intercepted: the boss plays "die",
# swaps to Phase2AnimSprite ("phase_in"), swaps its ray + hurtbox to the phase-2
# nodes, refills health, and realm-swaps immediately.
#
# PHASE 2 (P2State enum): MOVE / ATTACK / REALMSWAP.
#   MOVE      : advance, play phase-2 "idle".
#   ATTACK    : melee a demon in front of Phase_2_DMGRayCast2D, play "attack".
#   REALMSWAP : play "phase_out" -> change dimension -> "phase_in". Triggered when
#               the swap cooldown expires OR after 10 consecutive attacks (a walk
#               between attacks breaks the streak). Fires immediately on entering
#               phase 2.
#
# Damage is sourced from attackComp.attack_power so the inherited silence() (which
# halves attack_power) reduces Rohan's damage automatically. The transition and
# realm-swap sequences depend on "die" (phase 1), "phase_in" and "phase_out" being
# NON-looping so their `animation_finished` fires.

enum State { MOVE, ATTACK, DASH, BUFF }
enum Phase { ONE, TRANSITION, TWO }
enum P2State { MOVE, ATTACK, REALMSWAP }

@export_category("Rohan Boss")
@export var piercing_cooldown: float = 9.0    # always counts down, in every state
@export var buff_cooldown: float = 20.0       # only counts down while in MOVE
@export var dash_speed: float = 110.0
@export var dash_stop_gap: float = 32.0        # stop this far in front of the dash target

@export_category("Rohan Boss Phase 2")
@export var realmswap_cooldown: float = 15.0
@export var realmswap_attack_threshold: int = 10

var _phase: Phase = Phase.ONE
var _starting_health: float = 0.0

var _state: State = State.MOVE
var _piercing_cd: float = 0.0
var _buff_cd: float = 0.0

# ATTACK (shared by both phases — phases never run simultaneously)
var _attack_elapsed: float = 0.0
var _first_attack_done: bool = false
var _piercing_active: bool = false

# DASH
var _dash_target = null
var _dash_struck: bool = false

# PHASE 2
var _p2_state: P2State = P2State.MOVE
var _realmswap_cd: float = 0.0
var _consecutive_attacks: int = 0

@onready var dash_zone: Area2D = $DashZone
@onready var buff_zone: Area2D = $BuffZone
@onready var piercing_zone : Area2D = $PierceZone
@onready var phase2_sprite: AnimatedSprite2D = $Phase2AnimSprite
@onready var phase2_ray := $Phase_2_DMGRayCast2D
#@onready var hurtbox := $HurtBoxComponent
@onready var phase2_hurtbox := $Phase_2_HurtBoxComponent


func _ready() -> void:
	super()
	if Global.gameIsStarted && self.is_demo == false:
		pass
		#Global.unlock_zombie("Rohan")
	_piercing_cd = piercing_cooldown
	_buff_cd = buff_cooldown
	_starting_health = healthComp.maxHealth
	_setup_zone_masks()
	_set_single_mask(phase2_ray, 3 if is_in_group("Green") else 2)
	# Phase 2 nodes start inactive (the scene also sets these — kept explicit/robust).
	phase2_sprite.visible = false
	phase2_ray.enabled = false
	phase2_hurtbox.disabled = true
	_play(&"idle")
	Global.unlock_zombie("Rohan")


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

	# --- phase dispatch ---
	match _phase:
		Phase.ONE:
			_tick_phase1(delta)
		Phase.TRANSITION:
			pass   # death/phase-in coroutine owns the boss
		Phase.TWO:
			_tick_phase2(delta)


# ============================================================
# PHASE 1
# ============================================================

func _tick_phase1(delta: float) -> void:
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


# Phase-1 AnimatedSprite2D.animation_finished is wired to this node in the scene.
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


# ============================================================
# PHASE 1 → PHASE 2 TRANSITION (death interception)
# ============================================================

func die() -> void:
	match _phase:
		Phase.ONE:
			_enter_phase2()            # intercept: this is the phase change, not death
		Phase.TRANSITION:
			pass                       # invulnerable while transitioning
		Phase.TWO:
			phase2_sprite.play(&"die")
			super()                    # real death


# Async: die anim → reveal phase-2 sprite (phase_in) → swap ray/hurtbox → realm swap.
func _enter_phase2() -> void:
	_phase = Phase.TRANSITION
	healthComp.resetHealth(_starting_health)   # refill (sync, before first await)

	animatedSprite.play(&"die")
	await animatedSprite.animation_finished

	animatedSprite.visible = false
	phase2_sprite.visible = true
	phase2_sprite.play(&"phase_in")
	await phase2_sprite.animation_finished

	attack_ray.enabled = false
	phase2_ray.enabled = true
	hurtbox.disabled = true
	phase2_hurtbox.disabled = false

	_phase = Phase.TWO
	_attack_elapsed = 0.0
	_first_attack_done = false
	_begin_realm_swap()                        # "realm swap immediately on entering phase 2"


# ============================================================
# PHASE 2
# ============================================================

func _tick_phase2(delta: float) -> void:
	_realmswap_cd = maxf(0.0, _realmswap_cd - delta)
	match _p2_state:
		P2State.MOVE:
			_p2_move(delta)
		P2State.ATTACK:
			_p2_attack(delta)
		P2State.REALMSWAP:
			pass   # phase_out/phase_in coroutine owns the boss


func _p2_move(delta: float) -> void:
	if _should_realm_swap():
		_begin_realm_swap()
		return
	if _demon_in_front(phase2_ray) != null:
		_enter_p2_attack()
		return
	speedComp.tick(delta)
	_play_on(phase2_sprite, &"idle")


func _p2_attack(delta: float) -> void:
	if _should_realm_swap():
		_begin_realm_swap()
		return
	var target = _demon_in_front(phase2_ray)
	if target == null:
		_consecutive_attacks = 0     # walking between attacks breaks the streak
		_p2_state = P2State.MOVE
		return
	_play_on(phase2_sprite, &"attack")
	_attack_elapsed += delta
	var safe_speed := maxf(attack_speed, 0.01)
	var interval := (attack_damage_point / safe_speed) if not _first_attack_done else (1.0 / safe_speed)
	if _attack_elapsed >= interval:
		_attack_elapsed = 0.0
		_first_attack_done = true
		_strike(target)
		_consecutive_attacks += 1


func _enter_p2_attack() -> void:
	_p2_state = P2State.ATTACK
	_attack_elapsed = 0.0
	_first_attack_done = false
	_play_on(phase2_sprite, &"attack")


func _should_realm_swap() -> bool:
	return _realmswap_cd <= 0.0 or _consecutive_attacks >= realmswap_attack_threshold


func _begin_realm_swap() -> void:
	_p2_state = P2State.REALMSWAP
	_realm_swap_sequence()


# Async: phase_out (current realm) → change dimension → phase_in (new realm).
func _realm_swap_sequence() -> void:
	phase2_sprite.play(&"phase_out")
	await phase2_sprite.animation_finished
	_swap_dimension()
	phase2_sprite.play(&"phase_in")
	await phase2_sprite.animation_finished
	_realmswap_cd = realmswap_cooldown
	_consecutive_attacks = 0
	_p2_state = P2State.MOVE


# Move Rohan to the opposite dimension's GameLayer and re-point every
# dimension-specific binding (body layer + ray masks + zone masks) to it.
func _swap_dimension() -> void:
	if is_in_group("Purple"):
		remove_from_group("Purple")
		add_to_group("Green")
		reparent(Global.get_game_controller().get_green_dimension().get_node("GameLayer"))
	else:
		remove_from_group("Green")
		add_to_group("Purple")
		reparent(Global.get_game_controller().get_purple_dimension().get_node("GameLayer"))
	_setup_body_layer()
	_setup_zone_masks()
	_setup_ray_masks()
	fire_fx.animation = "green_fire" if is_in_group("Green") else "purple_fire"


# ============================================================
# Helpers
# ============================================================

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
	return _demon_in_front(attack_ray)


func _demon_in_front(ray):
	if ray.is_colliding():
		var c = ray.get_collider()
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
	_play_on(animatedSprite, anim)


func _play_on(sprite, anim: StringName) -> void:
	if sprite.animation != anim:
		sprite.play(anim)


func _setup_zone_masks() -> void:
	# Masks are assigned in code per dimension (README convention): DashZone/PierceZone
	# detect enemy demons (Purple=2 / Green=3); BuffZone detects allied zombies (Purple=4 / Green=5).
	var demon_bit := 3 if is_in_group("Green") else 2
	var zombie_bit := 5 if is_in_group("Green") else 4
	_set_single_mask(dash_zone, demon_bit)
	_set_single_mask(buff_zone, zombie_bit)
	_set_single_mask(piercing_zone, demon_bit)


func _setup_ray_masks() -> void:
	var demon_bit := 3 if is_in_group("Green") else 2
	_set_single_mask(attack_ray, demon_bit)
	_set_single_mask(phase2_ray, demon_bit)


func _setup_body_layer() -> void:
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, not is_in_group("Green"))   # Purple zombie
	set_collision_layer_value(5, is_in_group("Green"))       # Green zombie


func _set_single_mask(node, bit: int) -> void:
	for i in range(1, 6):
		node.set_collision_mask_value(i, false)
	node.set_collision_mask_value(bit, true)


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
