extends LevelTemplate

@onready var zombie_spawner_green := $GameLayer/ZombieSpawner2Green


func _ready() -> void:
	super()
	process_mode = Node.PROCESS_MODE_ALWAYS
	#attach_script_to_sway_children()
	attach_script_to_sway_children()
	_configure_waves()


func _configure_waves() -> void:
	zombie_spawner_green.set_waves_from_dicts([{}, {"Reborn": 5}, {"Reborn": 3, "Severed": 2}])


func setup_wave_2_ui() -> void:
	hide_all_demon_buttons_with_exception(["Crawler"])


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(4, 4)
