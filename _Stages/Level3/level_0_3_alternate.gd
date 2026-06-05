extends LevelTemplate



var purple_dimension: Control

@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5

func _ready() -> void:
	super()
	attach_script_to_sway_children()
	_configure_waves()


func _configure_waves() -> void:
	#pass
	zombie_spawner_1.set_waves_from_dicts([{"Reborn": 4, "Severed": 1}, 
											{"Reborn": 1, "Severed": 2},
											{"Reborn": 1, "Severed": 3}, 
											{ "Severed": 4}])
	zombie_spawner_2.set_waves_from_dicts([{},
											{}, 
											{"Severed": 1, "Reborn": 5}, 
											{"Severed": 2, "Unhallower": 1}])
	zombie_spawner_3.set_waves_from_dicts([{},
											{"Severed": 2},
											{"Severed": 3}, 
											{"Reborn": 6, "Unhallower": 2}])
	zombie_spawner_4.set_waves_from_dicts([{},
											{},
											{"Severed": 3, "Reborn":2}, 
											{"Severed": 1, "Reborn": 4, "Unhallower": 1}])
	zombie_spawner_5.set_waves_from_dicts([{"Severed": 2}, 
											{"Severed": 2, "Reborn":3},
											{"Reborn": 4, "Severed": 1}, 
											{"Severed": 4}])
											
	#zombie_spawner_1.set_waves_from_dicts([{"Erupter": 1}, {"Flesheater": 1, "Severed": 2}, {"Flesheater": 1, "Reborn": 3}])
	#zombie_spawner_2.set_waves_from_dicts([{"Severed": 1}, {"Flesheater": 1, "Reborn": 2}, {"Flesheater": 1, "Reborn": 3, "Severed": 1}])
	#zombie_spawner_3.set_waves_from_dicts([{}, {"Severed": 1}, {"Flesheater": 1}])
	#zombie_spawner_4.set_waves_from_dicts([{}, {"Reborn": 2, "Severed": 1}, {"Flesheater": 1, "Severed": 3}])
	#zombie_spawner_5.set_waves_from_dicts([{"Unhallower": 1}, {"Severed": 2, "Unhallower": 1}, {"Flesheater": 1, "Reborn": 3}])


func getIsGreenDimension() -> bool:
	return isGreenDimension


func start_game() -> void:
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	purple_dimension.start_game()


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 7)
