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
	level_title = tr("LEVEL_TITLE_0_5")
	extended_new_power_description = "POWER_WYRM_DESC_LONG"
	super()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum"])
	attach_script_to_sway_children()
	_configure_waves()


func _configure_waves() -> void:
	zombie_spawner_1.set_waves_from_dicts([{},                                                   #(0)
											{"Reborn": 5, "Unhallower":1},                      #(6)
											{"Severed":2,"Reanimator":1}])                      #(10)
											
	zombie_spawner_2.set_waves_from_dicts([{},                                                   #(0)
											{"Severed": 2, "Unhallower":1},                      #(6)
											{"Reborn":5,"Reanimator":1}])                        #(10)
											
	zombie_spawner_3.set_waves_from_dicts([{},                                                   #(0)
											{"Reborn": 5, "Unhallower":1},                      #(6)
											{"Severed":2,"Reanimator":1}])                      #(10)
											
	zombie_spawner_4.set_waves_from_dicts([{"Severed":7},                                         #(4-)
											{"Reborn": 15, "Unhallower": 1},                       #(8)
											{"Severed": 7, "Reanimator" : 1}])                     #(14-)
											
	zombie_spawner_5.set_waves_from_dicts([{"Reborn":10,"Severed":4},                             #(4)
											{"Severed":2,"Unhallower":1},                         #(9)
											{"Reborn":10,"Severed":4,"Reanimator": 1}])           #(14)
											
	zombie_spawner_6.set_waves_from_dicts([{"Severed":7},                                         #(4-)
											{"Reborn": 15, "Unhallower": 1},                       #(8)
											{"Severed": 7, "Reanimator" : 1}])                     #(14-)
											
	zombie_spawner_7.set_waves_from_dicts([{"Reborn":10,"Severed":4},                             #(4)
											{"Severed":2,"Unhallower":1},                         #(9)
											{"Reborn":10,"Severed":4,"Reanimator": 1}])           #(14)
											
											
											
											

func getIsGreenDimension() -> bool:
	return isGreenDimension


func start_game() -> void:
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	#purple_dimension.start_game()

func place_wyrm_queen()->void:
	demonSelectionMenu.set_wyrm_queen()
	demonManager.place_demon(Vector2(48,240),true)


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 9)
	
