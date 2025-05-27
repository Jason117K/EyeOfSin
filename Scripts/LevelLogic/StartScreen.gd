extends Control
#StartScreen.gd

#Sets up the startscreen tiles
func _ready():
	$GridManager.set_tiles_for_rows(0,1, 68)
	$GridManager.set_tiles_for_rows(1,2, 66)
	
	$GridManager.set_tiles_for_rows(2,3, 63)
	$GridManager.set_tiles_for_rows(3,4, 63)
	$GridManager.set_tiles_for_rows(4,5, 63)
	$GridManager.set_tiles_for_rows(5,6, 63)
	$GridManager.set_tiles_for_rows(6,7, 63)
	
	$GridManager.set_tiles_for_rows(7,8, 66)
	$GridManager.set_tiles_for_rows(8,9, 69)
	
	$CenterContainer/VBoxContainer/Button.get_theme_stylebox("normal").bg_color = Color.BLACK


	$AudioStreamPlayer2D.playing = true

#Starts Level 1
func _on_Button_pressed():
	var level1_scene = load("res://Scenes/LevelScenes/Main.tscn")
	assert(get_tree().change_scene_to_packed(level1_scene)== OK)
