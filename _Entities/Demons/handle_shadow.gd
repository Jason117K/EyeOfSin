extends Sprite2D

@onready var shadow := self
var max_offset_shadow : float = 50 


func _process(delta: float) -> void:
	handle_shadow(delta)

func handle_shadow(delta : float)->void:
	var center : Vector2 = get_viewport_rect().size / 2.0
	var distance : float = global_position.x - center.x
	shadow.position.x = lerp(0.0,-sign(distance) * max_offset_shadow, abs(distance/(center.x)))
	
var size = Vector2(42,42)
var last_pos: Vector2
var velocity: Vector2
@export var spring: float = 150.0
@export var damp: float = 10.0
@export var velocity_multiplier: float = 2.0

var displacement: float = 0.0 
var oscillator_velocity: float = 0.0
func rotate_velocity(delta: float) -> void:

	var center_pos: Vector2 = global_position - (size/2.0)
	#print("Pos: ", center_pos)
	#print("Pos: ", last_pos)
	# Compute the velocity
	velocity = (position - last_pos) / delta
	last_pos = position
	
	#print("Velocity: ", velocity)
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
	# Oscillator stuff
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	
	rotation = displacement
