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
	level_title = tr("LEVEL_TITLE_0_6")
	extended_new_power_description = "POWER_PORTALS_DESC_LONG"
	super()
	unlock_power.set_new_unlock_label("UI_NEW_SORCERY")
	attach_script_to_sway_children()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm"])
	_configure_waves()


func _configure_waves() -> void:
	zombie_spawner_1.set_waves_from_dicts([{"Reborn":7,"Severed":2},                             #(2+)
											{"Reborn": 11,"Severed":2},                          #(3+)    
											{"Reborn": 8, "Unhallower":1},                       #(6+)
											{"Severed": 4, "Reanimator":1},                      #(12)
											{"Severed": 6, "Reanimator":1}])                     #(13)
											
	zombie_spawner_2.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{"Severed": 2, "Reborn": 5},                         #(2)
											{"Reborn": 6, "Reanimator" : 1},                    #(11-)
											{"Reborn": 3, "Reanimator" : 1}])                    #(11-)
											
	zombie_spawner_3.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{},                                                  #(0)
											{"Reborn":15},                                       #(3)
											{"Reborn":20}])                                       #(4)
											
	zombie_spawner_4.set_waves_from_dicts([{},                                                   #(0)
											{"Reborn": 10, },                                    #(2)
											{"Severed": 3, "Unhallower": 1},                     #(6+)
											{"Amalgam":3},                                       #(10)
											{"Reborn":8,"Amalgam":4}])                           #(11+)
											
	zombie_spawner_5.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{},                                                 #(0)
											{"Unhallower": 1,"Severed": 4},                     #(7)
											{"Unhallower": 1,"Severed": 4}])                     #(7)
											
	zombie_spawner_6.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)  
											{"Severed": 6},                                      #(3)
											{"Reanimator":1},                                    #(10)
											{"Severed": 2,"Reanimator":1}])                      #(11)
											
	zombie_spawner_7.set_waves_from_dicts([{"Reborn":10, },                                       #(2)
											{"Severed":6,  },                                     #(3)
											{"Unhallower":1},                                     #(5)
											{"Reborn":8, "Amalgam":2},                           #(7)
											{"Amalgam":6}])                                      #(15)

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
