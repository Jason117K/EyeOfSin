extends Node

#Tracks Which Levels Have Been Unlocked

var canPlayLevel2: bool = true
var canPlayLevel3: bool = true
var canPlayLevel4: bool = true
var canPlayLevel5: bool = true
var canPlayLevel6: bool = true
var canPlayLevel7: bool = true
var occulumCount := 0
var green_occulum_count := 0
var purple_occulum_count := 0 

var occulumCountVisual := 0
var wave_manager : Node
var is_blocking := false

var dialog_is_disabled := true 
var skip_tutorials := false 

var all_zombies := []
var all_demons := []
var game_controller: GameController
var demon_selection_menus : Array = []
var demon_selection_menu : Control
var notification_bar : Control 
var green_portal :Node = null
var purple_portal :Node= null
var gameIsStarted := false
var hero_demon_summoned := false
var swap_ability : Node
var current_level : Node
var hero_demon : Node
var ui_layers  := []
var wave_previews := []
var demon_costs: Dictionary = {}
var demon_scenes: Dictionary
var should_hide_ui := false
var demon_managers :Array= []
var all_registered_occulum : Array = []
var registered_lightning_balls : Array = []
var purple_lightning_ball : Area2D
var green_lightning_ball : Area2D

var registered_syn_shields : Array = []
var purple_syn_shield : Area2D
var green_syn_shield : Area2D

var registered_syn_abilities : Array = []
var purple_syn_ability : Area2D
var green_syn_ability : Area2D

@onready var sway_shader: VisualShader = preload("res://_Common/Shaders/swayShader.tres")


var column_death_explosion := preload("res://_Entities/Demons/_Wyrm/zombie_death_explosion.tscn")
var blood_scene := preload("res://_Entities/Demons/Blood/Blood.tscn")
var bomb_scene := preload("res://_Entities/Demons/Explosion/Bomb.tscn")
var consume_zombie_group_scene := preload("res://_Entities/Demons/_Maw/maw_consume.tscn")
var silence_field := preload("res://_Entities/Zombies/silence_fx.tscn")
var severed_spriteframes := preload("res://_Entities/Zombies/_Severed/Severed.tres")


var reborn_icon := preload("res://_Entities/Zombies/Notif_Icons/BasicZombie.png")
var severed_icon := preload("res://_Entities/Zombies/Notif_Icons/ConeHeadZombie.png")
var unhallower_icon := preload("res://_Entities/Zombies/Notif_Icons/BucketHeadZombie.png")
var reanimator_icon := preload("res://_Entities/Zombies/Notif_Icons/SummonerZombie.png")
var wretch_icon := preload("res://_Entities/Zombies/Notif_Icons/BackUpDancer.png")
var sundered_icon := preload("res://_Entities/Zombies/Notif_Icons/PoleVaultZombie.png")
var erupter_icon := preload("res://_Entities/Zombies/Notif_Icons/TickerZombie.png")
var flesheater_icon := preload("res://_Entities/Zombies/Notif_Icons/FootBallZombie.png")
var amalgam_icon := preload("res://_Entities/Zombies/Notif_Icons/ScreenDoorZombie.png")

#var occulum_special_description := FileAccess.open("res://_Entities/Demons/SpecialDescriptions/occulum_special_description.txt", FileAccess.READ).get_as_text()
#var crawler_special_description := FileAccess.open("res://_Entities/Demons/SpecialDescriptions/crawler_special_description.txt", FileAccess.READ).get_as_text()
#var wyrm_special_description := FileAccess.open("res://_Entities/Demons/SpecialDescriptions/wyrm_special_description.txt", FileAccess.READ).get_as_text()
#var spinal_occulum_special_description := FileAccess.open("res://_Entities/Demons/SpecialDescriptions/spinal_occulum_special_description.txt", FileAccess.READ).get_as_text()
#var hive_special_description := FileAccess.open("res://_Entities/Demons/SpecialDescriptions/hive_special_description.txt", FileAccess.READ).get_as_text()
#var maw_special_description := FileAccess.open("res://_Entities/Demons/SpecialDescriptions/maw_special_description.txt", FileAccess.READ).get_as_text()
var occulum_special_description := ""#FileAccess.open("res://_Entities/Demons/SpecialDescriptions/occulum_special_description.txt", FileAccess.READ).get_as_text()
var crawler_special_description :=""# FileAccess.open("res://_Entities/Demons/SpecialDescriptions/crawler_special_description.txt", FileAccess.READ).get_as_text()
var wyrm_special_description :=""# FileAccess.open("res://_Entities/Demons/SpecialDescriptions/wyrm_special_description.txt", FileAccess.READ).get_as_text()
var spinal_occulum_special_description := ""#FileAccess.open("res://_Entities/Demons/SpecialDescriptions/spinal_occulum_special_description.txt", FileAccess.READ).get_as_text()
var hive_special_description :=""# FileAccess.open("res://_Entities/Demons/SpecialDescriptions/hive_special_description.txt", FileAccess.READ).get_as_text()
var maw_special_description := ""#FileAccess.open("res://_Entities/Demons/SpecialDescriptions/maw_special_description.txt", FileAccess.READ).get_as_text()

var occulum_icon := preload("res://_Assets/Sprites/Occulum.png")
var crawler_icon := preload("res://_Assets/Sprites/Crawler.png")
var wyrm_icon := preload("res://_Assets/Sprites/Wyrm.png")
var spinal_occulum_icon := preload("res://_Assets/Sprites/SpinalOcculum.png")
var hive_icon := preload("res://_Assets/Sprites/Hive.png")
var maw_icon := preload("res://_Assets/Sprites/MawImage.png")

