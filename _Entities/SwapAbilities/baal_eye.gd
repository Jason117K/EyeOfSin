extends AnimatedSprite2D

@export var position_curve : Curve
@export var travel_time : float = 5.0
@export var path : Path2D
var sample_point : float = 0.0
var dir : int = 1


func _ready() -> void:
	global_position = Vector2(367,-100)

	
func _physics_process(delta: float) -> void:
	if sample_point > 1.0 or sample_point < 0.0:
		dir = -dir 
				
	sample_point += (delta/travel_time) * dir
	var total_length := path.curve.get_baked_length()
	var t := position_curve.sample(clampf(sample_point,0.0,1.0))
	position = path.curve.sample_baked(t * total_length)
	#position = (baal_eye.position+eye_position_offset) + path.curve.sample_baked(t * total_length)
	
