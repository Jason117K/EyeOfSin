extends WaveManagerTemplate
#WaveManager1

var gameStarted : bool = false 
# Set the Level Specific Transition and Restart Scenes 
func setScenes():
	print("Main Set Scenes")
	new_scene = preload("res://Scenes/LevelScenes/Level1--2.tscn")  # Load the Tranistion scene
	retry_scene = preload("res://Scenes/LevelScenes/RestartScene.tscn") # Load the Restart Scene 


func _on_plant_manager_spyder_placed() -> void:
	pass
	#if !gameStarted:
		#canStartGame = true 
		#print("Can Start Game is True ")