var syn_ability_manager_scene := preload("res://_Entities/SynAbility/syn_ability.tscn")

var syn_ability_manager

var portal_progress_bar : ProgressBar

var portal_progress_bar_1 : ProgressBar 

@onready var blood_rain_icon := preload("res://_Entities/SwapAbilities/Blood_Rain_Swap_Card.png")
@onready var lucretia_grasp_icon := preload("res://_Entities/SwapAbilities/Lucretia_Grasp_Swap_Card.png")
@onready var lightning_storm_icon :=  preload("res://_Entities/SwapAbilities/Lightning_Storm_Swap_Card.png")
@onready var baal_gaze_icon :=  preload("res://_Entities/SwapAbilities/Baal_Gaze_Swap_Card.png")

@onready var lightning_strike_button_icon :=  preload("res://_Entities/SynAbility/SynAbility_1_CARD.png")
@onready var shield_button_icon :=  preload("res://_Entities/SynAbility/SynShieldCard.png")
@onready var blood_ice_button_icon :=  preload("res://_Entities/SynAbility/BloodIceSpike_Card.png")
@onready var death_mark_button_icon :=  preload("res://_Entities/SynAbility/MarkedForDeath_CARD.png")
@onready var shroomie_button_icon := preload("res://_Entities/SynAbility/TorchShroomie_Card.png")

@onready var blood_rain := preload("res://_Entities/SwapAbilities/blood_rain_swap_ability.tscn")
@onready var lucretia_grasp := preload("res://_Entities/SwapAbilities/lucretia_grasp_swap_ability.tscn")
@onready var lightning_storm := preload("res://_Entities/SwapAbilities/lightning_storm_swap_ability.tscn")
@onready var baal_gaze := preload("res://_Entities/SwapAbilities/gaze_of_baal_swap_ability.tscn")

@onready var lightning_strike := preload("res://_Entities/SynAbility/syn_lightning_ability_bolt.tscn")
@onready var syn_shield := preload("res://_Entities/SynAbility/syn_shield_ability.tscn")
@onready var blood_ice := preload("res://_Entities/SynAbility/syn_ice_ability.tscn")
@onready var death_mark := preload("res://_Entities/SynAbility/syn_ability_mark.tscn")
@onready var shroomie := preload("res://_Entities/SynAbility/syn_torch_ability.tscn")

signal demon_buff_unlocked(synergy_unlocked : String) 

var crawler_occulum_synergy  := "CrawlerOcculum" 
var spinal_occulum_occulum_synergy := "SpinalocculumOcculum" 
var wyrm_occulum_synergy := "WyrmOcculum" 
var hive_occulum_synergy := "HiveOcculum" 
var maw_occulum_synergy := "MawOcculum" 

var is_crawler_occulum  := false 
var is_spinal_occulum_occulum := false 
var is_wyrm_occulum := false 
var is_hive_occulum := false 
var is_maw_occulum := false 


var crawler_wyrm_synergy := "CrawlerWyrm"
var occulum_wyrm_synergy := "OcculumWyrm"
var spinal_occulum_wyrm_synergy := "SpinalocculumWyrm"
var hive_wyrm_synergy := "HiveWyrm"
var maw_wyrm_synergy := "MawWyrm"

var is_crawler_wyrm  := false 
var is_occulum_wyrm := false 
var is_spinal_occulum_wyrm := false 
var is_hive_wyrm := false 
var is_maw_wyrm := false 


var crawler_spinal_occulum_synergy := "CrawlerSpinalocculum"
var occulum_spinal_occulum_synergy := "OcculumSpinalocculum"
var wyrm_spinal_occulum_synergy := "WyrmSpinalocculum"
var maw_spinal_occulum_synergy := "MawSpinalocculum"
var hive_spinal_occulum_synergy := "HiveSpinalocculum"

var is_crawler_spinal_occulum  := false 
var is_occulum_spinal_occulum := false 
var is_wyrm_spinal_occulum_synergy := false 
var is_maw_spinal_occulum_synergy := false 
var is_hive_spinal_occulum_synergy := false 



var occulum_crawler_synergy := "OcculumCrawler"
var spinal_occulum_crawler_synergy := "SpinalocculumCrawler"
var wyrm_crawler_synergy := "WyrmCrawler"
var maw_crawler_synergy := "MawCrawler"
var hive_crawler_synergy := "HiveCrawler"

var is_occulum_crawler  := false 
var is_spinal_occulum_crawler := false 
var is_wyrm_crawler := false 
var is_maw_crawler := false 
var is_hive_crawler := false 



var maw_hive_synergy := "MawHive"
var crawler_hive_synergy := "CrawlerHive"
var wyrm_hive_synergy := "WyrmHive"
var occulum_hive_synergy := "OcculumHive"
var spinal_occulum_hive_synergy := "SpinalocculumHive"

var is_maw_hive  := false 
var is_crawler_hive := false 
var is_wyrm_hive := false 
var is_occulum_hive := false 
var is_spinal_occulum_hive := false 



var crawler_maw_synergy := "CrawlerMaw"
var spinal_occulum_maw_synergy := "SpinalocculumMaw"
var hive_maw_synergy := "HiveMaw"
var wyrm_maw_synergy := "WyrmMaw"
var occulum_maw_synergy := "OcculumMaw"

var is_crawler_maw  := false 
var is_spinal_occulum_maw := false 
var is_hive_maw := false 
var is_wyrm_maw := false 
var is_occulum_maw := false 

