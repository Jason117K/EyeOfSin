extends Control

@onready var pause_button := $".."
var level0_3 := "res://_Stages/Level3/Level0-3.tscn"
var level0_3Alt := "res://_Stages/Level3/Level0-3_Alternate.tscn"

var options_menu := "res://_UI/Options/OptionsMenu.tscn"

@export var restartScene: String
@export var restartSceneAlt: String

func set_pause_process_mode():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	for child : Control in $CenterContainer.get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS

func set_restart_levels(newLevel: String, newAltLevel: String) -> void:
	print(newLevel,newAltLevel, "RESTART LEVELS SET")
	restartScene = newLevel
	restartSceneAlt = newAltLevel
	#print(restartScene,restartSceneAlt, "RESTART LEVELS SET2")

func _on_resume_pressed() -> void:
	print("UNPPAUSE HERE")
	pause_button.undo_toolTip_change()
	get_tree().paused = false

func _on_return_to_menu_pressed() -> void:
	# Ensure proper cleanup before changing scene
	get_tree().root.set_input_as_handled()
	#$ButtonClickPlayer.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	# Add a small delay to ensure clean transition
	await get_tree().create_timer(0.1).timeout
	self.visible = false
		#toolTips.visble = false
	#toolTips.hide()
	#get_parent().hide_toolTip()
	Global.game_controller.change_from_dual_scenes("res://_Stages/StartScreen/StartScreen.tscn")


func _on_restart_pressed() -> void:
	print(restartScene,restartSceneAlt, "RESTART LEVELS SET2364553645463564564645645465")
	get_tree().paused = false
	#var current_scene_filepath = Global.get_current_scene_filepath()
	#print("CCUrent Scene Is ", current_scene_filepath) 
	Global.game_controller.change_dual_scenes(restartScene,restartSceneAlt )
	#Global.game_controller.change_scene(current_scene_filepath)


	

func _on_options_pressed() -> void:
	Global.hideDemonSelectionMenu()
	Global.hide_notification_bar()
	self.hide()
	Global.game_controller.change_scene_with_pause(options_menu)
	
	

	
	
	
	
	
