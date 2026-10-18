extends SwapAbility

#10
#35


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
	# process_always = false: the storm pauses with the game.
	await get_tree().create_timer(lightning_delay, false).timeout
	rain_lightning()

func set_collision()->void:
	if !Global.is_on_purple_dimension():
		set_purple_collision()
	else:
		set_green_collision()


func rain_lightning()->void : 
	#print("Calling Rain Lightning")
	var batch_sizes := [max_lightning_per_rain_1, max_lightning_per_rain_2, max_lightning_per_rain_3,
						max_lightning_per_rain_4, max_lightning_per_rain_5]
	for i in batch_sizes.size():
		if i > 0:
			await get_tree().create_timer(lightning_wave_delay, false).timeout
		# Re-sample every wave: zombies struck earlier may be dead or freed, and
		# new ones may have walked in.
		currently_available_zombies = _living_targets()
		_strike_batch(currently_available_zombies, batch_sizes[i])

# Living, unflipped zombies of the storm's dimension (the area's mask), shuffled.
func _living_targets() -> Array:
	var targets: Array = lightning_spawn_area.get_overlapping_areas().filter(
		func(z: Area2D) -> bool: return is_instance_valid(z) and z is Zombie and z.is_in_group("Zombie") and not z.is_dead)
	targets.shuffle()
	return targets


func _strike_batch(zombies: Array, num_zombies_to_strike: int) -> void:
	##print("Should Lightning Strike Batch ",currently_available_zombies)
	# Only while the storm is up (an early cancel or a restart stops it).
	if is_active:
		#print("About to Lightning Strike")
		num_zombies_struck = 0
		batches_struck += 1 
		for i in range(zombies.size() - 1, -1, -1):
			var zombie = zombies[i]
			if is_instance_valid(zombie) && num_zombies_struck < num_zombies_to_strike:
				call_lighting(zombie)
				num_zombies_struck += 1
				#Could Remove From Array here if no want duplicates 
	else:
		pass
		#print("IS ON COOLDOWN NO LIGHTNINGGGGGGGGGGGGG")
	
func call_lighting(zombie : Area2D)->void:
	var syn_lightning_instance = syn_lightning.instantiate()
	syn_lightning_instance.global_position = zombie.global_position
	#print("Add Lightning Child to ", get_parent().get_active_dimension())
	
	if Global.is_on_purple_dimension():
		syn_lightning_instance.add_to_group("Purple")
	else:
		syn_lightning_instance.add_to_group("Green")
	get_parent().get_active_dimension().add_child(syn_lightning_instance)
	
	
func undo_swap_ability() -> void:
	#print("Stop Swap In Undo")
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
	# Clear green zombies too, or a storm cast into Green leaves this bit set.
	lightning_spawn_area.set_collision_mask_value(5,false)

	
	
	
	
	
	
	
