extends Control
#EndScreen.gd

#SetUp The Rows in The EndScreen 
func _ready():
	pass
	#$GridManager.set_tiles_for_rows(0,1, 68)
	#$GridManager.set_tiles_for_rows(1,2, 66)
	#
	#$GridManager.set_tiles_for_rows(2,3, 63)
	#$GridManager.set_tiles_for_rows(3,4, 63)
	#$GridManager.set_tiles_for_rows(4,5, 63)
	#$GridManager.set_tiles_for_rows(5,6, 63)
	#$GridManager.set_tiles_for_rows(6,7, 63)
	#
	#$GridManager.set_tiles_for_rows(7,8, 66)
	#$GridManager.set_tiles_for_rows(8,9, 69)



#Handle quiting the game
func _on_Button_pressed():
	get_tree().quit()

#Handle reestarting th game
func _on_PlayAgain_pressed():
	Global.game_controller.change_scene("res://Scenes/LevelScenes/StartScreen.tscn")
	pass
	
	# Switch to the Main scene
	#assert(get_tree().change_scene_to_file("res://Scenes/LevelScenes/StartScreen.tscn")   ==OK)
