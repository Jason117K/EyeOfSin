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
											
	zombie_spawner_1.set_waves_from_dicts([{"Reborn":2,"Severed":2},                             #(1+)
											{"Reborn": 2,"Unhallower":1},                        #(5+)    
											{"Severed": 2, "Sundered":2},                       #(6)
											{"Severed": 4, "Reanimator":1},                      #(12)
											{"Sundered": 2, "Buffer":1}])                         #(10)
											
	zombie_spawner_2.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{"Sundered": 1},                                      #(5-)
											{"Reborn": 4, "Reanimator" : 1},                     #(11)
											{"Buffer": 1, "Reanimator" : 1}])                    #(15)
											
	zombie_spawner_3.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{},                                                  #(0)
											{ "Buffer": 1},                                      #(5)
											{ "Severed":4, "Buffer": 2}])                       #(12)
											
	zombie_spawner_4.set_waves_from_dicts([{},                                                    #(0)
											{"Severed": 1,"Unhallower":1},                        #(6)
											{"Reanimator":1},                                     #(10)
											{"Severed":2 ,"Sundered":4},                          #(11)
											{"Sundered":2,"Buffer":1}])                           #(15)
											
	zombie_spawner_5.set_waves_from_dicts([{},                                                   #(0)
											{},                                                  #(0)
											{},                                                  #(0)
											{"Buffer":1},                                        #(5)
											{"Buffer":2}])                                       #(10)
											
	zombie_spawner_6.set_waves_from_dicts([{},                                                    #(0)
											{},                                                   #(0)  
											{"Sundered": 1},                                      #(5-)
											{"Reanimator":1},                                     #(10)
											{"Sundered": 2,"Reanimator":1}])                      #(15)
											
	zombie_spawner_7.set_waves_from_dicts([{"Reborn":2,"Severed":2},                              #(1+)
											{"Reborn": 2,"Unhallower":1},                         #(5+)    
											{"Severed": 2, "Sundered":2},                         #(6)
											{"Severed": 4, "Reanimator":1},                       #(12)
											{"Sundered": 2, "Buffer":1}])                         #(10)
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
		"Sundered":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
