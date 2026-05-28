extends Sprite2D

@export var position_curve : Curve
@export var travel_time : float = 6.0
@export var path : Path2D
@export var baal_eye : AnimatedSprite2D

@export var center := Vector2(370, 88)
@export var radius := 25.0
@export var k := radius * 0.5523

var eye_position_offset := Vector2(0,45)
var absolute_center := Vector2(0, 0)
var sample_point : float = 0.0
var dir : int = 1
var curve : Curve2D

func _ready() -> void:
	curve = path.curve
	curve.clear_points()
	curve.add_point(absolute_center + Vector2(-radius, 0), Vector2.ZERO, Vector2(0, k))
	curve.add_point(absolute_center + Vector2(0, radius), Vector2(-k, 0), Vector2(k, 0))
	curve.add_point(absolute_center + Vector2(radius, 0), Vector2(0, k), Vector2.ZERO)
	
func _physics_process(delta: float) -> void:
	if sample_point > 1.0 or sample_point < 0.0:
		dir = -dir 
			
	#var path_direction := path.curve.get_point_position(1) - path.curve.get_point_position(0)
	
	sample_point += (delta/travel_time) * dir
	var total_length := path.curve.get_baked_length()
	var t := position_curve.sample(clampf(sample_point,0.0,1.0))
	#position = path.curve.sample_baked(t * total_length)
	position = (baal_eye.position+eye_position_offset) + path.curve.sample_baked(t * total_length)
	
	#position = path.curve.get_point_position(0) + path_direction * position_curve.sample(sample_point)
