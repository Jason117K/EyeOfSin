class_name TestTentacle extends Node2D
## Standalone tentacle — no Maw, no state machine.
## Just wriggles toward its ArmTarget using IK + wave motion.
## Place the ArmTarget wherever you want the tentacle to reach.

@export_group("References")
## The arm that does the IK solving and rendering.
@export var arm: TestArm
## The target the arm chases. Position this to control the tentacle.
@export var arm_target: TestArmTarget

@export_group("Idle Behavior")
## Local-space offset from this node where the arm target rests.
@export var idle_offset: Vector2 = Vector2(64, 0)
## If true, the arm target slowly drifts around idle_offset for organic feel.
@export var enable_wander: bool = false
## How far the target wanders from idle_offset.
@export_range(0.0, 50.0, 1.0) var wander_radius: float = 15.0
## How fast the target wanders.
@export_range(0.0, 5.0, 0.1) var wander_speed: float = 0.8

var _wander_time: float = 0.0


func _ready() -> void:
	if arm_target:
		arm_target.global_position = global_position + idle_offset
	# Randomize wander phase so tentacles don't move in sync
	_wander_time = randf() * TAU


func _process(delta: float) -> void:
	if not arm_target:
		return

	if enable_wander:
		_wander_time += delta * wander_speed
		var wander_offset := Vector2(
			sin(_wander_time) * wander_radius,
			cos(_wander_time * 0.7) * wander_radius * 0.6
		)
		arm_target.global_position = global_position + idle_offset + wander_offset
