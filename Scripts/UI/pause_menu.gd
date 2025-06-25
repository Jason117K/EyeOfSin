extends Control




func _on_resume_pressed() -> void:
	get_tree().paused = false 

func _on_return_to_menu_pressed() -> void:
	# Ensure proper cleanup before changing scene
	get_tree().root.set_input_as_handled()
	$ButtonClickPlayer.play()
	# Add a small delay to ensure clean transition
	await get_tree().create_timer(0.1).timeout
	Global.game_controller.change_scene("res://Scenes/LevelScenes/StartScreen.tscn")


func _on_restart_pressed() -> void:
	var current_scene_filepath = Global.get_current_scene_filepath()
	print("CCUrent Scene Is ", current_scene_filepath) 
	Global.game_controller.change_scene(current_scene_filepath)
