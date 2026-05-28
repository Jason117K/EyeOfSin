extends AnimatedSprite2D

##Movement
@export var position_curve : Curve
@export var travel_time : float = 15.0
@export var path : Path2D
var sample_point : float = 0.0
var dir : int = 1

@export var max_lightning_per_rain := 4
@export var max_lightning_per_rain_1 := 1
@export var max_lightning_per_rain_2 := 2
@export var max_lightning_per_rain_3 := 3
@export var lightning_wave_delay := 0.4

@onready var sacrifice_area := $"../SacrificeDetectionArea"
@onready var lightning_spawn_area := $"../LightningArea"
@onready var syn_lightning := preload("res://_Stages/Level6/syn_lightning.tscn")
@onready var lightning_timer := $LightningTimer

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
	#sacrifice_area.lightning_storm.connect(start_lighting_timer)
	#self.animation_finished.connect(finish_rain_lightning)
	#if self.is_in_group("Green"):
		#lightning_spawn_area.set_collision_mask_value(1,false)
		#lightning_spawn_area.set_collision_mask_value(2,false)
		#lightning_spawn_area.set_collision_mask_value(3,true)
		#lightning_spawn_area.set_collision_mask_value(4,false)
		#lightning_spawn_area.set_collision_mask_value(5,true)
#
		#sacrifice_area.set_collision_mask_value(1,false)
		#sacrifice_area.set_collision_mask_value(2,false)
		#sacrifice_area.set_collision_mask_value(3,true)
		#sacrifice_area.set_collision_mask_value(4,false)
		#sacrifice_area.set_collision_mask_value(5,true)
		#
	#else:
		#lightning_spawn_area.set_collision_mask_value(1,false)
		#lightning_spawn_area.set_collision_mask_value(2,true)
		#lightning_spawn_area.set_collision_mask_value(3,false)
		#lightning_spawn_area.set_collision_mask_value(4,true)
		#
		#sacrifice_area.set_collision_mask_value(1,false)
		#sacrifice_area.set_collision_mask_value(2,true)
		#sacrifice_area.set_collision_mask_value(3,false)
		#sacrifice_area.set_collision_mask_value(4,true)
				
		
		
func rain_lightning()->void:
	can_move = false 
	play("attack_purple")


func finish_rain_lightning()->void : 
	if animation == "attack_purple" :
		zombies_to_lightning_strike = lightning_spawn_area.get_overlapping_areas()
		zombies_to_lightning_strike.shuffle()
		currently_available_zombies = zombies_to_lightning_strike.filter(func(z): return z.is_in_group("Zombie"))

		_strike_batch(currently_available_zombies, max_lightning_per_rain_1)
		await get_tree().create_timer(lightning_wave_delay).timeout
		currently_available_zombies.shuffle()
		_strike_batch(currently_available_zombies, max_lightning_per_rain_2)
		await get_tree().create_timer(lightning_wave_delay).timeout
		currently_available_zombies.shuffle()
		_strike_batch(currently_available_zombies, max_lightning_per_rain_3)


func _strike_batch(zombies: Array, num_zombies_to_strike: int) -> void:
	num_zombies_struck = 0
	batches_struck += 1 
	for i in range(zombies.size() - 1, -1, -1):
		var zombie = zombies[i]
		if zombie != null && num_zombies_struck < num_zombies_to_strike:
			call_lighting(zombie)
			num_zombies_struck += 1
			#Could Remove From Array here if no want duplicates 
	if batches_struck >= 2:
		play("idle_red_purple")
		can_move = true 
	
func call_lighting(zombie : Area2D)->void:
	var syn_lightning_instance = syn_lightning.instantiate()
	syn_lightning_instance.global_position = zombie.global_position
	get_parent().add_child(syn_lightning_instance)
	

func _physics_process(delta: float) -> void:
	if sample_point > 1.0 or sample_point < 0.0:
		dir = -dir 
	if dir > 0.0:
		flip_h = false
	else:
		flip_h = true
		
	var path_direction = path.curve.get_point_position(1) - path.curve.get_point_position(0)


	if can_move:
		slope = abs(position_curve.sample(sample_point + epsilon) - position_curve.sample(sample_point - epsilon)) / (2.0 * epsilon)
		speed_scale = slope * 0.5
		sample_point += (delta/travel_time) * dir
		position = path.curve.get_point_position(0) + path_direction * position_curve.sample(sample_point)
		
	if can_rain_lightning:
		if sample_point >= 0.3 && sample_point <= 0.8:
			rain_lightning()
			can_rain_lightning = false
			
	
	
	


func _on_lightning_timer_timeout() -> void:
	can_rain_lightning = true 



func start_lighting_timer()->void:
	lightning_timer.start()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	##
