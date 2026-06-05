extends LevelTemplate


var purple_dimension: Control

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


func _configure_waves() -> void:
	pass
	#zombie_spawner_1.set_waves_from_dicts([{"Flesheater": 1, "Reanimator": 1, "Reborn": 15, "Severed": 5, "Unhallower": 1}, {"Reborn": 10, "Severed": 6, "Unhallower": 7}, {"Flesheater": 1, "Severed": 1}])
	#zombie_spawner_2.set_waves_from_dicts([{"Erupter": 1, "Flesheater": 1, "Reborn": 5, "Severed": 1, "Sundered": 3, "Unhallower": 8}, {"Amalgam": 1, "Flesheater": 4, "Sundered": 3, "Unhallower": 2}, {"Flesheater": 1, "Severed": 1}])
	#zombie_spawner_3.set_waves_from_dicts([{"Erupter": 5, "Flesheater": 3, "Reborn": 1, "Severed": 5, "Sundered": 1, "Unhallower": 1}, {"Amalgam": 2, "Erupter": 3, "Flesheater": 1, "Reanimator": 1, "Reborn": 3, "Unhallower": 6}, {"Flesheater": 1, "Severed": 1}])
	#zombie_spawner_4.set_waves_from_dicts([{"Amalgam": 3, "Erupter": 1, "Flesheater": 3, "Reborn": 5, "Sundered": 7}, {"Amalgam": 5, "Severed": 3, "Unhallower": 9}, {"Flesheater": 1, "Severed": 1}])
	#zombie_spawner_5.set_waves_from_dicts([{"Amalgam": 7, "Reanimator": 2, "Reborn": 7, "Severed": 1, "Sundered": 2, "Unhallower": 1}, {"Erupter": 5, "Flesheater": 1, "Reborn": 3, "Severed": 2}, {"Flesheater": 1, "Severed": 1}])
	#zombie_spawner_6.set_waves_from_dicts([{"Erupter": 7, "Flesheater": 4}, {"Erupter": 5, "Flesheater": 2, "Reanimator": 2, "Reborn": 3, "Severed": 7, "Unhallower": 1}, {"Flesheater": 1, "Severed": 1}])
	#zombie_spawner_7.set_waves_from_dicts([{"Amalgam": 8, "Erupter": 5, "Unhallower": 5}, {"Reborn": 15, "Severed": 5, "Unhallower": 8}, {"Flesheater": 1, "Severed": 1}])


func getIsGreenDimension() -> bool:
	return isGreenDimension


func start_game() -> void:
	show_all_demon_buttons()
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	purple_dimension.start_game()



func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 9)
