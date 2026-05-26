class_name Tentacle extends Node2D
## Procedural tentacle controller. Wraps an Arm (IK visual) and an
## ArmTarget (Node2D the IK chases). Owns its own
## attack -> grab -> retract -> wait -> digest state machine; the parent
## demon coordinates via signals and (for multi-tentacle eats) by calling
## begin_digestion() once every participating tentacle has retracted.

# === Tunables ===
const GRAB_DISTANCE_THRESHOLD := 10.0
const ATTACH_DURATION := 0.1
const MAX_EXTEND_TIME := 3.0           # Stuck-tentacle timeout
const EXTEND_TIME_CONSTANT := 0.75     # Exponential homing rate while EXTENDING
const RETRACT_DURATION := 0.5          # Tween duration while RETRACTING
const ABORT_RETURN_DURATION := 0.4     # Tween duration when easing back to idle

# === States ===
# WAITING_FOR_DIGESTION: retraction tween has completed; arm hidden;
# awaiting external begin_digestion() so multi-tentacle groups can sync.
enum State { IDLE, EXTENDING, ATTACHED, RETRACTING, WAITING_FOR_DIGESTION, DIGESTING }

# === Signals ===
signal grabbed_enemy(enemy: Node2D)         # Arm tip reached enemy
signal retraction_finished(enemy: Node2D)   # Enemy pulled to retract center
signal ready_again                          # Digestion complete, available again
signal aborted                              # Attack abandoned, returning to idle

# === Exports ===
@export var idle_offset: Vector2 = Vector2.ZERO  # Local-space resting pos for arm tip
@export var digestion_time: float = 4.5
@export var debug_mode: bool = false

# === Node references ===
@onready var arm: Arm = $Arm
@onready var arm_target: ArmTarget = $ArmTarget

# === Runtime state ===
var state: State = State.IDLE
var enemy: Node2D = null
var retraction_center_provider: Callable  # Optional: called for retract destination

# When false, this tentacle is a "secondary" in a multi-tentacle eat —
# it animates alongside the primary but does NOT pin the enemy each frame.
# Reset to true on every attack() call.
var is_primary_grabber: bool = true

var _timer: float = 0.0
var _extend_timer: float = 0.0
var _movement_tween: Tween = null


func _ready() -> void:
	arm_target.global_position = global_position + idle_offset
	



func is_available() -> bool:
	return state == State.IDLE


# Public — kick off an attack on a target enemy.
# `is_primary` controls whether this tentacle pins the enemy. When two
# or more tentacles share an enemy (cost > 1), only one is primary.
func attack(target_enemy: Node2D, is_primary: bool = true) -> void:
	_kill_tween()
	state = State.EXTENDING
	enemy = target_enemy
	is_primary_grabber = is_primary
	_timer = 0.0
	_extend_timer = 0.0
	arm_target.global_position = target_enemy.global_position


# Public — cancel the current attack and ease back to idle.
func abort() -> void:
	state = State.IDLE
	enemy = null
	is_primary_grabber = true
	_timer = 0.0
	_extend_timer = 0.0
	_kill_tween()
	# Restore arm visibility in case we aborted from WAITING_FOR_DIGESTION
	# or DIGESTING, where the arm was hidden.
	_set_arm_visible(true)

	var idle_pos := global_position + idle_offset
	_movement_tween = create_tween()
	_movement_tween.tween_property(arm_target, "global_position", idle_pos, ABORT_RETURN_DURATION)
	aborted.emit()


# Public — start the digestion timer. The Maw calls this once all
# participating tentacles in an eating group have completed RETRACTING,
# so digestion starts and ends in sync across the group.
func begin_digestion() -> void:
	state = State.DIGESTING
	enemy = null
	_timer = 0.0


func _process(delta: float) -> void:
	if state == State.IDLE or state == State.WAITING_FOR_DIGESTION:
		return

	# Only the pre-commit phases bail on enemy loss. Once RETRACTING is
	# under way the primary has (or is about to) apply damage, so a
	# now-invalid enemy is expected — let the retraction run to completion.
	if state in [State.EXTENDING, State.ATTACHED] and not is_instance_valid(enemy):
		if debug_mode:
			print("[Tentacle %s] Enemy became invalid, aborting" % name)
		abort()
		return

	match state:
		State.EXTENDING:
			_tick_extending(delta)
		State.ATTACHED:
			_tick_attached(delta)
		State.RETRACTING:
			_tick_retracting(delta)
		State.DIGESTING:
			_tick_digesting(delta)


func _tick_extending(delta: float) -> void:
	# Framerate-independent exponential approach
	var t := 1.0 - exp(-delta / EXTEND_TIME_CONSTANT)
	arm_target.global_position = arm_target.global_position.lerp(enemy.global_position, t)

	_extend_timer += delta
	if _extend_timer > MAX_EXTEND_TIME:
		if debug_mode:
			print("[Tentacle %s] Extension timeout" % name)
		abort()
		return

	var arm_tip := arm.to_global(arm.get_segments()[-1])
	if arm_tip.distance_to(enemy.global_position) < GRAB_DISTANCE_THRESHOLD:
		state = State.ATTACHED
		_timer = 0.0
		grabbed_enemy.emit(enemy)


func _tick_attached(delta: float) -> void:
	# Only primary pins the enemy — secondaries trail along visually.
	if is_primary_grabber and is_instance_valid(enemy):
		var arm_tip := arm.to_global(arm.get_segments()[-1])
		enemy.global_position = arm_tip

	_timer += delta
	if _timer >= ATTACH_DURATION:
		_start_retraction()


func _tick_retracting(_delta: float) -> void:
	# Tween drives the target; per-frame work is just pinning the enemy
	# (primary only; secondary's enemy may already be invalid after the
	# primary's damage step fires, which is fine).
	if is_primary_grabber and is_instance_valid(enemy):
		var arm_tip := arm.to_global(arm.get_segments()[-1])
		enemy.global_position = arm_tip


func _start_retraction() -> void:
	state = State.RETRACTING
	_kill_tween()

	var retract_target: Vector2
	if retraction_center_provider.is_valid():
		retract_target = retraction_center_provider.call()
	else:
		retract_target = global_position

	_movement_tween = create_tween()
	_movement_tween.tween_property(arm_target, "global_position", retract_target, RETRACT_DURATION)
	_movement_tween.tween_callback(_on_retraction_complete)


# Retraction tween finished. Park in WAITING_FOR_DIGESTION with the arm
# hidden until the Maw calls begin_digestion() (after all group members
# have likewise retracted).
func _on_retraction_complete() -> void:
	var captured := enemy
	_movement_tween = null
	state = State.WAITING_FOR_DIGESTION
	_set_arm_visible(false)
	retraction_finished.emit(captured)


func _tick_digesting(delta: float) -> void:
	_timer += delta
	if _timer >= digestion_time:
		_complete_digestion()
	else:
		pass
		#print("timer is ", _timer)


func _complete_digestion() -> void:
	print("Digestion Complete")
	state = State.IDLE
	enemy = null
	is_primary_grabber = true
	_set_arm_visible(true)
	arm_target.global_position = global_position + idle_offset
	ready_again.emit()


func _set_arm_visible(v: bool) -> void:
	if arm.base_node:
		arm.base_node.visible = v
	if arm.shadow_node:
		arm.shadow_node.visible = v


func _kill_tween() -> void:
	if _movement_tween and _movement_tween.is_valid():
		_movement_tween.kill()
	_movement_tween = null
