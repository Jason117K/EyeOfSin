extends Node2D
#Level1->2



var Lvl2 = preload("res://Scenes/LevelScenes/Level2.tscn")  # Load the next scene

# Called when the node enters the scene tree for the first time.
func _ready():
	$GridManager.set_tiles_for_rows(1,6, 5)


func _on_Continue_pressed():
	$ButtonClickPlayer.play()
	assert(get_tree().change_scene_to(Lvl2) ==OK)


func _on_PlayAgain_pressed():
	$ButtonClickPlayer.play()
	if(self.name == "Level1->2"):
		assert(get_tree().change_scene("res://Scenes/Main.tscn") == OK)
	