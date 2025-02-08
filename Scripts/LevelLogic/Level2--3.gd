extends Node2D
#Level2->3

#Switches the Level from 1 to 2 

onready var Lvl3 = preload("res://Scenes/LevelScenes/Level3.tscn")  # Load the next scene

#Sets Level Interim Screen TileMap 
func _ready():
	$GridManager.set_tiles_for_rows(1,6, 5)
	


#Changes the Scene to Level 3
func _on_Continue_pressed():
	assert(get_tree().change_scene_to(Lvl3) ==OK)
	

# Restarts the Scene 
func _on_PlayAgain_pressed():
	assert(get_tree().change_scene("res://Scenes/LevelScenes/Level2.tscn") ==OK)

