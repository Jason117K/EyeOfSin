extends LevelTemplate
# level_0_2_alternate.gd - Green Dimension Controller for Level 0-2
# Waits for purple dimension to activate Wave 2

@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3


func _ready():
	super()
	process_mode = Node.PROCESS_MODE_ALWAYS
	attach_script_to_sway_children()
	_configure_waves()
	demonManager.connect("spinalOcculum_placed", Callable(self, "_on_spinalOcculum_placed"))


func _configure_waves():
	zombie_spawner_1.set_waves_from_dicts([{"Reborn": 3}, {"Reborn": 3, "Severed": 1}, {"Reborn": 4, "Severed": 4}])
	zombie_spawner_2.set_waves_from_dicts([{"Severed": 1}, {"Reborn": 3, "Severed": 1}, {"Reborn": 5, "Severed": 2, "Unhallower": 1}])
	zombie_spawner_3.set_waves_from_dicts([{}, {"Severed": 2}, {"Unhallower": 1}])


func start_game():
	pass


func _on_spinalOcculum_placed(grid_pos: Vector2):
	print("[Tutorial] Spinal Occulum placement complete - tutorial finished")
	toolTips.hide()
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler","SpinalOcculum"])
	# Tutorial complete - no further forced actions
	

func add_blood(bloodAmount):
	demonManager.add_blood(bloodAmount)


func show_guide():
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 5)
	
