extends AnimatedSprite2D

@export var position_curve : Curve
@export var travel_time : float = 5.0
@export var path : Path2D
var sample_point : float = 0.0
var dir : int = 1
var initial_pass_done := false
var loop_start : float


func _ready() -> void:
	global_position = Vector2(367,-100)
	var total_length := path.curve.get_baked_length()
	var length_to_point2 := path.curve.get_closest_offset(path.curve.get_point_position(1))
	loop_start = length_to_point2 / total_length


func _physics_process(delta: float) -> void:
	var lower_bound := 0.0 if not initial_pass_done else loop_start

	if sample_point > 1.0 or sample_point < lower_bound:
		dir = -dir
		if not initial_pass_done and sample_point >= 1.0:
			initial_pass_done = true

	sample_point += (delta/travel_time) * dir
	var total_length := path.curve.get_baked_length()
	var t := position_curve.sample(clampf(sample_point, lower_bound, 1.0))
	position = path.curve.sample_baked(t * total_length)
	
