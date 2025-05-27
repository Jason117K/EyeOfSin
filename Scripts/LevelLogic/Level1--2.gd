extends Control
#Level1->2

#Switches the Level from 1 to 2 


var Lvl2 = preload("res://Scenes/LevelScenes/Level2.tscn")  # Load the next scene


#TODO Abstract Level1--2 & Level2--3 into one script 


#Sets Level Interim Screen TileMap 
func _ready():
	$GridManager.set_tiles_for_rows(1,6, 5)

#Moves onto next level 
func _on_Continue_pressed():
	$ButtonClickPlayer.play()
	assert(get_tree().change_scene_to_packed(Lvl2) ==OK)

#Restarts the current level
func _on_PlayAgain_pressed():
	$ButtonClickPlayer.play()
	if(self.name == "Level1->2"):
		assert(get_tree().change_scene_to_file("res://Scenes/LevelScenes/Main.tscn") == OK)
	
