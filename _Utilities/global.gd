extends Node

#Tracks Which Levels Have Been Unlocked

var canPlayLevel2: bool = true
var canPlayLevel3: bool = true
var canPlayLevel4: bool = true
var canPlayLevel5: bool = true
var canPlayLevel6: bool = true
var canPlayLevel7: bool = true
var occulumCount := 0
var occulumCountVisual := 0
var wave_manager : Node
var is_blocking := false

var all_zombies := []
var all_demons := []
var game_controller: GameController
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

@onready var blood_rain_icon := preload("res://_Entities/SwapAbilities/Blood_Rain_Swap_Card.png")
@onready var lucretia_grasp_icon := preload("res://_Entities/SwapAbilities/Lucretia_Grasp_Swap_Card.png")
@onready var lightning_storm_icon :=  preload("res://_Entities/SwapAbilities/Lightning_Storm_Swap_Card.png")
@onready var baal_gaze_icon :=  preload("res://_Entities/SwapAbilities/Baal_Gaze_Swap_Card.png")

@onready var lightning_strike_button_icon :=  preload("res://_Entities/SynAbility/SynAbility_1_CARD.png")
@onready var shield_button_icon :=  preload("res://_Entities/SynAbility/SynShieldCard.png")
@onready var blood_ice_button_icon :=  preload("res://_Entities/SynAbility/BloodIceSpike_Card.png")
@onready var death_mark_button_icon :=  preload("res://_Entities/SynAbility/MarkedForDeath_CARD.png")
@onready var shroomie_button_icon := preload("res://_Entities/SynAbility/TorchShroomie_Card.png")



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

func get_demon_cost(demon_name: String) -> int:
	if demon_costs == null:
		return -1
	if demon_costs.size() < 1:
		_load_demon_costs()
	return demon_costs.get(demon_name, -1)
	
func get_current_scene_filepath() -> String:
	return game_controller.get_current_scene_filepath()

func register_wave_manager(new_wavemanager : Node) -> void:
	wave_manager = new_wavemanager

func get_wave_manager()->Node:
	return wave_manager

func register_ui_layer(new_ui_layer:Control) -> void:
	ui_layers.append(new_ui_layer)
	#ui_layer.set_health(DemonMan)

func register_wave_preview(new_wave_preview:Node) -> void:
	wave_previews.append(new_wave_preview)
	pass

func add_blood_from_wave(blood_to_add:int)->void:
	for demon_manager in demon_managers:
		if demon_manager != null:
			demon_manager.add_blood(blood_to_add)	

func hideDemonSelectionMenu() -> void:
	if demon_selection_menu != null:
		demon_selection_menu.visible = false

func unHideDemonSelectionMenu() -> void:
	if demon_selection_menu != null:
		demon_selection_menu.visible = true
		
func swap_portal_button() -> void:
	demon_selection_menu.swap_portal_button()

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
	all_registered_occulum.clear()
	#game_controller.on_scene_1 = true 
	
	
func incrementOcculumCount() -> void:
	occulumCount += 1
	demon_selection_menu.increaseOcculumCost()



	
func incrementOcculumCountVisual() -> void:
	occulumCountVisual += 1
	
func getOcculumCount() -> int:
	#print("SSReturn , ", occulumCount)
	return occulumCount

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
	if purple_portal == null:
		new_green_portal.add_to_group("EntrancePortal")
	green_portal = new_green_portal


func register_purple_portal(new_purple_portal : Node) -> void:
	if green_portal == null:
		new_purple_portal.add_to_group("EntrancePortal")
	purple_portal = new_purple_portal
	
func get_purple_portal_location() -> Vector2:
	return purple_portal.global_position

func get_green_portal_location() -> Vector2:
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
	
func start_game()->void:
	if swap_ability != null:
		swap_ability.game_start()
	for occulum in all_registered_occulum:
		occulum.start_blood_timer()
	pass
	
func register_occulum(new_occulum:Demon)->void:
	all_registered_occulum.append(new_occulum)
