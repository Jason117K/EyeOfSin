extends LevelTemplate

@onready var zombie_spawner_green := $GameLayer/ZombieSpawner2Green


func _ready() -> void:
	super()
	hide_all_demon_buttons_with_exception(["Crawler"])
	waveManager.wave_started.connect(_on_wave_started)
	process_mode = Node.PROCESS_MODE_ALWAYS
	#attach_script_to_sway_children()
	attach_script_to_sway_children()
	_configure_waves()


func _configure_waves() -> void:
	zombie_spawner_green.set_waves_from_dicts([{}, {"Reborn": 4}, {"Severed": 3}])


func setup_wave_2_ui() -> void:
	hide_all_demon_buttons_with_exception(["Crawler"])


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(4, 4)

func _on_wave_started(wave_index: int)->void:
	match wave_index:
		0:
			pass
		1:
			pass
			#demonManager.add_blood(50)
		2:
			pass
			demonManager.add_blood(25)
