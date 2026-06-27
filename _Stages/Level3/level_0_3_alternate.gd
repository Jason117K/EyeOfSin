extends LevelTemplate

var purple_dimension: Control

@onready var zombie_spawner_1 := $GameLayer/ZombieSpawner1
@onready var zombie_spawner_2 := $GameLayer/ZombieSpawner2
@onready var zombie_spawner_3 := $GameLayer/ZombieSpawner3
@onready var zombie_spawner_4 := $GameLayer/ZombieSpawner4
@onready var zombie_spawner_5 := $GameLayer/ZombieSpawner5

var buckethead_zombie_demo_scene := preload("res://_UI/GameDemonstrations/ZombieTutorials/buckethead_zombie_demo.tscn")


func _ready() -> void:
	level_title = "0-3:ACCEPTANCE"
	extended_new_power_description = "SUMMONS LIGHTNING IN SELECTED AREA. TEARS THROUGH HORDES."
	super()
	hide_all_demon_buttons_with_exception(["Crawler","Occulum"])
	attach_script_to_sway_children()
	_configure_waves()
	unlock_power.set_new_unlock_label("NEW SORCERCY")


func _configure_waves() -> void:
	#pass
	zombie_spawner_1.set_waves_from_dicts([{"Reborn": 4, "Severed": 1}, 		 #(2)
											{"Reborn": 8, "Severed": 2}, 		 #(3)
											{"Reborn": 8, "Severed": 4}, 		 #(4)
											{"Reborn": 8, "Severed": 6}])		 #(5)
											
	zombie_spawner_2.set_waves_from_dicts([{}, 									#(0)
											{}, 								 #(0)
											{"Severed": 2, "Reborn": 5},  		 #(2)
											{"Severed": 4, "Unhallower": 1}]) 	 #(3)
											
	zombie_spawner_3.set_waves_from_dicts([{},              			         #(0)
											{"Severed": 2},						 #(1)
											{"Severed": 4}, 					 #(3)
											{"Reborn": 8, "Unhallower": 1}])	 #(3)
											
	zombie_spawner_4.set_waves_from_dicts([{}, 					            	 #(0)
											{"Reborn":4},						 #(1)
											{"Reborn": 4, "Severed": 4}, 		  #(3)
											{"Severed": 7}])					 #(4)
											
	zombie_spawner_5.set_waves_from_dicts([{"Severed":2},                        #(1)
											{"Severed": 4},						 #(2)
											{"Severed": 6}, 					 #(3)
											{"Reborn": 8, "Unhallower": 1}])	 #(3)
											
											
											
											
											
											
											
	#zombie_spawner_1.set_waves_from_dicts([{"Erupter": 1}, {"Flesheater": 1, "Severed": 2}, {"Flesheater": 1, "Reborn": 3}])
	#zombie_spawner_2.set_waves_from_dicts([{"Severed": 1}, {"Flesheater": 1, "Reborn": 2}, {"Flesheater": 1, "Reborn": 3, "Severed": 1}])
	#zombie_spawner_3.set_waves_from_dicts([{}, {"Severed": 1}, {"Flesheater": 1}])
	#zombie_spawner_4.set_waves_from_dicts([{}, {"Reborn": 2, "Severed": 1}, {"Flesheater": 1, "Severed": 3}])
	#zombie_spawner_5.set_waves_from_dicts([{"Unhallower": 1}, {"Severed": 2, "Unhallower": 1}, {"Flesheater": 1, "Reborn": 3}])


func getIsGreenDimension() -> bool:
	return isGreenDimension


func start_game() -> void:
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler"])
	for node in get_parent().get_children():
		if node.has_method("getIsPurpleDimension"):
			purple_dimension = node
	purple_dimension.start_game()


func show_guide() -> void:
	$GameLayer/GridManager/TileMapLayer.place_rectangles_on_rows(3, 7)
	
func _spinal_occulum_unlocked()->void:
	hide_all_demon_buttons_with_exception(["Occulum", "Crawler", "SpinalOcculum"])
	demonSelectionMenu.highlight_demon_card("SpinalOcculum")
	toolTips.set_basic_tutorial_text(TUTORIAL_SPINAL_OCCULUM_UNLOCKED, false)
	
func _hide_spinal_occulum_highlight()->void:
	print("Green Hide Spinal Occulum Highlight")
	demonSelectionMenu.unhighlight_demon_card("SpinalOcculum")
	toolTips.hide()


func pre_place_spinal_occulum()->void:
	demonManager.add_blood(150)
	demonSelectionMenu._on_SpinalOcculumButton_pressed()
	demonManager.place_demon(Vector2(304,112))
	await get_tree().physics_frame
	demonSelectionMenu._on_SpinalOcculumButton_pressed()
	demonManager.place_demon(Vector2(304,176))
	await get_tree().physics_frame
	demonSelectionMenu._on_SpinalOcculumButton_pressed()
	demonManager.place_demon(Vector2(304,240))

func show_zombie_tutorial(_unlocked_zombie : String)->void:
	_start_explain_unhallower()

func _start_explain_unhallower() -> void:
	auto_advance = false
	toolTips.set_visual_tutorial_text(TUTORIAL_EXPLAIN_BUCKETHEAD_ZOMBIE)
	toolTips.set_visual_tutorial_visual(buckethead_zombie_demo_scene.instantiate(),true,Vector2(0,32))
	
func show_unlock_zombie_button(new_zombie_unlocked:String)->void:
	match new_zombie_unlocked:
		"Unhallower":
			ui_layer.new_zombie_unlocked_button.show()
			ui_layer.set_zombie_icon_texture(new_zombie_unlocked)
