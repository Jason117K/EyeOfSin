extends Node


enum DEMON_TYPE{
	CRAWLER,
	OCCULUM,
	SPINAL_OCCULUM,
	WYRM,
	HIVE,
	MAW
}

var canPlayLevel2: bool = true
var canPlayLevel3: bool = true
var canPlayLevel4: bool = true
var canPlayLevel5: bool = true
var canPlayLevel6: bool = true
var canPlayLevel7: bool = true

var crawler_unlocked := true
var occulum_unlocked := false
var spinal_occulum_unlocked := false
var wyrm_unlocked := false
var maw_unlocked := false
var hive_unlocked := false

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
var style_menu : Control
var game_controller: GameController
var demon_selection_menus : Array = []
var demon_selection_menu : Control
var notification_bar : Control 
var green_portal :Node = null
var purple_portal :Node= null
var gameIsStarted := false
var hero_demon_summoned := false
var ultimate_is_ready := false
var swap_ability : Node
var current_level : Node
#var hero_demon : Node
var current_hero_demon : Node 
var ui_layers  := []
var wave_previews := []
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

var num_cheap_occulum :int = 4 
var recovery_blood_value := 200 
var is_demon_hero_selected := false 

#region Preloaded scenes & icons (planned: move to catalogs in refactor Phase 5)
@onready var sway_shader: VisualShader = preload("res://_Common/Shaders/swayShader.tres")

var hero_demon := preload("res://_Entities/Demons/_Hero_Demon/hero_demon.tscn")

var demon_revive_point := preload("res://_Entities/Demons/demon_revive_point.tscn")

var column_death_explosion := preload("res://_Entities/Demons/_Wyrm/zombie_death_explosion.tscn")
var blood_scene := preload("res://_Entities/Demons/Blood/Blood.tscn")
var bomb_scene := preload("res://_Entities/Demons/Explosion/Bomb.tscn")
var consume_zombie_group_scene := preload("res://_Entities/Demons/_Maw/maw_consume.tscn")
var silence_field := preload("res://_Entities/Zombies/silence_fx.tscn")
var severed_spriteframes := preload("res://_Entities/Zombies/_Severed/Severed.tres")


var reborn_icon := preload("res://_Entities/Zombies/Notif_Icons/BasicZombie.png")
var severed_icon := preload("res://_Entities/Zombies/Notif_Icons/ConeHeadZombie.png")
var unhallower_icon := preload("res://_Entities/Zombies/_Unhallower/Unhallower.png")
var buffer_icon := preload("res://_Entities/Zombies/_BufferZombie/BufferZombie.png")
var reanimator_icon := preload("res://_Entities/Zombies/Notif_Icons/SummonerZombie.png")
var wretch_icon := preload("res://_Entities/Zombies/Notif_Icons/BackUpDancer.png")
var sundered_icon := preload("res://_Entities/Zombies/Notif_Icons/PoleVaultZombie.png")
var erupter_icon := preload("res://_Entities/Zombies/Notif_Icons/TickerZombie.png")
var flesheater_icon := preload("res://_Entities/Zombies/Notif_Icons/FootBallZombie.png")
var amalgam_icon := preload("res://_Entities/Zombies/Notif_Icons/ScreenDoorZombie.png")
var rohan_icon := preload("res://_Entities/Zombies/_RohanBossZombie/RohanZombie.png")

var all_zombie_notif_icons : Array = [reborn_icon,severed_icon,unhallower_icon,reanimator_icon,wretch_icon,
								sundered_icon,erupter_icon,flesheater_icon,amalgam_icon,]

var zombie_notif_icons : Dictionary = {"Reborn": reborn_icon, "Severed": severed_icon,"Unhallower": unhallower_icon,
										"Reanimator":reanimator_icon, "Wretch":wretch_icon,"Sundered":sundered_icon,
										"Erupter":erupter_icon,"Flesheater":flesheater_icon,"Amalgam":amalgam_icon,
										"Buffer":buffer_icon,"Rohan":rohan_icon}
										
@onready var all_crawler_synergies : Array = get_files_in_folder("res://_Assets/Text/TextFiles/Synergies/","Crawler")
@onready var all_occulum_synergies : Array = get_files_in_folder("res://_Assets/Text/TextFiles/Synergies/","Occulum")
@onready var all_spinalocculum_synergies : Array = get_files_in_folder("res://_Assets/Text/TextFiles/Synergies/","Spinal")
@onready var all_wyrm_synergies : Array = get_files_in_folder("res://_Assets/Text/TextFiles/Synergies/","Wyrm")
@onready var all_hive_synergies : Array = get_files_in_folder("res://_Assets/Text/TextFiles/Synergies/","Hive")
@onready var all_maw_synergies : Array = get_files_in_folder("res://_Assets/Text/TextFiles/Synergies/","Maw")
@onready var wyrm_queen_special_description = "res://_Assets/Text/TextFiles/WyrmQueen.txt"

