extends Area2D
#Sun.gd

#Adjustable sun value 
export var SunValue = 50

	
#Handle sun collection 
func _on_Sun_mouse_entered():
	$CollectAudioPlayer.play()
	var root = get_tree().current_scene
	var plant_manager = root.get_node("PlantManager")
	if plant_manager:  # If the PlantManager or GameManager is set
		#$CollectAudioPlayer.play()
		plant_manager.add_sun(SunValue)  # Add 25 sun points (or whatever amount)
		plant_manager.play_sun_collect()
	# Queue the sun for deletion (simulate absorption)
	queue_free()




