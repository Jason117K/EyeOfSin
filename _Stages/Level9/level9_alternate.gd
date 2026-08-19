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
	level_title = tr("LEVEL_TITLE_0_7")
	extended_new_power_description = "POWER_OCCULUM_DESC_LONG"
	super()
	attach_script_to_sway_children()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum","SpinalOcculum","Wyrm","Portal"])
	_configure_waves()


func _configure_waves() -> void:
	pass
	#8
	zombie_spawner_1.set_waves_from_dicts([{"Reborn":0,"Severed":8},                             #(3+)
											{"Reborn":4, "Unhallower":1},                         #(6-)    
											{"Reanimator":1},                                     #(10)
											{"Reanimator": 1, "Amalgam":2},                      #(15)
											{"Sundered": 3, "Buffer":2},                         #(20-)
											{"Unhallower":3, "Sundered":4}])                     #(25)
											
	zombie_spawner_2.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{},                                    #(10)
											{ "Amalgam" : 4},                                    #(15-)
											{"Sundered": 2, "Buffer" : 2},                        #(15)
											{"Amalgam": 4,"Buffer": 2}])                          #(20)
											
	zombie_spawner_3.set_waves_from_dicts([{"Reborn":0,"Severed":8},                                                   #(0)
											{},                                                  #(0)
											{},                                                  #(0)
											{"Amalgam": 3},                                      #(5)
											{"Buffer": 2},                                      #(10)
											{"Reanimator":2}])                                   #(20)
											
	zombie_spawner_4.set_waves_from_dicts([{},                                                   #(0)
											{"Unhallower":1},                                     #(5)
											{"Reanimator":1},                                    #(10)
											{"Reanimator":1 ,"Amalgam":2},                          #(11+)
											{"Sundered":3,"Buffer":2},                           #(20-)
											{"Unhallower":3,  "Reanimator":1}])                   #(25)
											
	zombie_spawner_5.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{},                                                  #(0)
											{"Amalgam": 2},                                      #(5)
											{"Buffer": 2},                                      #(10)
											{"Reanimator":2}])                                   #(20)
											
	zombie_spawner_6.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{"Reanimator":1},                                    #(10)
											{ "Amalgam" :4},                                    #(15-)
											{"Sundered": 2, "Buffer" : 2},                        #(15)
											{"Amalgam": 4,"Buffer": 2}])                          #(20)
			
			#8								
	zombie_spawner_7.set_waves_from_dicts([{"Reborn":0,"Severed":8},                             #(3+)
											{"Reborn":4, "Unhallower":1},                         #(6-)
											{"Reanimator":1},                                     #(10)
											{"Reanimator":1, "Amalgam":2},                         #(15)
											{ "Sundered":3, "Buffer":2},                          #(20-)
											{"Unhallower":3, "Sundered":4}])                      #(25)  

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
		"Rohan":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
