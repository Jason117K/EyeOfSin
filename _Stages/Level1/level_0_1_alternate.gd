extends LevelTemplate


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	attach_script_to_sway_children("res://Scripts/Environment/sway.gd")


func setup_wave_2_ui():
	hide_all_demon_buttons_with_exception(["Crawler"])


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(4, 4)
