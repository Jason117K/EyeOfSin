extends Node2D
#EndScreen.gd

#SetUp The Rows in The EndScreen 
func _ready():
	$GridManager.set_tiles_for_rows(0,8, 5)



#Handle quiting the game
func _on_Button_pressed():
	get_tree().quit()

#Handle reestarting th game
func _on_PlayAgain_pressed():
	var new_scene = preload("res://Scenes/LevelScenes/StartScreen.tscn")  # Load the Main scene
	# Switch to the Main scene
	assert(get_tree().change_scene_to_packed(new_scene)   ==OK)
