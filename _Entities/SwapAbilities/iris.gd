extends Sprite2D

@export var position_curve : Curve
@export var travel_time : float = 4.0
@export var path : Path2D
var sample_point : float = 0.0
var dir : int = 1


func _physics_process(delta: float) -> void:
	if sample_point > 1.0 or sample_point < 0.0:
		dir = -dir 
			
	var path_direction := path.curve.get_point_position(1) - path.curve.get_point_position(0)
	
	sample_point += (delta/travel_time) * dir
	position = path.curve.get_point_position(0) + path_direction * position_curve.sample(sample_point)
