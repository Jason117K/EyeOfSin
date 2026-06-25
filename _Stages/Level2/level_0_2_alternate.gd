extends LevelTemplate
# level_0_2_alternate.gd - Green Dimension Controller for Level 0-2
# Waits for purple dimension to activate Wave 2

@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3

#215

func _ready() -> void:
	level_title = "0-2:BETRAYAL"
	extended_new_power_description = "BLOCKS ZOMBIES. SYNERGIES IMPROVE DEFENSE & STALLING POTENTIAL."
	super()
	hide_all_demon_buttons_with_exception(["Occulum","Crawler"])
	process_mode = Node.PROCESS_MODE_ALWAYS
	attach_script_to_sway_children()
	_configure_waves()
	demonManager.connect("spinalOcculum_placed", Callable(self, "_on_spinalOcculum_placed"))


func _configure_waves() -> void:
	zombie_spawner_1.set_waves_from_dicts([{"Reborn": 5},                  #(1)
											{"Reborn": 5, "Severed": 2},   #(2)
											{"Severed": 6}])                #(3)
	zombie_spawner_2.set_waves_from_dicts([{"Reborn": 5},                  #(1)
											{"Reborn": 5, "Severed": 2},   #(2)
											{"Reborn": 6, "Severed": 4}])  #(3)  
	zombie_spawner_3.set_waves_from_dicts([{},                              #(1)
											{"Severed": 4},                 #(2)
											{"Severed": 6}])                #(3)


func start_game() -> void:
	pass


func _on_spinalOcculum_placed(grid_pos: Vector2) -> void:
	print("[Tutorial] Spinal Occulum placement complete - tutorial finished")
	toolTips.hide()
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler","SpinalOcculum"])
	# Tutorial complete - no further forced actions
	

func add_blood(bloodAmount) -> void:
	demonManager.add_blood(bloodAmount)


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 5)



			
			
			
			
