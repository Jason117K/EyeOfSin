extends Control
#StartScreen.gd


func _ready():
	$GridManager.set_tiles_for_rows(0,1, 28)
	$GridManager.set_tiles_for_rows(1,2, 26)
	
	$GridManager.set_tiles_for_rows(2,3, 23)
	$GridManager.set_tiles_for_rows(3,4, 23)
	$GridManager.set_tiles_for_rows(4,5, 23)
	$GridManager.set_tiles_for_rows(5,6, 23)
	$GridManager.set_tiles_for_rows(6,7, 23)
	
	$GridManager.set_tiles_for_rows(7,8, 26)
	$GridManager.set_tiles_for_rows(8,9, 29)
	
	
	$AudioStreamPlayer2D.playing = true


func _on_Button_pressed():
	var level1_scene = load("res://Scenes/LevelScenes/Main.tscn")
	assert(get_tree().change_scene_to(level1_scene)== OK)
