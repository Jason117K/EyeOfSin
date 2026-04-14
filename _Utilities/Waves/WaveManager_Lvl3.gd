extends WaveManagerTemplate
#WaveManager3

# Set the Level Specific Transition and Restart Scenes 
func setScenes():
	new_scene = preload("res://Scenes/LevelScenes/EndScreen.tscn")  # Load the Tranistion scene
	retry_scene = preload("res://Scenes/LevelScenes/RestartScene3.tscn") # Load the Restart Scene 


		
		