var all_demon_synergies : Array = [crawler_occulum_synergy,spinal_occulum_occulum_synergy, wyrm_occulum_synergy, 
	hive_occulum_synergy,maw_occulum_synergy,crawler_wyrm_synergy,occulum_wyrm_synergy,spinal_occulum_wyrm_synergy,
	hive_wyrm_synergy, maw_wyrm_synergy, crawler_spinal_occulum_synergy , occulum_spinal_occulum_synergy, 
	wyrm_spinal_occulum_synergy, maw_spinal_occulum_synergy, hive_spinal_occulum_synergy, occulum_crawler_synergy,
	spinal_occulum_crawler_synergy, wyrm_crawler_synergy,maw_crawler_synergy, hive_crawler_synergy, maw_hive_synergy,
	crawler_hive_synergy, wyrm_hive_synergy, occulum_hive_synergy, spinal_occulum_hive_synergy, crawler_maw_synergy,
	spinal_occulum_maw_synergy, hive_maw_synergy, wyrm_maw_synergy, occulum_maw_synergy]

var unlocked_demon_synergies_dict : Dictionary = \
	{crawler_occulum_synergy : is_crawler_occulum, spinal_occulum_occulum_synergy : is_spinal_occulum_occulum, 
	wyrm_occulum_synergy : is_wyrm_occulum, hive_occulum_synergy : is_hive_occulum , maw_occulum_synergy : is_maw_occulum,
	crawler_wyrm_synergy : is_crawler_wyrm, occulum_wyrm_synergy : is_occulum_wyrm, spinal_occulum_wyrm_synergy : is_spinal_occulum_wyrm,
	hive_wyrm_synergy : is_hive_wyrm, maw_wyrm_synergy : is_maw_wyrm , crawler_spinal_occulum_synergy : is_crawler_spinal_occulum,
	occulum_spinal_occulum_synergy : is_occulum_spinal_occulum ,wyrm_spinal_occulum_synergy : is_wyrm_spinal_occulum_synergy,
	maw_spinal_occulum_synergy : is_maw_spinal_occulum_synergy,hive_spinal_occulum_synergy : is_hive_spinal_occulum_synergy,
	occulum_crawler_synergy :is_occulum_crawler,spinal_occulum_crawler_synergy:is_spinal_occulum_crawler,wyrm_crawler_synergy : is_wyrm_crawler,
	maw_crawler_synergy : is_maw_crawler, hive_crawler_synergy : is_hive_crawler,maw_hive_synergy : is_maw_hive, 
	crawler_hive_synergy :is_crawler_hive,wyrm_hive_synergy:is_wyrm_hive,occulum_hive_synergy:is_occulum_hive,
	spinal_occulum_hive_synergy: is_spinal_occulum_hive,crawler_maw_synergy: is_crawler_maw,spinal_occulum_maw_synergy : is_spinal_occulum_maw,
	hive_maw_synergy :is_hive_maw, wyrm_maw_synergy : is_wyrm_maw, occulum_maw_synergy :  is_occulum_maw  }

# Thickness of the highlight border (in pixels)
@export var highlight_border_thickness: int = 1

# Color of the highlight border
@export var highlight_border_color: Color = Color.RED


var current_synergies : Array 

var demon_codex : Control 
var should_navigate_demon_codex : bool 

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	var zombies := all_zombies.duplicate()
	for zombie in zombies:
		if zombie != null:
			zombie.tick(delta)

func reset_all_variables()->void:
	gameIsStarted = false
	reset_swap_ability()
	resetOcculumCount()
	reset_demon_managers()
	reset_all_zombies()

func _load_demon_costs() -> void:
	demon_scenes = {
		"Occulum": "res://_Entities/Demons/_Occulum/Occulum.tscn",
		"Crawler": "res://_Entities/Demons/_Crawler/Crawler.tscn",
		"SpinalOcculum": "res://_Entities/Demons/_CagedOculum/SpinalOcculum.tscn",
		"Wyrm": "res://_Entities/Demons/_Wyrm/Wyrm.tscn",
		"Maw": "res://_Entities/Demons/_Maw/Maw.tscn",
		"Hive": "res://_Entities/Demons/_Hive/Hive.tscn",
	}
	for demon_name : String in demon_scenes:
		var scene: PackedScene = load(demon_scenes[demon_name])
		var instance: Node = scene.instantiate()
		demon_costs[demon_name] = instance.cost  # each demon script has an @export var cost: int
		instance.queue_free()


func free_portals()->void:
	purple_portal.queue_free()
	green_portal.queue_free()
	portal_progress_bar.recharge()
	portal_progress_bar_1.recharge()


func get_demon_cost(demon_name: String) -> int:
	if demon_costs == null:
		return -1
	if demon_costs.size() < 1:
		_load_demon_costs()
	return demon_costs.get(demon_name, -1)
	
func is_on_purple_scene()->bool:
	return game_controller.on_purple_scene()
		
func get_current_scene_filepath() -> String:
	return game_controller.get_current_scene_filepath()

func register_wave_manager(new_wavemanager : Node) -> void:
	wave_manager = new_wavemanager

func get_wave_manager()->Node:
	return wave_manager

func lose_game()->void:
	wave_manager._lose()

func register_ui_layer(new_ui_layer:Control) -> void:
	ui_layers.append(new_ui_layer)
	#ui_layer.set_health(DemonMan)

func get_blood_panel()->Control:
	for this_ui_layer in ui_layers:
		if this_ui_layer != null:
			if !this_ui_layer.make_green:
				#print("Will Return ", this_ui_layer)
				return this_ui_layer.get_blood_panel()
	#print("Return Null L")
	return null

