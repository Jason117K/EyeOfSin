extends WaveManagerTemplate
#WaveManager2

	
	
# Set the Level Specific Transition and Restart Scenes 
func setScenes():
	new_scene = preload("res://Scenes/LevelScenes/Level2--3.tscn")  # Load the Tranistion scene
	retry_scene = preload("res://Scenes/LevelScenes/RestartScene2.tscn") # Load the Restart Scene 