# Demon identity/menu data (scene, icon, base cost, description) lives here.
# load(), NOT preload(): the catalog references the demon scenes, whose
# scripts (extends Demon) can't compile while Global itself is mid-compile —
# preload here is a compile-time cycle ("Could not resolve class Demon").
var demon_catalog : DemonCatalog = load("res://_Entities/Demons/Definitions/DemonCatalog.tres")

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
#endregion

signal demon_buff_unlocked(synergy_unlocked : String)

#region Synergy catalog (data) + unlock state
var synergy_catalog : SynergyCatalog = preload("res://_Entities/Demons/Synergies/SynergyCatalog.tres")
# Runtime unlock state, keyed by SynergyDefinition.id. Deliberately NOT reset
# per level: unlocks persist for the whole session (matches the old dict).
var unlocked_synergies : Dictionary = {}

func is_synergy_unlocked(id : StringName) -> bool:
	return unlocked_synergies.get(id, false)
#endregion


var unlocked_zombie_array : Array = []

var demon_codex : Control
# Synergy id waiting for the codex scene to load and register (see
# navigate_to_buff / register_demon_codex).
var pending_codex_synergy := ""

var skull_tile_highlight_area : Control 

var ultimate_charge_container: Control 

signal swap_scenes_signal
signal demon_was_removed
signal crawler_ultimate_triggered
signal syn_monolith_activated

# Per-frame conductor — the deterministic order for gameplay ticks:
#   (1) all zombies tick (movement/attack), then
#   (2) all demon buff zones poll overlaps (react to settled positions).
# Syn charge accumulators and the swap cooldown keep their own _process;
# they touch no cross-system state mid-frame.
func _process(delta: float) -> void:
	if get_tree().paused:
		return
	var zombies := all_zombies.duplicate()
	for zombie in zombies:
		if zombie != null:
			zombie.tick(delta)
	var demons := all_demons.duplicate()
	for this_demon in demons:
		if this_demon != null and is_instance_valid(this_demon):
			this_demon.tick_buff(delta)

func add_mana(mana_to_add:float)->void:
	ultimate_charge_container.add_mana(mana_to_add)

func disable_ultimate()->void:
	print("GLOBAL Should DISABLE Ultimate")
	if ultimate_charge_container != null:
		ultimate_charge_container.disable_ult()


func enable_ultimate()->void:
	print("GLOBAL Should Enable Ultimate")
	ultimate_charge_container.enable_ult()

	
func un_ready_ultimate()->void:
	ultimate_is_ready = false
	ultimate_charge_container.un_ready_ultimate()

func reset_all_variables()->void:
	gameIsStarted = false
	hero_demon_summoned = false
	ultimate_is_ready = false
	occulumCountVisual = 0
	reset_swap_ability()
	resetOcculumCount()
	reset_demon_managers()
	reset_all_zombies()
	reset_all_demons()
	reset_syn_registries()
	# Compact (don't clear): both dimensions' level roots call this in _ready,
	# and their children have already registered by then (children ready first).
	ui_layers = compact_registrations(ui_layers)
	wave_previews = compact_registrations(wave_previews)

func emit_syn_monolith_activated()->void:
	syn_monolith_activated.emit()

# NOTE: must build a NEW array (see resetOcculumCount) — never append to the
# array being iterated.
func compact_registrations(registered : Array) -> Array:
	var valid : Array = []
	for item in registered:
		if item != null and is_instance_valid(item):
			valid.append(item)
	return valid

func get_files_in_folder(path: String, prefix: String) -> Array[String]:
	var files: Array[String] = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Could not open directory: %s. Error: %d" % [path, DirAccess.get_open_error()])
		return files
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.begins_with(prefix):
			files.append(path.path_join(file_name))
		file_name = dir.get_next()
	dir.list_dir_end()
	return files

func register_skull_tile_highlight_area(new_skull_tile_highlight_area)->void:
	skull_tile_highlight_area = new_skull_tile_highlight_area
		

func free_portals()->void:
	purple_portal.free_portal()
	green_portal.free_portal()
	portal_progress_bar.recharge()
	if portal_progress_bar_1 != null:
		portal_progress_bar_1.recharge()


func get_demon_cost(demon_name: String) -> int:
	var def : DemonDefinition = demon_catalog.get_demon(StringName(demon_name))
	if def == null:
		return -1
	return def.get_scene_cost()
	
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

func hide_swap_and_pip()->void:
	swap_ability.hide()
	hide_pip()
	
