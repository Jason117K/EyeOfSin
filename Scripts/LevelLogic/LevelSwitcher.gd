extends Control
#LevelSwitcher

#Switches the Level to the next level

#@export var nextLevel = preload("res://Scenes/LevelScenes/EmptyScene.tscn")  # Load the next scene
@export var next_level = "res://Scenes/LevelScenes/EmptyScene.tscn"
@export var next_level_alt = "res://Scenes/LevelScenes/EmptyScene.tscn"
@export var current_level = "res://Scenes/LevelScenes/EmptyScene.tscn"
@export var current_level_alt = "res://Scenes/LevelScenes/EmptyScene.tscn"

@export var level_unlocked := 2
@onready var outcome_label = $CenterContainer/VBoxContainer/OutcomeLabel
@onready var continue_button = $CenterContainer/VBoxContainer/Continue

var level02 = "res://Scenes/LevelScenes/Level0-2.tscn"
var level02Alt = "res://Scenes/LevelScenes/Level0-2_Alternate.tscn"

func _ready() -> void:
	self.visible = false 
	process_mode = Node.PROCESS_MODE_ALWAYS
	next_level = level02
	next_level_alt = level02Alt
	
#Moves onto next level 
func _on_Continue_pressed():
	#$ButtonClickPlayer.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	#assert(get_tree().change_scene_to_packed(nextLevel) == OK)
	#Global.game_controller.change_scene(next_level)
	Global.game_controller.change_dual_scenes(level02,level02Alt)
	self.visible = false 
	Global.unlockLevel(level_unlocked)

#Restarts the current level
func _on_PlayAgain_pressed():
	#$ButtonClickPlayer.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	#assert(get_tree().change_scene_to_file(get_parent().get_scene_file_path()) == OK)
	#Global.game_controller.change_scene(get_parent().get_scene_file_path())
	Global.game_controller.change_dual_scenes(current_level,current_level_alt)
	Global.unlockLevel(level_unlocked)

func _on_return_to_menu_pressed() -> void:
	# Ensure proper cleanup before changing scene
	get_tree().root.set_input_as_handled()
	#$ButtonClickPlayer.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	# Add a small delay to ensure clean transition
	await get_tree().create_timer(0.1).timeout
#	assert(get_tree().change_scene_to_file("res://Scenes/LevelScenes/StartScreen.tscn") == OK)
	#TODO Will this work with current setup?
	Global.game_controller.change_scene("res://Scenes/LevelScenes/StartScreen.tscn")
	Global.unlockLevel(level_unlocked)

func lose():
	#outcome_label.text = ""
	outcome_label.text = "YOU LOSE!"
	continue_button.visible = false 