func get_health_panel()->Control:
	for this_ui_layer in ui_layers:
		if this_ui_layer != null:
			if !this_ui_layer.make_green:
				#print("Will Return ", this_ui_layer)
				return this_ui_layer.get_health_panel()
	#print("Return Null L")
	return null

func register_wave_preview(new_wave_preview:Node) -> void:
	wave_previews.append(new_wave_preview)
	pass

func add_blood_from_wave(blood_to_add:int)->void:
	for demon_manager in demon_managers:
		if demon_manager != null:
			demon_manager.add_blood(blood_to_add)	

func register_demon_selection_menu(new_demon_selection_menu)->void:
	var temp_menu_holder :Array = []
	for menu in demon_selection_menus:
		if menu != null && is_instance_valid(menu):
			temp_menu_holder.append(menu)
			
	demon_selection_menus = temp_menu_holder
	demon_selection_menus.append(new_demon_selection_menu)

func hideDemonSelectionMenu() -> void:
	for menu in demon_selection_menus:
		if menu != null:
			menu.visible = false 
			
	#if demon_selection_menu != null:
		#demon_selection_menu.visible = false

func unHideDemonSelectionMenu() -> void:
	var on_purple = true 
	if game_controller.on_purple_scene():
		on_purple = true 
	else:
		on_purple = false 

	for menu in demon_selection_menus:
		if menu != null:
			menu.set_pause_process_mode()
			if on_purple:
				if !menu.is_alt:
					menu.visible = true 
			elif !on_purple:
				if menu.is_alt:
					menu.visible = true 
						 
	#if demon_selection_menu != null:
		#demon_selection_menu.visible = true
	
		
func swap_portal_button() -> void:
	#TODO
	pass
	#demon_selection_menu.swap_portal_button()

func register_demon_managers(new_demon_manager:DemonManager)->void:
	demon_managers.append(new_demon_manager)

func reset_demon_managers()->void:
	var demon_managers_temp : Array = []
	for demon_manager in demon_managers:
		if demon_manager == null:
			pass
		else:
			demon_managers_temp.append(demon_manager)
	demon_managers.clear()
	demon_managers = demon_managers_temp
	
func register_syn_ability_instance(new_syn_ability : Area2D)->void:
	
	if new_syn_ability.is_in_group("Purple"):
		if purple_syn_ability == null:
			registered_syn_abilities.append(new_syn_ability)
		purple_syn_ability = new_syn_ability
		
	else: 
		if green_syn_ability == null:
			registered_syn_abilities.append(new_syn_ability)
		green_syn_ability = new_syn_ability
		
	if registered_syn_abilities.size() >= 2 :
		connect_syn_abilities()
	else:
		print(registered_syn_abilities, " Cannot connect not enough syn sheilds : ",registered_syn_abilities.size() )	
		
func connect_syn_abilities()->void:
	print("Should Start connect Syn Abilities")
	if green_syn_ability != null && purple_syn_ability != null:
		if green_syn_ability.is_dual_connection:
			green_syn_ability.connect_ability(purple_syn_ability)
			purple_syn_ability.connect_ability(green_syn_ability)
		else:
			if green_syn_ability.global_position.x > purple_syn_ability.global_position.x:
				green_syn_ability.connect_ability(purple_syn_ability)
			else:
				purple_syn_ability.connect_ability(green_syn_ability)

func deregister_syn_ability(new_syn_ability:Area2D)->void:
	registered_syn_abilities.erase(new_syn_ability)
	syn_ability_manager.deregister_ability_instance(new_syn_ability)
	if new_syn_ability.is_in_group("Purple"):
		purple_syn_ability = null
	else:
		green_syn_ability = null
	print(registered_syn_abilities, " now has size syn abilitys : ",registered_syn_abilities.size() )		
		
		
		
		
func register_syn_shield(new_shield:Area2D)->void:
	if new_shield.is_in_group("Purple"):
		if purple_syn_shield == null:
			registered_syn_shields.append(new_shield)
		purple_syn_shield = new_shield
		
	else: 
		if green_syn_shield == null:
			registered_syn_shields.append(new_shield)
		green_syn_shield = new_shield
		
	if registered_syn_shields.size() >= 2:
		connect_syn_shields()
	else:
		print(registered_syn_shields, " Cannot connect not enough syn sheilds : ",registered_syn_shields.size() )




func connect_syn_shields()->void:
	print("Should Start connect shields s")
	if green_syn_shield.global_position.x > purple_syn_shield.global_position.x:
		green_syn_shield.connect_shield(purple_syn_shield)
	else:
		purple_syn_shield.connect_shield(green_syn_shield)

func deregister_syn_shield(new_shield:Area2D)->void:
	registered_syn_shields.erase(new_shield)
	if new_shield.is_in_group("Purple"):
		purple_syn_shield = null
	else:
		green_syn_shield = null
	print(registered_syn_shields, " now has size syn shields : ",registered_syn_shields.size() )
		
func register_lightning_ball(new_lightning_ball:Area2D)->void:
	
	if new_lightning_ball.is_in_group("Purple"):
		if purple_lightning_ball == null:
			registered_lightning_balls.append(new_lightning_ball)
		purple_lightning_ball = new_lightning_ball
		
	else: 
		if green_lightning_ball == null:
			registered_lightning_balls.append(new_lightning_ball)
		green_lightning_ball = new_lightning_ball
		
	if registered_lightning_balls.size() >= 2:
		connect_lightning_balls()
	else:
		print(registered_lightning_balls, " Cannot connect not enough balls : ",registered_lightning_balls.size() )
		
