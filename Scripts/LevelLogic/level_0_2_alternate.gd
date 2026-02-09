extends Control
# level_0_2_alternate.gd - Green Dimension Controller for Level 0-2
# Waits for purple dimension to activate Wave 2

@onready var toolTips = $"../ToolTips"
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $"../PlantSelectionMenu" #$PlantSelectionMenu
#@onready var waveManager = $GameLayer/WaveManager
var waveManager 
@onready var levelSwitcher = 	$"../LevelSwitcher"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	waveManager = get_parent().get_node("WaveManager")
	# Keep waves disabled until purple dimension activates us
	waveManager.canStartGame = false
	print("[Level0-1 Alternate] Green dimension loaded, waiting for Wave 2 activation")
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	plantManager.connect("walnut_placed", Callable(self, "_on_walnut_placed"))


func start_game():
	waveManager = get_parent().get_node("WaveManager")
	waveManager.canStartGame = true

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
	
func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)

func remove_empty_blocker_plant(grid_pos):
	plantManager.clear_space_alt(grid_pos)
	

func make_camera_current():
	$Camera2D.make_current()


func _on_walnut_placed(grid_pos: Vector2):
	print("[Tutorial] Walnut placement complete - tutorial finished")
	toolTips.hide()
	show_all_plant_buttons()
	# Tutorial complete - no further forced actions
	
func show_all_plant_buttons():
	# Show Sunflower
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = true

	# Show Spyder
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
	plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true

func add_sun(sunAmount):
	plantManager.add_sun(sunAmount)


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 5)
	
func hide_guide():
	$GameLayer/GridManager/TileMapLayer.clear_rectangles()		
