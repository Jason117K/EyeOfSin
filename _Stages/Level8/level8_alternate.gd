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
	level_title = tr("LEVEL_TITLE_0_8")
	extended_new_power_description = "POWER_OCCULUM_DESC_LONG"
	super()
	attach_script_to_sway_children()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm"])
	_configure_waves()


func _configure_waves() -> void:
	pass
	zombie_spawner_1.set_waves_from_dicts([{"Reborn":7,"Severed":4},                             #(2+)
											{"Reborn": 11,"Severed":2},                          #(3+)    
											{"Sundered":1,"Severed": 4, "Unhallower":1,},                       #(6+)
											{"Severed": 4, "Reanimator":1},                      #(12)
											{"Severed": 6, "Reanimator":1}])                     #(13)
											
	zombie_spawner_2.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{"Severed": 2, "Sundered": 2},                         #(2)
											{"Unhallower": 1, "Reanimator" : 1},                    #(11-)
											{"Reborn": 3, "Reanimator" : 1}])                    #(11-)
											
	zombie_spawner_3.set_waves_from_dicts([{},                                                   #(0)
											{"Sundered":1},                                                  #(0)
											{"Amalgam":2},                                                  #(0)
											{"Severed":6,"Unhallower": 1},                                       #(3)
											{"Severed":15,"Amalgam":2}])                                       #(4)
											
	zombie_spawner_4.set_waves_from_dicts([{},                                                   #(0)
											{"Reborn": 10, },                                    #(2)
											{"Severed": 3, "Unhallower": 1},                     #(6+)
											{"Amalgam":3},                                       #(10)
											{"Reborn":8,"Amalgam":4}])                           #(11+)
											
	zombie_spawner_5.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{"Unhallower":1},                                                 #(0)
											{"Unhallower": 1,"Severed": 3},                     #(7)
											{"Unhallower": 2,"Sundered": 4}])                     #(7)
											
	zombie_spawner_6.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)  
											{"Severed": 6, "Amalgam":1},                                      #(3)
											{"Reanimator":1},                                    #(10)
											{"Severed": 2,"Reanimator":1}])                      #(11)
											
	zombie_spawner_7.set_waves_from_dicts([{"Reborn":12, },                                       #(2)
											{"Severed":8, },                                     #(3)
											{"Sundered":2,"Unhallower":1},                                     #(5)
											{"Severed":10, "Amalgam":2},                           #(7)
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
		"Buffer":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
