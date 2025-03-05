extends WaveManagerTemplate
#WaveManager1


# Set the Level Specific Transition and Restart Scenes 
func setScenes():
	print("Main Set Scenes")
	new_scene = preload("res://Scenes/LevelScenes/Level1--2.tscn")  # Load the Tranistion scene
	retry_scene = preload("res://Scenes/LevelScenes/RestartScene.tscn") # Load the Restart Scene 


