extends Node

#Tracks Which Levels Have Been Unlocked

var canPlayLevel2 : bool = true
var canPlayLevel3 : bool  = true
var canPlayLevel4 : bool = true
var canPlayLevel5 : bool = true
var canPlayLevel6 : bool = true
var canPlayLevel7 : bool = true
var occulumCount := 0  
var occulumCountVisual := 0  
var wave_manager

var all_zombies := []
var game_controller : GameController
var demon_selection_menu 
var notification_bar
var green_portal = null
var purple_portal = null 
var gameIsStarted := false
var hero_demon_summoned := false
var swap_ability 
var current_level
var hero_demon 
var ui_layer : Control
var demon_costs: Dictionary = {}
var demon_scenes : Dictionary

func _load_demon_costs():
	demon_scenes = {
		"Occulum": "res://_Entities/Demons/_Occulum/Occulum.tscn",
		"Crawler": "res://_Entities/Demons/_Crawler/Crawler.tscn",
		"SpinalOcculum": "res://_Entities/Demons/_CagedOculum/SpinalOcculum.tscn",
		"Wyrm": "res://_Entities/Demons/_Wyrm/Wyrm.tscn",
		"Maw": "res://_Entities/Demons/_Maw/Maw.tscn",
		"Hive": "res://_Entities/Demons/_Hive/Hive.tscn",
	}
	for demon_name in demon_scenes:
		var scene: PackedScene = load(demon_scenes[demon_name])
		var instance: Node = scene.instantiate()
		demon_costs[demon_name] = instance.cost  # each demon script has an @export var cost: int
		instance.queue_free()

func get_demon_cost(demon_name: String) -> int:
	return demon_costs.get(demon_name, -1)
	
func get_current_scene_filepath():
	return game_controller.get_current_scene_filepath()
	
func register_wave_manager(new_wavemanager):
	wave_manager = new_wavemanager

func get_wave_manager():
	return wave_manager
	
func register_ui_layer(new_ui_layer):
	ui_layer = new_ui_layer

func hideDemonSelectionMenu():
	if demon_selection_menu != null:
		demon_selection_menu.visible = false 
	
func unHideDemonSelectionMenu():
	if demon_selection_menu != null:
		demon_selection_menu.visible = true 	
		
func swap_portal_button():
	demon_selection_menu.swap_portal_button()
	
func resetOcculumCount():
	occulumCount = 0
	gameIsStarted = false
	
func incrementOcculumCount():
	occulumCount += 1
	demon_selection_menu.increaseOcculumCost()
	
func incrementOcculumCountVisual():
	occulumCountVisual += 1
	
func getOcculumCount():
	#print("SSReturn , ", occulumCount)
	return occulumCount

func getOcculumCountVisual():
	return occulumCountVisual
	
func setCanPlayLevel2():
	canPlayLevel2 = true  
	
func getCanPlayLevel2():
	return canPlayLevel2    
	
	
func setCanPlayLevel3():
	canPlayLevel3 = true  

func getCanPlayLevel3():
	return canPlayLevel3 
	
	
func setCanPlayLevel4():
	canPlayLevel4 = true 
	
func getCanPlayLevel4():
	return canPlayLevel4
	 

func setCanPlayLevel5():
	canPlayLevel5 = true  
	
func getCanPlayLevel5():
	return canPlayLevel5 
	
	
func setCanPlayLevel6():
	canPlayLevel6 = true  
	
func getCanPlayLevel6():
	return canPlayLevel6 
	
		
func setCanPlayLevel7():
	canPlayLevel7 = true  
	
func getCanPlayLevel7():
	return canPlayLevel7 

func unlockLevel(levelUnlocked):
	match levelUnlocked:
		1:
			pass
		2:
			setCanPlayLevel2()
		3:
			setCanPlayLevel3()
		4:
			setCanPlayLevel4()
		5:
			setCanPlayLevel5()
		6:
			setCanPlayLevel6()
		7:
			setCanPlayLevel7()
	
func start_wave_1():
	if current_level != null:
		current_level.wave_1_active = true	
		#print("Current Level is ", current_level, " wave 1 active is ", current_level.wave_1_active)
	else:
		pass
		#print("Current Level is Null")
	
func show_guide():
	game_controller.show_guide()	
	
func clear_guide():
	game_controller.clear_guide()		
	
func get_game_controller():
	return game_controller
	
func register_green_portal(new_green_portal):
	if purple_portal == null :
		new_green_portal.add_to_group("EntrancePortal")
	green_portal = new_green_portal


func register_purple_portal(new_purple_portal):
	if green_portal == null :
		new_purple_portal.add_to_group("EntrancePortal")
	purple_portal = new_purple_portal
	
func get_purple_portal_location():
	return purple_portal.global_position
	
func get_green_portal_location():
	return green_portal.global_position
	
	
func register_hero_demon(new_hero_demon):
	hero_demon = new_hero_demon 
	hero_demon_summoned = true 
	
func hero_demon_is_summoned():
	return hero_demon_summoned

func swap_scenes():
	game_controller.swap_scenes()
	swap_portal_button()
	
func register_swap_ability(new_swap_ability):
	swap_ability = new_swap_ability
	
func register_notification_bar(new_notification_bar):
	notification_bar = new_notification_bar
	

func start_swap_ability():
	if swap_ability != null:
		swap_ability.begin()
	
func stop_swap_ability():
	if swap_ability != null:
		swap_ability.stop()
		
func reset_swap_ability():
	if swap_ability != null:
		swap_ability.reset_on_game_start()
	
func register_zombie(new_zombie):
	all_zombies.append(new_zombie)
	if swap_ability != null:
		swap_ability.append_new_zombie(new_zombie)
	
	
func deregister_zombie(zombie_to_delete):
	all_zombies.erase(zombie_to_delete)
	
func get_all_zombies():
	return all_zombies
	
func set_zombie_info_bar(zombie):
	#print(" notification_bar" , notification_bar)
	notification_bar.set_zombie_info(zombie)
	pass
	
func hide_notification_bar():
	if notification_bar != null:
		notification_bar.hide()
	
	
	
	
