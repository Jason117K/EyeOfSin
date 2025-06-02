extends Node
#LevelSwitcher

#Switches the Level to the next level

@export var nextLevel  = preload("res://Scenes/LevelScenes/Level2.tscn")  # Load the next scene

#Moves onto next level 
func _on_Continue_pressed():
	$ButtonClickPlayer.play()
	assert(get_tree().change_scene_to_packed(nextLevel) ==OK)

#Restarts the current level
func _on_PlayAgain_pressed():
	$ButtonClickPlayer.play()
	assert(get_tree().change_scene_to_file(get_parent().get_scene_file_path()) == OK)
	
