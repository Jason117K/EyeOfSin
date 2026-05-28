extends Sprite2D

@export var position_curve : Curve
@export var travel_time : float = 4.0
@export var path : Path2D
@export var baal_eye : AnimatedSprite2D
var sample_point : float = 0.0
var dir : int = 1



func _physics_process(delta: float) -> void:
	if sample_point > 1.0 or sample_point < 0.0:
		dir = -dir 
			
	#var path_direction := path.curve.get_point_position(1) - path.curve.get_point_position(0)
	
	sample_point += (delta/travel_time) * dir
	var total_length := path.curve.get_baked_length()
	var t := position_curve.sample(clampf(sample_point,0.0,1.0))
	position = path.curve.sample_baked(t * total_length)
	
	#position = path.curve.get_point_position(0) + path_direction * position_curve.sample(sample_point)
