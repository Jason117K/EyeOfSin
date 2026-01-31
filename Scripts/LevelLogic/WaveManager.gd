extends WaveManagerTemplate
#WaveManager1

var gameStarted : bool = false 
@export var dialogic_end := "res://Assets/Dialog/level_0_end_dialog.dtl"
@export var alt := false

# Set the Level Specific Transition and Restart Scenes 
func setScenes():
	print("Main Set Scenes")
	#new_scene = preload("res://Scenes/LevelScenes/Level1--2.tscn")  # Load the Tranistion scene
	#retry_scene = preload("res://Scenes/LevelScenes/RestartScene.tscn") # Load the Restart Scene 


func _on_plant_manager_spyder_placed() -> void:
	pass

func set_dialog_end(newEndDialog):
	dialogic_end = newEndDialog

func end_level():
	print("Attempting End Current Level")
	
	if alt : 
		return 
	
	Dialogic.timeline_ended.connect(win_level)
	Dialogic.start(dialogic_end)


func win_level():
	$"../LevelSwitcher".visible = true
	$"../ToolTips".visible = false
	for child in get_parent().get_parent().get_parent().get_children():
		if "LevelSwitcher" in child.name:
			child.visible = true
	get_tree().paused = true
			
