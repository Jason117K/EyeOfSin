extends Control

var level0_3 = ("res://Scenes/LevelScenes/Level0-3.tscn")
var level0_3Alt = ("res://Scenes/LevelScenes/Level0-3_Alternate.tscn")

@export var restartScene : String 
@export  var restartSceneAlt  : String 


func set_restart_levels(newLevel,newAltLevel):
	print(newLevel,newAltLevel, "RESTART LEVELS SET")
	restartScene = newLevel
	restartSceneAlt = newAltLevel
	print(restartScene,restartSceneAlt, "RESTART LEVELS SET2")

func _on_resume_pressed() -> void:
	print("UNPPAUSE HERE")
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
	get_parent().hide_toolTip()
	Global.game_controller.change_from_dual_scenes("res://Scenes/LevelScenes/StartScreen.tscn")


func _on_restart_pressed() -> void:
	print(restartScene,restartSceneAlt, "RESTART LEVELS SET2364553645463564564645645465")
	var current_scene_filepath = Global.get_current_scene_filepath()
	#print("CCUrent Scene Is ", current_scene_filepath) 
	Global.game_controller.change_dual_scenes(restartScene,restartSceneAlt )
	#Global.game_controller.change_scene(current_scene_filepath)
