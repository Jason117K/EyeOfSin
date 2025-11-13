extends Control
#Level6.gd


@onready var toolTips = $ToolTips
@onready var waveManager = $GameLayer/WaveManager
@export var make_green := false 


var footBallZombieText = "res://Assets/Text/TextFiles/FootBallTutorial.txt"
var footBallZombieAnim = preload("res://Assets/Zombies/Animations/Spriteframes/FootBall.tres")
@onready var plantManager = $PlantManager

func _ready():
	attach_script_to_coral_children("res://Scripts/Environment/sway.gd")
	Global.resetSunflowerCount()
	process_mode = Node.PROCESS_MODE_ALWAYS
	#$GameLayer/GridManager.set_tiles_for_rows(0,1, 68)
	##$GameLayer/GridManager.set_tiles_for_rows(1,2, 66)
	#
	#$GameLayer/GridManager.set_tiles_for_rows(2,3, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(3,4, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(4,5, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(5,6, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(6,7, 63)
	#
##	$GameLayer/GridManager.set_tiles_for_rows(7,8, 66)
	#$GameLayer/GridManager.set_tiles_for_rows(8,9, 69)
	
	toolTips.set_text_pause(footBallZombieText)
	toolTips.setAnim(footBallZombieAnim)
	toolTips.showButton()
	make_camera_current()


func _on_tool_tips_tool_tip_hid() -> void:
	waveManager.canStartGame = true 


func _on_wave_manager_wave_2_almost_start() -> void:
	waveManager.startSecondWave()


func make_camera_current():
	$Camera2D.make_current()


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)


func attach_script_to_coral_children(script_path: String) -> void:

	# Find the Coral node
	var coral_node = get_node("Environment2/Coral")
	
	if coral_node == null:
		push_error("Coral node not found at Environment/Coral")
		return
	
	
	# Load the script to attach
	var script_to_attach = load(script_path)
	
	if script_to_attach == null:
		push_error("Failed to load script at: " + script_path)
		return
	
	# Iterate through all children and attach the script
	for child in coral_node.get_children():
		child.set_script(script_to_attach)
		if child.is_inside_tree() and child.has_method("_ready"):
			if make_green:
				child.make_green()
			child._ready()
		print("Script attached to: ", child.name)
