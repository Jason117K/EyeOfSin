extends LevelTemplate



@export var isGreenDimension := false
var purple_dimension : Control

@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7

func _ready() -> void:
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	_configure_waves()


func _configure_waves():
	zombie_spawner_1.waves = [{"Flesheater": 1, "Reborn": 3}, {"Reborn": 3, "Severed": 1}, {"Flesheater": 2, "Reborn": 5, "Severed": 2}]
	zombie_spawner_2.waves = [{"Severed": 1, "Unhallower": 3}, {"Flesheater": 1, "Reborn": 6}, {"Flesheater": 2, "Reanimator": 1, "Reborn": 3, "Severed": 2, "Unhallower": 1}]
	zombie_spawner_3.waves = [{}, {"Flesheater": 2, "Reanimator": 1}, {"Flesheater": 1, "Reborn": 1, "Unhallower": 3}]
	zombie_spawner_4.waves = [{}, {"Flesheater": 1, "Reanimator": 2, "Unhallower": 1}, {"Flesheater": 1, "Reborn": 7, "Severed": 3, "Unhallower": 1}]
	zombie_spawner_5.waves = [{"Reborn": 2, "Severed": 1}, {"Reanimator": 1, "Reborn": 3}, {"Flesheater": 1, "Severed": 1, "Unhallower": 4}]
	zombie_spawner_6.waves = [{}, {"Reborn": 3}, {"Flesheater": 2, "Severed": 1, "Unhallower": 2}]
	zombie_spawner_7.waves = [{"Severed": 3}, {"Flesheater": 1, "Reborn": 2, "Unhallower": 1}, {"Flesheater": 1, "Severed": 1}]
	

func getIsGreenDimension():
	return isGreenDimension




	

func start_game():
	show_all_plant_buttons()
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	purple_dimension.start_game()


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
	
