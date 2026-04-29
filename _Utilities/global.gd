extends Node

#Tracks Which Levels Have Been Unlocked

var canPlayLevel2 : bool = true
var canPlayLevel3 : bool  = true
var canPlayLevel4 : bool = true
var canPlayLevel5 : bool = true
var canPlayLevel6 : bool = true
var canPlayLevel7 : bool = true
var sunflowerCount := 0  
var sunflowerCountVisual := 0  

var game_controller : GameController
var plant_selection_menu 
var plant_selection_menu_alt
var green_portal = null
var purple_portal = null 
var gameIsStarted := false
var hero_demon_summoned := false
var blood_rain 
var current_level
var hero_demon 

func get_current_scene_filepath():
	return game_controller.get_current_scene_filepath()

func hidePlantSelectionMenu():
	if plant_selection_menu != null:
		plant_selection_menu.visible = false 
	
func unHidePlantSelectionMenu():
	if plant_selection_menu != null:
		plant_selection_menu.visible = true 	
	
func resetSunflowerCount():
	sunflowerCount = 0
	gameIsStarted = false
	
func incrementSunflowerCount():
	sunflowerCount += 1
	plant_selection_menu.increaseSunflowerCost()
	#plant_selection_menu_alt.increaseSunflowerCost()
	
func incrementSunflowerCountVisual():
	sunflowerCountVisual += 1
	
func getSunflowerCount():
	#print("SSReturn , ", sunflowerCount)
	return sunflowerCount

func getSunflowerCountVisual():
	return sunflowerCountVisual
	
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
	
func register_blood_rain(new_blood_rain):
	blood_rain = new_blood_rain

func start_blood_rain():
	blood_rain.begin()
	
	
	
	
	
	
	
	
	
