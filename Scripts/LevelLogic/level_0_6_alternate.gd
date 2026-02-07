extends Control


@onready var toolTips = $"../ToolTips"
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $"../PlantSelectionMenu"
#@onready var waveManager = $GameLayer/WaveManager
var waveManager 
@onready var levelSwitcher = 	$"../LevelSwitcher"
@onready var spotlight_overlay = $"../SpotlightOverlay"  # Reference to CanvasLayer

@export var isGreenDimension := false 
var purple_dimension : Control

func _ready() -> void:
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	
func attach_script_to_sway_children(script_path: String) -> void:

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
			#if self.is_in_group("Green"):
				#child.make_green()
			child._ready()
		#print("Script attached to: ", child.name)	
	
func getIsGreenDimension():
	return isGreenDimension

func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)

func remove_empty_blocker_plant(grid_pos):
	plantManager.clear_space_alt(grid_pos)
	

func start_game():
	waveManager = get_parent().get_node("WaveManager")
	show_all_plant_buttons()
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	#print("Purple Dim is ", purple_dimension)
	purple_dimension.start_game()	
	waveManager.canStartGame = true


func show_all_plant_buttons():
	# Show Sunflower
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = true

	# Show Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true	

	#Show Walnut
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel").visible = true	

func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(2, 8)
	
func hide_guide():
	$GameLayer/GridManager/TileMapLayer.clear_rectangles()		
