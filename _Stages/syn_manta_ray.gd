extends AnimatedSprite2D

##Movement
@export var position_curve : Curve
@export var travel_time : float = 15.0
@export var path : Path2D
var sample_point : float = 0.0
var dir : int = 1





var epsilon := 0.001
var slope :float  
var can_move := true 
var can_rain_lightning := false 
var num_zombies_struck := 0 
var zombies_to_lightning_strike :Array= []
var currently_available_zombies : Array = []
var batches_struck := 0 

func _ready() -> void:
	pass



	

func _physics_process(delta: float) -> void:
	if sample_point > 1.0 or sample_point < 0.0:
		dir = -dir 
	if dir > 0.0:
		flip_h = true
	else:
		flip_h = false
		
	var path_direction := path.curve.get_point_position(1) - path.curve.get_point_position(0)


#
	#slope = abs(position_curve.sample(sample_point + epsilon) - position_curve.sample(sample_point - epsilon)) / (2.0 * epsilon)
	#speed_scale = slope * 0.5
	sample_point += (delta/travel_time) * dir
	position = path.curve.get_point_position(0) + path_direction * position_curve.sample(sample_point)

			
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	##
