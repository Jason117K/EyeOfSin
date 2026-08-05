extends AnimatedSprite2D

@export var position_curve : Curve
@export var travel_time : float = 3.0
@export var path : Path2D
var sample_point : float = 0.0
var dir : int = 1
var initial_pass_done := false
var loop_start : float
var loop_end : float
var can_move := false 
var reached_top := false
var num_times_hit_end := 0 

func _ready() -> void:
	path.curve.add_point( Vector2(370,32), Vector2.ZERO , Vector2.ZERO,2)
	var total_length := path.curve.get_baked_length()
	loop_end = path.curve.get_closest_offset(path.curve.get_point_position(2))  / total_length
	path.curve.remove_point(2)
	
	total_length = path.curve.get_baked_length()
	var length_to_point2 := path.curve.get_closest_offset(path.curve.get_point_position(1))
	loop_start = length_to_point2 / total_length
	
	 
	
	loop_start = path.curve.get_closest_offset( path.curve.get_point_position(1)) / path.curve.get_baked_length()
	#print("LOOOOP ", loop_start)
	#descend()

func descend()->void:
	can_move = true 

func stop_descend()->void:
	can_move = false 
	initial_pass_done = false 

func _physics_process(delta: float) -> void:
	if can_move:
		var lower_bound : float
		var upper_bound : float
		if initial_pass_done:
			lower_bound = loop_start
			upper_bound = loop_end
		elif reached_top:
			lower_bound = loop_start
			upper_bound = 1.0
		else:
			lower_bound = 0.0
			upper_bound = 1.0
			
			
# Added:
		if sample_point > upper_bound or sample_point < lower_bound:
			dir = -dir
			num_times_hit_end += 1 
			if not initial_pass_done:
				if sample_point >= 1.0:
					reached_top = true
					
				elif reached_top:
					initial_pass_done = true
			sample_point = clampf(sample_point, lower_bound, upper_bound)
			if num_times_hit_end > 1:
				travel_time = 20
			
		sample_point += (delta/travel_time) * dir
		var total_length := path.curve.get_baked_length()
		var t := position_curve.sample(clampf(sample_point, lower_bound,upper_bound))
		position = path.curve.sample_baked(t * total_length)
	else:
		initial_pass_done = false 
	