func connect_lightning_balls()->void:
	green_lightning_ball.connect_lightning(purple_lightning_ball)
	purple_lightning_ball.connect_lightning(green_lightning_ball)

func deregister_lightning_ball(new_lightning_ball:Area2D)->void:
	registered_lightning_balls.erase(new_lightning_ball)
	if new_lightning_ball.is_in_group("Purple"):
		purple_lightning_ball = null
	else:
		green_lightning_ball = null
	print(registered_lightning_balls, " now has size lightning balls : ",registered_lightning_balls.size() )
	


	
func resetOcculumCount() -> void:
	is_blocking = false
	occulumCount = 0
	green_occulum_count = 0
	purple_occulum_count = 0
	all_registered_occulum.clear()
	#game_controller.on_scene_1 = true 
	
	
func incrementOcculumCount() -> void:
	if game_controller.on_purple_scene():
		purple_occulum_count += 1
		for menu in demon_selection_menus:
			if menu != null:
				if !menu.is_alt:
					menu.increaseOcculumCost() 
	else: #Green
		green_occulum_count += 1
		for menu in demon_selection_menus:
			if menu != null:
				if menu.is_alt:
					menu.increaseOcculumCost() 
				
	#occulumCount += 1
	#for menu in demon_selection_menus:
		#if menu != null:
			#menu.increaseOcculumCost() 
	##demon_selection_menu.increaseOcculumCost()



	
func incrementOcculumCountVisual() -> void:
	occulumCountVisual += 1
	
func getOcculumCount() -> int:
	#print("SSReturn , ", occulumCount)
	if game_controller.on_purple_scene():
		return purple_occulum_count
	else:
		return green_occulum_count
	#return occulumCount

func damage_all_zombies_with_link(damage : float, zombie_to_exclude : Zombie)->void:
	print("Checking Link DMG on ", all_zombies)
	for zombie in all_zombies:
		if zombie.is_flame_dmg_linked && zombie != zombie_to_exclude:
			print("Calling Link Damage on ", zombie)
			zombie.take_damage(true,damage,false)
	pass
	


func getOcculumCountVisual() -> int:
	return occulumCountVisual
	
func setCanPlayLevel2() -> void:
	canPlayLevel2 = true

func getCanPlayLevel2() -> bool:
	return canPlayLevel2


func setCanPlayLevel3() -> void:
	canPlayLevel3 = true

func getCanPlayLevel3() -> bool:
	return canPlayLevel3


func setCanPlayLevel4() -> void:
	canPlayLevel4 = true

func getCanPlayLevel4() -> bool:
	return canPlayLevel4


func setCanPlayLevel5() -> void:
	canPlayLevel5 = true

func getCanPlayLevel5() -> bool:
	return canPlayLevel5


func setCanPlayLevel6() -> void:
	canPlayLevel6 = true

func getCanPlayLevel6() -> bool:
	return canPlayLevel6


func setCanPlayLevel7() -> void:
	canPlayLevel7 = true

func getCanPlayLevel7() -> bool:
	return canPlayLevel7

func unlockLevel(levelUnlocked : int) -> void:
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
	
func start_wave_1() -> void:
	if current_level != null:
		current_level.wave_1_active = true	
		#print("Current Level is ", current_level, " wave 1 active is ", current_level.wave_1_active)
	else:
		pass
		#print("Current Level is Null")
	
func show_guide() -> void:
#	print("UNDO THE CLEAR AND SHOW THE GUIDE FROM GLOBAL")
	game_controller.show_guide()	
	
func clear_guide() -> void:
	#print("CLEAR THE GUIDE GAMECONTROLLER")
	game_controller.clear_guide()		
	
func get_game_controller() -> GameController:
	return game_controller
	
func register_green_portal(new_green_portal : Node) -> void:
	green_portal = new_green_portal
	if purple_portal == null:
		green_portal.add_to_group("EntrancePortal")
	else:
		purple_portal.start_cooldown()
		green_portal.start_cooldown()
	
func register_portal_progess_bar(new_progress_bar : ProgressBar)->void:
	if portal_progress_bar_1 == null:
		portal_progress_bar_1 = new_progress_bar
	else:
		portal_progress_bar = new_progress_bar

func get_portal_progress_bar(requesting_portal : Area2D)->ProgressBar:
	if requesting_portal.is_in_group("Green"):
		return portal_progress_bar
	else:
		return portal_progress_bar_1

func register_purple_portal(new_purple_portal : Node) -> void:
	purple_portal = new_purple_portal
	if green_portal == null:
		purple_portal.add_to_group("EntrancePortal")
	else:
		purple_portal.start_cooldown()
		green_portal.start_cooldown()
	
func get_purple_portal_location() -> Vector2:
	if purple_portal == null:
		return Vector2.ONE
	return purple_portal.global_position

func get_green_portal_location() -> Vector2:
	if green_portal == null:
		return Vector2.ONE
	return green_portal.global_position
	
func register_demon(new_demon : Demon)->void:
	all_demons.append(new_demon)

func get_all_demons()->Array:
	return all_demons 
		
		
func register_hero_demon(new_hero_demon : Demon) -> void:
	hero_demon = new_hero_demon
	hero_demon_summoned = true
	for demon_manager in demon_managers:
		if demon_manager != null:
			demon_manager.hero_demon = new_hero_demon

func hero_demon_is_summoned() -> bool:
	return hero_demon_summoned

func swap_scenes() -> void:
	#print("SWAP SCENES SHOULD")
	game_controller.swap_scenes()
	adjust_ui_layer()					
	swap_portal_button()
	swap_hero_demon()
	#demon_manager.swap_heart()

