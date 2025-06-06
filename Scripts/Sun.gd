extends Area2D
#Sun.gd

#Adjustable sun value 
@export var SunValue = 50


func _ready() -> void:
	input_pickable = true
	print("SSCollision Layer: ", collision_layer)
	print("SSCollision Mask: ", collision_mask)
	print("SSInput Pickable: ", input_pickable)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
#Handle sun collection 
func _on_Sun_mouse_entered():
	print("SS Mouse Entered")
	$CollectAudioPlayer.play()

	var plant_manager = get_parent().get_parent().get_node("PlantManager")
	if plant_manager:  # If the PlantManager or GameManager is set
		#$CollectAudioPlayer.play()
		plant_manager.add_sun(SunValue)  # Add 25 sun points (or whatever amount)
		plant_manager.play_sun_collect()
	# Queue the sun for deletion (simulate absorption)
	queue_free()


func _on_auto_pick_up_timer_timeout() -> void:
	$CollectAudioPlayer.play()
	print("SSun Auto Pickup")
	SunValue = SunValue / 2
	#var root = get_tree().current_scene
	#print("SS root is ", root )
	var plant_manager = get_parent().get_parent().get_node("PlantManager")
	print("PlantManager SS : ", plant_manager)
	if plant_manager:  # If the PlantManager or GameManager is set
		#$CollectAudioPlayer.play()
		plant_manager.add_sun(SunValue)  # Add 25 sun points (or whatever amount)
		plant_manager.play_sun_collect()
	# Queue the sun for deletion (simulate absorption)
	queue_free()

func setWorth(bloodWorth):
	SunValue = bloodWorth
	
	
	
	
	
	
	
	
	
