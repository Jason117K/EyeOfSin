extends LevelTemplate
# level_0_2_alternate.gd - Green Dimension Controller for Level 0-2
# Waits for purple dimension to activate Wave 2


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	attach_script_to_sway_children()
	plantManager.connect("walnut_placed", Callable(self, "_on_walnut_placed"))


func start_game():
	pass


func _on_walnut_placed(grid_pos: Vector2):
	print("[Tutorial] Walnut placement complete - tutorial finished")
	toolTips.hide()
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler"])
	# Tutorial complete - no further forced actions
	

func add_sun(sunAmount):
	plantManager.add_sun(sunAmount)


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 5)
	