func swap_hero_demon()->void:
	pass
	print("Swap Hero Demon")
	if hero_demon != null:
		if hero_demon.is_in_group("Purple"):
			print("Hero Was Purple")
			hero_demon.add_to_group("Green")
			hero_demon.remove_from_group("Purple")
			if hero_demon.is_in_group("Purple"):
				print("Hero Still Purple Lmao")
			hero_demon.reparent(game_controller.get_active_dimension().game_layer)
			hero_demon.swap_scenes()
		else:
			print("Hero Was Green")
			hero_demon.add_to_group("Purple")
			hero_demon.remove_from_group("Green")
			hero_demon.reparent(game_controller.get_active_dimension().game_layer)
			hero_demon.swap_scenes()
	

func unhide_ui_layer() -> void:
	should_hide_ui = false
	var real_ui_layers := []
		
	for item in ui_layers:
		if item == null:
			pass
		else:
			real_ui_layers.append(item)
	for this_ui_layer:Control in real_ui_layers:		
		this_ui_layer.show()
	adjust_ui_layer()

func hide_ui_layer() -> void:
	should_hide_ui = true
	var real_ui_layers := []
		
	for item  in ui_layers:
		if item == null:
			pass
		else:
			real_ui_layers.append(item)
	for this_ui_layer  in real_ui_layers:		
		#print("Should Hide Ui Layer ", this_ui_layer)
		this_ui_layer.hide()
		
		
#And Wave Preview
func adjust_ui_layer() -> void:
	if !should_hide_ui:
		var real_ui_layers := []
		var real_wave_previews := []
		
		for item in ui_layers:
			if item == null:
				pass
			else:
				real_ui_layers.append(item)

		for preview_item in wave_previews:
			if preview_item == null:
				pass
			else:
				real_wave_previews.append(preview_item)
				
		for this_ui_layer in real_ui_layers:
		#	print("SHOULD CHECKING UI LAYER ", this_ui_layer)
			if game_controller.on_purple_scene():
			#	print("ON PURPLE SCENE SHOULD HIDE GREEN")
				if this_ui_layer.make_green == true :
					this_ui_layer.hide()
				else:
					this_ui_layer.show()
			else:
			#	print("ON GREEN SCENE SHOULD HIDE PURPLE")
				if this_ui_layer.make_green == true :
					this_ui_layer.show()
				else:
					this_ui_layer.hide()
					
		for this_preview in real_wave_previews:
		#	print("SHOULD CHECKING PREVIEW ", this_preview)
			if game_controller.on_purple_scene():
				#print("ON PURPLE SCENE SHOULD HIDE GREEN PREVIEW")
				if this_preview.is_green == true :
					this_preview.hide()
				else:
					this_preview.show()
			else:
				#print("ON GREEN SCENE SHOULD HIDE PURPLE PREVIEW")
				if this_preview.is_green == true :
					this_preview.show()
				else:
					this_preview.hide()
		
	
	
func is_on_purple_dimension() -> bool:
	if game_controller.on_scene_1:
		return true
	else:
		return false

func register_syn_ability_manager(new_syn_ability_manager)->void:
	syn_ability_manager = new_syn_ability_manager
	
func register_swap_ability(new_swap_ability ) -> void:
	if swap_ability != null:
		swap_ability.queue_free()
	swap_ability = new_swap_ability.instantiate()
	game_controller.add_child(swap_ability)
func register_syn_ability(new_syn_ability)->void:
	if syn_ability_manager == null:
		syn_ability_manager = syn_ability_manager_scene.instantiate()
		game_controller.add_child(syn_ability_manager)
	syn_ability_manager.set_syn_ability(new_syn_ability)
	var temp_syn_holder = new_syn_ability.instantiate()
	
	syn_ability_manager.set_icon(temp_syn_holder.get_icon())
	temp_syn_holder.queue_free()
	#register_syn_ability_instance(new_syn_ability.instantiate())

func register_swap_ability_instance(new_swap_ability ) -> void:
	swap_ability = new_swap_ability

func get_swap_ability_panel()->PanelContainer:
	return swap_ability.get_panel_container()

func register_notification_bar(new_notification_bar : Control) -> void:
	notification_bar = new_notification_bar

func get_swap_icon()->Texture:
	if swap_ability != null:
		return swap_ability.get_icon()
	else:
		return blood_rain_icon
	
func get_syn_icon()->Texture:
	if swap_ability != null:
		return syn_ability_manager.get_icon()
	else:
		return lightning_storm_icon	

func get_syn_button()->Control:
	return syn_ability_manager.get_syn_button()

func start_swap_ability() -> void:
	if swap_ability != null:
		swap_ability.begin()


func stop_swap_ability() -> void:
	if swap_ability != null:
		swap_ability.stop()

func reset_swap_ability() -> void:
	if swap_ability != null:
		swap_ability.reset_on_game_start()
	
func register_zombie(new_zombie : Zombie) -> void:
	all_zombies.append(new_zombie)
	if swap_ability != null:
		swap_ability.append_new_zombie(new_zombie)
	
	
func deregister_zombie(zombie_to_delete : Zombie) -> void:
	all_zombies.erase(zombie_to_delete)
	
func get_all_zombies() -> Array:
	return all_zombies

func reset_all_zombies()->void:
	all_zombies.clear()
	
func set_zombie_info_bar(zombie : Zombie) -> void:
	#print(" notification_bar" , notification_bar)
	notification_bar.set_zombie_info(zombie)
	pass

func set_demon_info_bar(demon : Demon) -> void:
	notification_bar.set_demon_info(demon)
	game_controller.get_active_dimension().demon_clicked()
	pass
	
	
