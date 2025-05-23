extends Node2D
#RestartScene.gd



#Set the tilemap 
func _ready():
	#$GridManager.set_tiles_for_rows(1,6, 5)
	
		#$GameLayer/GridManager.set_tiles_for_rows(0,1, 28)
	$GridManager.set_tiles_for_rows(1,2, 26)
	
	$GridManager.set_tiles_for_rows(2,3, 26)
	$GridManager.set_tiles_for_rows(3,4, 23)
	$GridManager.set_tiles_for_rows(4,5, 23)
	$GridManager.set_tiles_for_rows(5,6, 23)
	$GridManager.set_tiles_for_rows(6,7, 26)
	
	#$GameLayer/GridManager.set_tiles_for_rows(7,8, 26)
	$GridManager.set_tiles_for_rows(8,9, 29)

#Restart the current scene 
func _on_Retry_pressed():
	print(self.name)
	if(self.name == "RestartScene1"):
		assert(get_tree().change_scene_to_file("res://Scenes/LevelScenes/Main.tscn") ==OK)
	elif(self.name == "RestartScene2"):
		assert(get_tree().change_scene_to_file("res://Scenes/LevelScenes/Level2.tscn") ==OK)
	elif(self.name == "RestartScene3"):
		assert(get_tree().change_scene_to_file("res://Scenes/LevelScenes/Level3.tscn")==OK)
