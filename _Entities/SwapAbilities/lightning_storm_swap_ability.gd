extends SwapAbility



@export var max_lightning_per_rain := 4
@export var max_lightning_per_rain_1 := 1
@export var max_lightning_per_rain_2 := 1
@export var max_lightning_per_rain_3 := 2
@export var max_lightning_per_rain_4 := 3
@export var max_lightning_per_rain_5 := 5
#@export var max_lightning_per_rain_6 := 6

@export var lightning_wave_delay := 0.9
@export var lightning_delay := 0.7


@onready var lightning_spawn_area := $LightningSpawnArea
@onready var syn_lightning := preload("res://_Stages/Level6/syn_lightning.tscn")

var can_strike := true 
var num_zombies_struck := 0 
var zombies_to_lightning_strike :Array= []
var currently_available_zombies : Array = []
var batches_struck := 0 
	
#func _ready() -> void:
	#ability_duration = lightning_wave_delay * 6 
			
func get_icon()->Texture:
	return Global.lightning_storm_icon
	
func apply_swap_ability()->void:
	set_collision()
	ability_duration = lightning_wave_delay * 6 
	await get_tree().create_timer(lightning_delay).timeout
	rain_lightning()

func set_collision()->void:
	if !Global.is_on_purple_dimension():
		set_purple_collision()
	else:
		set_green_collision()


func rain_lightning()->void : 
	print("Calling Rain Lightning")
	zombies_to_lightning_strike = lightning_spawn_area.get_overlapping_areas()
	zombies_to_lightning_strike.shuffle()
	currently_available_zombies = zombies_to_lightning_strike.filter(func(z:Area2D): return z.is_in_group("Zombie"))

	_strike_batch(currently_available_zombies, max_lightning_per_rain_1)
	await get_tree().create_timer(lightning_wave_delay).timeout
	currently_available_zombies.shuffle()
	
	_strike_batch(currently_available_zombies, max_lightning_per_rain_2)
	await get_tree().create_timer(lightning_wave_delay).timeout
	currently_available_zombies.shuffle()
	
	_strike_batch(currently_available_zombies, max_lightning_per_rain_3)
	await get_tree().create_timer(lightning_wave_delay).timeout
	currently_available_zombies.shuffle()

	_strike_batch(currently_available_zombies, max_lightning_per_rain_4)
	await get_tree().create_timer(lightning_wave_delay).timeout
	currently_available_zombies.shuffle()

	_strike_batch(currently_available_zombies, max_lightning_per_rain_5)
	await get_tree().create_timer(lightning_wave_delay).timeout
	currently_available_zombies.shuffle()

	#_strike_batch(currently_available_zombies, max_lightning_per_rain_6)
	#await get_tree().create_timer(lightning_wave_delay).timeout
	#currently_available_zombies.shuffle()


func _strike_batch(zombies: Array, num_zombies_to_strike: int) -> void:
	#print("Should Lightning Strike Batch ",currently_available_zombies)
	if !is_on_cooldown:
		print("About to Lightning Strike")
		num_zombies_struck = 0
		batches_struck += 1 
		for i in range(zombies.size() - 1, -1, -1):
			var zombie = zombies[i]
			if zombie != null && num_zombies_struck < num_zombies_to_strike:
				call_lighting(zombie)
				num_zombies_struck += 1
				#Could Remove From Array here if no want duplicates 
	else:
		print("IS ON COOLDOWN NO LIGHTNINGGGGGGGGGGGGG")
	
func call_lighting(zombie : Area2D)->void:
	var syn_lightning_instance = syn_lightning.instantiate()
	syn_lightning_instance.global_position = zombie.global_position
	print("Add Lightning Child to ", get_parent().get_active_dimension())
	
	if Global.is_on_purple_dimension():
		syn_lightning_instance.add_to_group("Purple")
	else:
		syn_lightning_instance.add_to_group("Green")
	get_parent().get_active_dimension().add_child(syn_lightning_instance)
	
	
func undo_swap_ability() -> void:
	print("Stop Swap In Undo")
	stop()

	


func set_green_collision()->void:
	lightning_spawn_area.set_collision_mask_value(1,false)
	lightning_spawn_area.set_collision_mask_value(2,false)
	lightning_spawn_area.set_collision_mask_value(3,false)
	lightning_spawn_area.set_collision_mask_value(4,false)
	lightning_spawn_area.set_collision_mask_value(5,true)
		
		
func set_purple_collision()->void:
	lightning_spawn_area.set_collision_mask_value(1,false)
	lightning_spawn_area.set_collision_mask_value(2,false)
	lightning_spawn_area.set_collision_mask_value(3,false)
	lightning_spawn_area.set_collision_mask_value(4,true)

	
	
	
	
	
	
	