func set_dialog_disabled()->void:
	pass
	
	
	
func get_column_death_explosion() -> PackedScene:
	return column_death_explosion
		
func hide_notification_bar() -> void:
	if notification_bar != null:
		notification_bar.hide()
	
func get_blood_scene() -> PackedScene:
	return blood_scene

func get_bomb_scene() -> PackedScene:
	return bomb_scene
	
func get_consume_zombie_group_scene() -> PackedScene:
	return consume_zombie_group_scene

func get_silence_field() -> PackedScene :
	return silence_field
	
func get_severed_spriteframes()-> SpriteFrames:
	return severed_spriteframes
	
func hide_pip() -> void:
	print("Should hide ", game_controller.pip)
	game_controller.pip.hide()
	game_controller.pip.hide_pip()
	
func show_pip() -> void:
	game_controller.pip.show()

func make_pip_glow()->void:
	add_pulsing_button_highlight(game_controller.pip.get_pip_panel())

func stop_pip_glow()->void:
	remove_pulsing_button_highlight(game_controller.pip.get_pip_panel())
	
func start_game()->void:
	if swap_ability != null:
		swap_ability.game_start()
	for occulum in all_registered_occulum:
		occulum.start_blood_timer()
	pass
	
func register_occulum(new_occulum:Demon)->void:
	all_registered_occulum.append(new_occulum)

func get_current_ui_layer()->Control:
	var on_purple :bool= game_controller.on_purple_scene()
	for ui_layer in ui_layers:
		if on_purple && ui_layer.make_green == false:
			return ui_layer
		if !on_purple && ui_layer.make_green == true:
			return ui_layer
	return null
			
	

func unlock_buff(unlocked_buff : String)->void:
	for synergy : String in all_demon_synergies:
		if synergy == unlocked_buff:
			print("this synergy ", synergy , " is A MATCH")
			if unlocked_demon_synergies_dict[synergy] == false:
				unlocked_demon_synergies_dict[synergy] = true
				get_current_ui_layer().set_unlock_notif(synergy)
			
func navigate_to_buff(new_synergy:String)->void:
	current_synergies = split_capitals(new_synergy)
	game_controller.change_scene_with_pause("res://_UI/LoreBooks/demon_lore_book.tscn")
	should_navigate_demon_codex = true 
	
func register_demon_codex(new_demon_codex : Control)->void:
	demon_codex = new_demon_codex
	await demon_codex.ready
	if should_navigate_demon_codex:
		should_navigate_demon_codex = false
		continue_navigate_to_buff(current_synergies)
	
func continue_navigate_to_buff(current_synergies : Array)->void:
	var demon_a :String= current_synergies[0]
	var demon_b :String= current_synergies[1]
	print("Demon A Is ", demon_a)
	print("Demon B is ", demon_b)

	match demon_b:
		"Crawler":
			demon_codex._on_crawler_pressed()
			await get_tree().physics_frame
			await get_tree().physics_frame
			finish_navigate_to_buff_crawler(demon_a)
		"Occulum":
			demon_codex._on_occulum_pressed()
			await get_tree().physics_frame
			await get_tree().physics_frame
			finish_navigate_to_buff_occulum(demon_a)
		"Hive":
			demon_codex._on_hive_pressed()
			await get_tree().physics_frame
			await get_tree().physics_frame
			finish_navigate_to_buff_hive(demon_a)
		"Spinalocculum":
			demon_codex._on_spinalOcculum_pressed()
			await get_tree().physics_frame
			await get_tree().physics_frame
			finish_navigate_to_buff_spinal_occulum(demon_a)
		"Maw":
			demon_codex._on_maw_pressed()
			await get_tree().physics_frame
			await get_tree().physics_frame
			finish_navigate_to_buff_maw(demon_a)
		"Wyrm":
			demon_codex._on_wrym_pressed()
			await get_tree().physics_frame
			await get_tree().physics_frame
			finish_navigate_to_buff_wyrm(demon_a)
	
func finish_navigate_to_buff_occulum(demon_a:String)->void:
	match demon_a:
		"Crawler":
			demon_codex._on_alt_4_pressed()
		"Occulum":
			pass
		"Hive":
			demon_codex._on_alt_3_pressed()
		"Spinalocculum":
			demon_codex._on_alt_5_pressed()
		"Maw":
			demon_codex._on_alt_2_pressed()
		"Wyrm":
			demon_codex._on_alt_6_pressed()	

func finish_navigate_to_buff_crawler(demon_a:String)->void:
	match demon_a:
		"Crawler":
			pass
		"Occulum":
			demon_codex._on_alt_4_pressed()
		"Hive":
			demon_codex._on_alt_2_pressed()
		"Spinalocculum":
			demon_codex._on_alt_5_pressed()
		"Maw":
			demon_codex._on_alt_3_pressed()
		"Wyrm":
			demon_codex._on_alt_6_pressed()	
			
func finish_navigate_to_buff_spinal_occulum(demon_a:String)->void:
	match demon_a:
		"Crawler":
			demon_codex._on_alt_5_pressed()
		"Occulum":
			demon_codex._on_alt_2_pressed()
		"Hive":
			demon_codex._on_alt_3_pressed()
		"Spinalocculum":
			pass
		"Maw":
			demon_codex._on_alt_4_pressed()
		"Wyrm":
			demon_codex._on_alt_6_pressed()	
			
