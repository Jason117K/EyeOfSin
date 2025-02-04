extends Control
#StartScreen.gd


func _ready():
	
	$GridManager.set_tiles_for_rows(0,1, 28)
	$GridManager.set_tiles_for_rows(1,1, 26)
	
	$GridManager.set_tiles_for_rows(2,1, 21)
	$GridManager.set_tiles_for_rows(3,1, 22)
	$GridManager.set_tiles_for_rows(4,1, 3)
	$GridManager.set_tiles_for_rows(5,1, 4)
	$GridManager.set_tiles_for_rows(6,1, 12)
	
	$GridManager.set_tiles_for_rows(7,1, 26)
	$GridManager.set_tiles_for_rows(8,1, 18)
	
	
	$AudioStreamPlayer2D.playing = true


func _on_Button_pressed():
	var level1_scene = load("res://Scenes/LevelScenes/Main.tscn")
	assert(get_tree().change_scene_to(level1_scene)== OK)
