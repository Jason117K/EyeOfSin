extends LevelTemplate


var purple_dimension: Control

@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5
@onready var zombie_spawner_6 := $GameLayer/ZombieSpawner6
@onready var zombie_spawner_7 := $GameLayer/ZombieSpawner7

var amalgam_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/amalgam_zombie_demo.tscn")

const TUTORIAL_EXPLAIN_AMALGAM = "res://_Assets/Text/TextFiles/ZombieDescriptions/ScreenDoorZombieDescription.txt"


func _ready() -> void:
	level_title = "0-6:BONDS"
	extended_new_power_description = "TELEPORTS ZOMBIES TO OPPOSITE DIMENSION PORTAL. CONTROL THE FIELD"
	super()
	unlock_power.set_new_unlock_label("NEW SORCERCY")
	attach_script_to_sway_children()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm"])
	_configure_waves()


func _configure_waves() -> void:
	pass
	zombie_spawner_1.set_waves_from_dicts([{},
											{},
											{"Reborn": 10, "Unhallower":2}, 
											{"Severed": 2, "Unhallower": 1,"Amalgam":1 }])
	zombie_spawner_2.set_waves_from_dicts([{},
											{}, 
											{"Severed":3}, 
											{"Amalgam": 2}])
	zombie_spawner_3.set_waves_from_dicts([{"Reanimator":1, "Reborn":10},
											{"Reanimator" : 1, "Reborn":9,"Severed":3}, 
											{"Reanimator": 2, "Severed": 7}, 
											{"Reanimator": 2, "Unhallower": 1, "Severed" : 1}])
	zombie_spawner_4.set_waves_from_dicts([{"Unhallower": 1}, 
											{"Unhallower": 1, "Reborn": 6},
											{"Unhallower": 1, "Severed": 5}, 
											{"Unhallower": 2, "Reanimator":1}]) 
	zombie_spawner_5.set_waves_from_dicts([{"Reanimator":1, "Reborn":10},
											{"Reanimator" : 1, "Reborn":9,"Severed":3}, 
											{"Reanimator": 2, "Severed": 7}, 
											{"Reanimator": 2, "Unhallower": 1, "Severed" : 1}])
	zombie_spawner_6.set_waves_from_dicts([{},
											{}, 
											{"Severed":3}, 
											{"Amalgam": 2}])
	zombie_spawner_7.set_waves_from_dicts([{},
											{},
											{"Reborn": 10, "Unhallower":2}, 
											{"Severed": 2, "Unhallower": 1,"Amalgam":1 }])

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


func show_unlock_zombie_button(new_zombie_unlocked:String)->void:
	match new_zombie_unlocked:
		"Amalgam":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
			
			
func show_zombie_tutorial(_unlocked_zombie : String)->void:
	_start_explain_amalgam_zombie()

func _start_explain_amalgam_zombie() -> void:
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_AMALGAM)
	toolTips.set_visual_tutorial_visual(amalgam_zombie_demo_scene.instantiate())
