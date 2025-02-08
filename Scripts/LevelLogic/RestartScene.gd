extends Node2D
#RestartScene.gd



#Set the tilemap 
func _ready():
	$GridManager.set_tiles_for_rows(1,6, 5)

#Restart the current scene 
func _on_Retry_pressed():
	print(self.name)
	if(self.name == "RestartScene1"):
		assert(get_tree().change_scene("res://Scenes/LevelScenes/Main.tscn") ==OK)
	elif(self.name == "RestartScene2"):
		assert(get_tree().change_scene("res://Scenes/LevelScenes/Level2.tscn") ==OK)
	elif(self.name == "RestartScene3"):
		assert(get_tree().change_scene("res://Scenes/LevelScenes/Level3.tscn")==OK)
