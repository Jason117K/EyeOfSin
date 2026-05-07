extends LevelTemplate
# level_0_2_alternate.gd - Green Dimension Controller for Level 0-2
# Waits for purple dimension to activate Wave 2


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
	
