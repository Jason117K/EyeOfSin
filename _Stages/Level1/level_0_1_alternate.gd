extends LevelTemplate

@onready var zombie_spawner_2_green := $GameLayer/ZombieSpawner2Green

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")
	_configure_waves()


func _configure_waves():
	zombie_spawner_2_green.waves = [{}, {"Reborn": 5}, {"Reborn": 3, "Severed": 2}]


func setup_wave_2_ui():
	hide_all_demon_buttons_with_exception(["Crawler"])


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(4, 4)
