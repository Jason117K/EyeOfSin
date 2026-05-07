extends LevelTemplate


@export var isGreenDimension := false 
var purple_dimension : Control

func _ready() -> void:
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	

func getIsGreenDimension():
	return isGreenDimension





func start_game():
	waveManager = get_parent().get_node("WaveManager")
	show_all_plant_buttons()
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	print("Purple Dim is ", purple_dimension)
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