func show_swap_and_pip()->void:
	swap_ability.show()
	show_pip()
	
func register_demon_selection_menu(new_demon_selection_menu)->void:
	var temp_menu_holder :Array = []
	for menu in demon_selection_menus:
		if menu != null && is_instance_valid(menu):
			temp_menu_holder.append(menu)
			
	demon_selection_menus = temp_menu_holder
	demon_selection_menus.append(new_demon_selection_menu)

func show_wave_label(wave_num:int)->void:
	for menu in demon_selection_menus:
		if menu != null:
			menu.show_wave_label(wave_num)

	

func hideDemonSelectionMenu() -> void:
	for menu in demon_selection_menus:
		if menu != null:
			menu.visible = false 
			print(menu , " demon selection menu hide")
			
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
					print(menu , " demon selection menu show")
			elif !on_purple:
				if menu.is_alt:
					menu.visible = true
					print(menu , " demon selection menu show") 
						 
	#if demon_selection_menu != null:
		#demon_selection_menu.visible = true
		
func get_demon_selection_menu(is_green:bool)->Control:
	for menu in demon_selection_menus:
		if menu != null:
			if menu.is_alt && is_green:
				return menu
			if !menu.is_alt && !is_green:
				return menu 
	return null
		
		
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
	
func add_blood_to_demon_manager(is_green:bool=false)->void:
	for demon_manager in demon_managers:
		if is_green == demon_manager.is_green:
			demon_manager.add_blood(recovery_blood_value)

func get_demon_manager(is_green:bool)->Node:
	for demon_manager in demon_managers:
		if is_green == demon_manager.is_green:
			return demon_manager
	return null 
	
	
#region Syn ability / shield / lightning-ball pair registries
# (planned: collapse the three copy-pasted register/connect/deregister blocks
# into one generic pair-linker in refactor Phase 7)
func register_syn_ability_instance(new_syn_ability : Area2D)->void:
	print("Register Syn Ability ", new_syn_ability)
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
	#print("Should Start connect Syn Abilities")
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
	#print(registered_syn_abilities, " now has size syn abilitys : ",registered_syn_abilities.size() )		
		
		
		
		
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
		pass
		print(registered_syn_shields, " Cannot connect not enough syn sheilds : ",registered_syn_shields.size() )




func connect_syn_shields()->void:
	#print("Should Start connect shields s")
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

# Deployed syn instances are freed with their level scenes, but nothing
# deregisters them on a restart — clear outright so no stale cached refs
# survive into the next run. Safe to clear (vs compact): none exist at load.
func reset_syn_registries()->void:
	registered_syn_abilities.clear()
	purple_syn_ability = null
	green_syn_ability = null
	registered_syn_shields.clear()
	purple_syn_shield = null
	green_syn_shield = null
	registered_lightning_balls.clear()
	purple_lightning_ball = null
	green_lightning_ball = null
#endregion



	
func resetOcculumCount() -> void:
	is_blocking = false
	occulumCount = 0
	green_occulum_count = 0
	purple_occulum_count = 0
	# NOTE: must be a NEW array. Aliasing all_registered_occulum here and
	# appending to it while iterating it is an infinite loop (froze on restart).
	var temp_occulum_array : Array = []

	for occulum in all_registered_occulum:
		if occulum != null and is_instance_valid(occulum):
			temp_occulum_array.append(occulum)

	all_registered_occulum = temp_occulum_array
	#print("All Registered Occulum is ", all_registered_occulum)
	
	#game_controller.on_scene_1 = true 
	
	
func incrementOcculumCount() -> void:
	if game_controller.on_purple_scene():
		purple_occulum_count += 1
		for menu in demon_selection_menus:
			if menu != null:
				if !menu.is_alt:
					menu.adjust_occulum_cost() 
	else: #Green
		green_occulum_count += 1
		for menu in demon_selection_menus:
			if menu != null:
				if menu.is_alt:
					menu.adjust_occulum_cost() 
				
	#occulumCount += 1
	#for menu in demon_selection_menus:
		#if menu != null:
			#menu.increaseOcculumCost() 
	##demon_selection_menu.increaseOcculumCost()

func decrement_occulum_count()->void:
	if game_controller.on_purple_scene():
		purple_occulum_count -= 1
		for menu in demon_selection_menus:
			if menu != null:
				if !menu.is_alt:
					menu.adjust_occulum_cost() 
	else: #Green
		green_occulum_count -= 1
		for menu in demon_selection_menus:
			if menu != null:
				if menu.is_alt:
					menu.adjust_occulum_cost() 	


	
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
	if new_demon.has_signal("crawler_ultimate_triggered"):
		new_demon.crawler_ultimate_triggered.connect(crawler_ult_triggered)
	all_demons.append(new_demon)

