extends Control
#LevelSwitcher

#Switches the Level to the next level

#@export var nextLevel = preload("res://Scenes/LevelScenes/EmptyScene.tscn")  # Load the next scene
@export var next_level = "res://_Stages/Empty/EmptyScene.tscn"
@export var next_level_alt = "res://_Stages/Empty/EmptyScene.tscn"
@export var current_level = "res://_Stages/Empty/EmptyScene.tscn"
@export var current_level_alt = "res://_Stages/Empty/EmptyScene.tscn"
@onready var toolTips = $"../ToolTips"
@export var level_unlocked := 2
@onready var outcome_label = $CenterContainer/VBoxContainer/OutcomeLabel
@onready var continue_button = $CenterContainer/VBoxContainer/Continue



func _ready() -> void:
	self.visible = false 
	process_mode = Node.PROCESS_MODE_ALWAYS

	
#Moves onto next level 
func _on_Continue_pressed():
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	Global.game_controller.change_from_dual_scenes("res://_Stages/LevelSelect/LevelSelect_Map.tscn")
	self.visible = false 
	Global.unlockLevel(level_unlocked)

#Restarts the current level
func _on_PlayAgain_pressed():
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	self.visible = false 
	Global.game_controller.change_dual_scenes(current_level,current_level_alt)
	Global.unlockLevel(level_unlocked)

func _on_return_to_menu_pressed() -> void:
	get_tree().root.set_input_as_handled()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	# Add a small delay to ensure clean transition
	await get_tree().create_timer(0.1).timeout
	self.visible = false 
	Global.game_controller.change_from_dual_scenes("res://_Stages/StartScreen/StartScreen.tscn")
	Global.unlockLevel(level_unlocked)

func update_level(this_upcomingLevel,this_upcomingLevelAlt):
	next_level = this_upcomingLevel
	next_level_alt = this_upcomingLevelAlt
	pass

func update_current_level(this_current_Level,this_current_LevelAlt):
	current_level = this_current_Level
	current_level_alt = this_current_LevelAlt
	pass
	
	
func lose():
	#outcome_label.text = ""
	outcome_label.text = "YOU LOSE!"
	continue_button.visible = false 