func finish_navigate_to_buff_wyrm(demon_a:String)->void:
	print("Demon A is still, ", demon_a)
	match demon_a:
		"Crawler":
			demon_codex._on_alt_5_pressed()
		"Occulum":
			demon_codex._on_alt_2_pressed()
		"Hive":
			demon_codex._on_alt_3_pressed()
		"Spinalocculum":
			demon_codex._on_alt_6_pressed()
		"Maw":
			demon_codex._on_alt_4_pressed()
		"Wyrm":
			pass
			
func finish_navigate_to_buff_hive(demon_a:String)->void:
	match demon_a:
		"Crawler":
			demon_codex._on_alt_3_pressed()
		"Occulum":
			demon_codex._on_alt_4_pressed()
		"Hive":
			pass
		"Spinalocculum":
			demon_codex._on_alt_5_pressed()
		"Maw":
			demon_codex._on_alt_2_pressed()
		"Wyrm":
			demon_codex._on_alt_6_pressed()	
			
			
func finish_navigate_to_buff_maw(demon_a:String)->void:
	match demon_a:
		"Crawler":
			demon_codex._on_alt_3_pressed()
		"Occulum":
			demon_codex._on_alt_4_pressed()
		"Hive":
			demon_codex._on_alt_2_pressed()
		"Spinalocculum":
			demon_codex._on_alt_5_pressed()
		"Maw":
			pass
		"Wyrm":
			demon_codex._on_alt_6_pressed()	
			

func split_capitals(s: String) -> Array:
	var result: Array = []
	var current: String = ""
	for c in s:
		if c == c.to_upper() and c != c.to_lower() and current != "":
			result.append(current)
			current = ""
		current += c
	if current != "":
		result.append(current)
	return result	
	
func add_pulsing_button_highlight(button, should_pulse : bool = true) -> void:
	if not button:
		push_error("Button node is null!")
		return
	#print("Button Global START Pos Is  : ", button.global_position)
	# Remove any existing highlight
	if button.has_meta("highlight_panel"):
		if is_instance_valid(button.get_meta("highlight_panel")):
			var old: Panel = button.get_meta("highlight_panel")
			if is_instance_valid(old):
				old.queue_free()

	# Create a Panel as a child to act as the border/glow
	var panel := Panel.new()
	#panel.scale = Vector2(0.8,0.8)
	panel.name = "HighlightPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't eat clicks
	

	button.add_child(panel)
	for child in button.get_children():
		#print(button, " children are ", child)
		pass


	# Expand slightly beyond the button to create a border effect
	var margin := highlight_border_thickness #+ 4
	#panel.position = Vector2(-margin, -margin)
	#panel.position = Vector2(0,0)
	panel.size = button.size #+ Vector2(margin * 2, margin * 2)
	#print(panel.size , " Glow Container Size is ", button.size)
	panel.z_index = 2

	# Build the stylebox for the panel
	var highlight_style := StyleBoxFlat.new()
	highlight_style.bg_color = Color.TRANSPARENT
	highlight_style.border_width_left = highlight_border_thickness
	highlight_style.border_width_right = highlight_border_thickness
	highlight_style.border_width_top = highlight_border_thickness
	highlight_style.border_width_bottom = highlight_border_thickness
	highlight_style.border_color = highlight_border_color
	highlight_style.shadow_color = Color(highlight_border_color, 0.5)
	highlight_style.shadow_size = 2
	highlight_style.shadow_offset = Vector2.ZERO
	highlight_style.corner_radius_top_left = 2
	highlight_style.corner_radius_top_right = 2
	highlight_style.corner_radius_bottom_left = 2
	highlight_style.corner_radius_bottom_right = 2

	panel.add_theme_stylebox_override("panel", highlight_style)
	button.set_meta("highlight_panel", panel)



	if should_pulse:
		start_glow_pulse(button, panel, highlight_style)


func start_glow_pulse(button, _panel: Panel, style: StyleBoxFlat, glow_color: Color = highlight_border_color) -> void:
	if button.has_meta("glow_tween"):
		var old_tween: Tween = button.get_meta("glow_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween = button.create_tween()
	tween.set_loops()

	tween.tween_method(
		func(val: int) -> void:
			style.shadow_size = int(lerpf(4, 8, val))
			style.shadow_color = Color(glow_color, lerpf(0.2, 0.4, val)),
		0.0, 1.0, 1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_method(
		func(val: int) -> void:
			style.shadow_size = int(lerpf(8, 4, val))
			style.shadow_color = Color(glow_color, lerpf(0.4, 0.2, val)),
		0.0, 1.0, 1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	button.set_meta("glow_tween", tween)
	
	
		
	
func stop_glow_pulse(button) -> void:
	#print("STOP PULSE")
	if button.has_meta("glow_tween"):
		var tween: Tween = button.get_meta("glow_tween")
		if tween and tween.is_valid():
			tween.kill()
		button.remove_meta("glow_tween")
	
	# Remove the highlight panel
	if button.has_meta("highlight_panel"):
		var panel: Panel = button.get_meta("highlight_panel")
		if is_instance_valid(panel):
			panel.queue_free()
		button.remove_meta("highlight_panel")
	if button.get_child(0) != null:
		if button.get_child(0).name == "HighlightPanel":
			print("Going to queue free button highlight : ", button.get_child(0))
			button.get_child(0).queue_free()
			pass
			
func remove_pulsing_button_highlight(button) -> void:
	if button.has_meta("glow_tween"):
		var tw: Tween = button.get_meta("glow_tween")
		if tw and tw.is_valid():
			tw.kill()
	if button.has_meta("highlight_panel"):
		if is_instance_valid(button.get_meta("highlight_panel")):
			var p: Panel = button.get_meta("highlight_panel")
			if is_instance_valid(p):
				p.queue_free()
				
				
