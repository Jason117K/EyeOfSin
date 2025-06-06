extends Control
#LevelSwitcher

#Switches the Level to the next level

@export var nextLevel = preload("res://Scenes/LevelScenes/EmptyScene.tscn")  # Load the next scene
@export var next_level = "res://Scenes/LevelScenes/EmptyScene.tscn"
@export var level_unlocked := 2


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
#Moves onto next level 
func _on_Continue_pressed():
	$ButtonClickPlayer.play()
	#assert(get_tree().change_scene_to_packed(nextLevel) == OK)
	Global.game_controller.change_scene(next_level)
	Global.unlockLevel(level_unlocked)

#Restarts the current level
func _on_PlayAgain_pressed():
	$ButtonClickPlayer.play()
	#assert(get_tree().change_scene_to_file(get_parent().get_scene_file_path()) == OK)
	Global.game_controller.change_scene(get_parent().get_scene_file_path())
	Global.unlockLevel(level_unlocked)

func _on_return_to_menu_pressed() -> void:
	# Ensure proper cleanup before changing scene
	get_tree().root.set_input_as_handled()
	$ButtonClickPlayer.play()
	# Add a small delay to ensure clean transition
	await get_tree().create_timer(0.1).timeout
#	assert(get_tree().change_scene_to_file("res://Scenes/LevelScenes/StartScreen.tscn") == OK)
	Global.game_controller.change_scene("res://Scenes/LevelScenes/StartScreen.tscn")
	Global.unlockLevel(level_unlocked)
	