func crawler_ult_triggered()->void:
	crawler_ultimate_triggered.emit()
	


func get_all_demons()->Array:
	return all_demons 

func demon_removed()->void:
	demon_was_removed.emit()
		
func register_hero_demon(new_hero_demon : Area2D) -> void:
	if current_hero_demon != null && is_instance_valid(current_hero_demon):
		current_hero_demon.remove_hero()
	current_hero_demon = new_hero_demon
	hero_demon_summoned = true


func hero_demon_is_summoned() -> bool:
	return hero_demon_summoned

func swap_scenes() -> void:
	print("SWAP SCENES SHOULD")
	game_controller.swap_scenes()
	adjust_ui_layer()					
	swap_portal_button()
	#swap_hero_demon()
	swap_scenes_signal.emit()
	#demon_manager.swap_heart()

#func swap_hero_demon()->void:
	#pass
	##print("Swap Hero Demon")
	#if hero_demon != null:
		#if hero_demon.is_in_group("Purple"):
			##print("Hero Was Purple")
			#hero_demon.add_to_group("Green")
			#hero_demon.remove_from_group("Purple")
			#if hero_demon.is_in_group("Purple"):
				#print("Hero Still Purple Lmao")
			#hero_demon.reparent(game_controller.get_active_dimension().game_layer)
			#hero_demon.swap_scenes()
		#else:
		##	print("Hero Was Green")
			#hero_demon.add_to_group("Purple")
			#hero_demon.remove_from_group("Green")
			#hero_demon.reparent(game_controller.get_active_dimension().game_layer)
			#hero_demon.swap_scenes()
	

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
					#this_preview.hide()
					this_preview.set_detect_mouse(false)
					this_preview.make_preview_visible()
					
					pass
				else:
					pass
					this_preview.set_detect_mouse(true)
					this_preview.make_preview_visible()
			else:
				#print("ON GREEN SCENE SHOULD HIDE PURPLE PREVIEW")
				if this_preview.is_green == true :
					this_preview.set_detect_mouse(true)
					this_preview.make_preview_visible()
					pass
				else:
					pass
					this_preview.set_detect_mouse(false)
					this_preview.make_preview_visible()
					#this_preview.hide()
		
	
	
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
		print("Stop Swap In Globa;l")
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

func reset_all_demons()->void:
	all_demons = compact_registrations(all_demons)
	
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
	UiFx.add_pulsing_button_highlight(game_controller.pip.get_pip_panel())


func stop_pip_glow()->void:
	UiFx.remove_pulsing_button_highlight(game_controller.pip.get_pip_panel())
	
	
func register_style_menu(new_style_menu)->void:
	style_menu = new_style_menu
	pass
	
	
func start_game()->void:
	if swap_ability != null:
		swap_ability.game_start()
	for occulum in all_registered_occulum:
		if occulum != null && is_instance_valid(occulum):
			occulum.start_blood_timer()
	ultimate_charge_container.set_margin()
	pass
	
	
func register_occulum(new_occulum:Demon)->void:
	all_registered_occulum.append(new_occulum)


func get_current_ui_layer()->Control:
	var on_purple :bool= game_controller.on_purple_scene()
	for ui_layer in ui_layers:
		if is_instance_valid(ui_layer):
			if on_purple && ui_layer.make_green == false:
				return ui_layer
			if !on_purple && ui_layer.make_green == true:
				return ui_layer
	return null
			
			
func unlock_zombie(unlocked_zombie : String)->void:
	if gameIsStarted:
		for zombie_name : String in ZombieRegistry.SCENES:
			if zombie_name == unlocked_zombie && zombie_name not in unlocked_zombie_array:
				print("Just Unlocked ", zombie_name)
				unlocked_zombie_array.append(zombie_name)
				get_current_ui_layer().set_zombie_unlock_notif(zombie_name)


func unlock_buff(unlocked_buff : String)->void:
	var id := StringName(unlocked_buff)
	if synergy_catalog.get_by_id(id) == null:
		return
	if not unlocked_synergies.get(id, false):
		print("this synergy ", id, " is A MATCH")
		unlocked_synergies[id] = true
		get_current_ui_layer().set_unlock_notif(unlocked_buff)


func navigate_to_buff(new_synergy:String)->void:
	pending_codex_synergy = new_synergy
	game_controller.change_scene_with_pause("res://_UI/LoreBooks/demon_lore_book.tscn")


func register_demon_codex(new_demon_codex : Control)->void:
	demon_codex = new_demon_codex
	await demon_codex.ready
	if pending_codex_synergy != "":
		var synergy : String = pending_codex_synergy
		pending_codex_synergy = ""
		demon_codex.navigate_to_synergy(synergy)
