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
	super()
	attach_script_to_sway_children()
	_configure_waves()


func _configure_waves():
	zombie_spawner_1.set_waves_from_dicts([{}, {"Flesheater": 1, "Reanimator": 1, "Reborn": 7, "Sundered": 3}, {"Erupter": 3, "Flesheater": 1, "Reanimator": 1, "Severed": 7, "Sundered": 4, "Unhallower": 3}])
	zombie_spawner_2.set_waves_from_dicts([{"Reanimator": 1, "Reborn": 3, "Sundered": 1}, {"Erupter": 2, "Reanimator": 1, "Reborn": 7, "Severed": 3}, {"Flesheater": 1, "Reanimator": 1, "Reborn": 7, "Severed": 3, "Sundered": 6, "Unhallower": 1}])
	zombie_spawner_3.set_waves_from_dicts([{}, {"Erupter": 3, "Flesheater": 1, "Reanimator": 2, "Severed": 2, "Sundered": 2, "Unhallower": 2}, {"Erupter": 2, "Flesheater": 1, "Reanimator": 1, "Reborn": 3, "Severed": 2, "Sundered": 5, "Unhallower": 6}])
	zombie_spawner_4.set_waves_from_dicts([{"Sundered": 2}, {"Erupter": 2, "Flesheater": 3, "Severed": 6, "Sundered": 3}, {"Erupter": 2, "Flesheater": 2, "Reanimator": 1, "Severed": 3, "Unhallower": 1}])
	zombie_spawner_5.set_waves_from_dicts([{"Reanimator": 1, "Unhallower": 3}, {"Flesheater": 2, "Reborn": 9, "Severed": 6, "Sundered": 5, "Unhallower": 2}, {"Erupter": 9, "Flesheater": 1, "Reborn": 6, "Severed": 4, "Sundered": 5, "Unhallower": 3}])
	zombie_spawner_6.set_waves_from_dicts([{"Flesheater": 1, "Sundered": 3}, {"Erupter": 2, "Flesheater": 5, "Reborn": 3, "Severed": 3}, {"Erupter": 3, "Flesheater": 4, "Reanimator": 2, "Reborn": 1, "Severed": 1, "Unhallower": 6}])
	zombie_spawner_7.set_waves_from_dicts([{}, {"Erupter": 1, "Flesheater": 4, "Reanimator": 1, "Reborn": 12, "Severed": 1, "Unhallower": 1}, {"Erupter": 3, "Flesheater": 3, "Reanimator": 1, "Severed": 3, "Sundered": 1}])


func getIsGreenDimension():
	return isGreenDimension


func start_game():
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	purple_dimension.start_game()


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 9)
	
