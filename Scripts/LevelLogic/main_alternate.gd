extends Control

@onready var plantManager = $PlantManager
@onready var waveManager = $GameLayer/WaveManager
@onready var toolTips = $ToolTips
@export var make_green := true 

func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)


func finish_setup_and_start():
	$PlantSelectionMenu.showEyeSummon()
	#toolTips.noButtonShow()
	$GameLayer/WaveManager.canStartGame = true 


func startWave2():
	waveManager.startSecondWave()


func attach_script_to_coral_children(script_path: String) -> void:

	# Find the Coral node
	var coral_node = get_node("Environment/Coral")
	
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
