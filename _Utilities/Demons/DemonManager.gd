class_name DemonManager
extends Node2D
#DemonManager.gd

# Get a reference to the demon selection menu
@onready var selection_menu: Control = get_parent().get_node("DemonSelectionMenu")
@onready var notification_bar: MarginContainer = Global.notification_bar
@onready var parentName: String = get_parent().get_name()
@onready var grid_manager : Node2D = $"../GameLayer/GridManager"
@export var blood_points: int = 200 # Holds how many blood points we have currently

@onready var camera : Camera2D = get_parent().get_node("Camera2D")

var selected_demon_scene: PackedScene = null  # Holds the selected demon scene
var grid_size: int = 32 # Defines the size of each grid cell
var grid_map: Dictionary = {}  # Dictionary to store occupied cells
var demon_cost: int = 25  # Holds the cost of the currently selected demon
var demon_to_move: Demon
var demon_highlighted := false
var highlight_demon_global_pos: Vector2
var occulum_scene := preload("res://_Entities/Demons/_Occulum/Occulum.tscn")
var empty_demon_scene := preload("res://_Entities/Demons/Empty/EmptyDemon.tscn")
var crawler_not_placed := true
var hero_demon: Demon

signal demon_placed(grid_position: Vector2)
signal occulum_placed(grid_position: Vector2)
signal crawler_placed(grid_position: Vector2)
signal spinalOcculum_placed(grid_position: Vector2)
signal wyrm_placed(grid_position: Vector2)
signal wasp_placed(grid_position: Vector2)
signal maw_placed(grid_position: Vector2)
signal test_signal()

func _ready() -> void:
	if get_parent().has_method("crawler_placed"):
		self.connect("_on_crawler_placed", Callable(get_parent(), "crawler_placed"))
	print("blood_points is ", blood_points, str(blood_points))
	get_parent().get_node("UILayer").set_initial_blood(blood_points)
	
	Global.register_demon_managers(self)


# Reference the DemonSelectionMenu dynamically
func get_selected_demon() -> PackedScene:
	#print("Emit Test")
	test_signal.emit()
	if demon_highlighted:
		#print("Returning HighLight Occulum.R")
		return occulum_scene
	else:
		return get_parent().get_node("DemonSelectionMenu").selected_demon


# Handles Player Interaction with the Demon Menu 
func _unhandled_input(event: InputEvent) -> void:
	if Global.is_blocking:
		return 
	# Dynamically get the selected demon	
	selected_demon_scene = get_selected_demon()  
	
	if selected_demon_scene == null:
		#print("Demon Scene is Null")
		pass
	
	if event is InputEventMouseButton and event.pressed:
		# If they left click, grab the positon and place a demon there 
		if event.button_index == MOUSE_BUTTON_LEFT:
			if get_parent() != Global.game_controller.get_active_dimension():
				#print(get_parent(), " is not visible, return early qqx")
				return 
			#print(get_parent()," QQx Grid Map on Click is ", grid_map)
			var mouse_pos :Vector2= get_global_mouse_position()
			var grid_pos :Vector2= mouse_pos_to_grid(mouse_pos)
			#print("GRID POS IS ", grid_pos)
			grid_pos = Vector2(grid_pos.x+16,grid_pos.y+16)
			#print("GRID POS IS NOW ", grid_pos)
			
			if demon_highlighted:
				move_demon(demon_to_move, grid_pos)

			if selected_demon_scene != null:
				var temp_instance = selected_demon_scene.instantiate()
				
				var cost :float= temp_instance.get_cost()
				print("Temp instance is ", temp_instance.get_name(), " with a cost of " , cost)
				if(parentName == "Level3"):
					#print("Grid map size is ", grid_map.size())
					if grid_map.size() == 0 && selected_demon_scene:
					
						if "Wyrm" in temp_instance.get_name():
							#print("Place Demon11 " , grid_pos)
							place_demon(grid_pos)
							return
						else:
							return
					
				temp_instance.queue_free()
				# early return if no blood points
				if blood_points < cost:
					selection_menu.clear_preview()
					Global.notification_bar.set_text(" CANNOT AFFORD DEMON")
					selection_menu.deselect_demon()
					print("Blood Points is : ", blood_points, " which is less than ", cost)
					return
			else: #Demon Scene Null
				#TODO Make Demons Handle Their Own Selection After Being Placed
				#print("Clicked1 and Demon Scene Null NN")
				if selection_menu.getCanRemove():
					print("Clicked1 and Time to Clear Space")
					clear_space(grid_pos)
					#selection_menu.setCanRemoveFalse()
				if detect_demon(grid_pos):
				#	print("Demon Detected")
					#highlight_demon(grid_pos)
					pass
				Global.hide_notification_bar()
				return 
			# Place the demon assuming it's within bounds of the level
			if(parentName == "Level0-1" || parentName == "Level0-1_Alternate"):
				if(grid_pos.x<769 && grid_pos.y<176 && grid_pos.y > 112):
					#print("Place Demon " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_demon(grid_pos)
			elif(parentName == "Level0-2" || parentName == "Level0-2_Alternate"):
				if(grid_pos.x<769 && grid_pos.y<208 && grid_pos.y > 80):
					#print("Place Demon " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_demon(grid_pos)
				
			else:
				if(grid_pos.x<769 && grid_pos.y<500 && grid_pos.y > 80):
					#print(get_parent(), "QQOtro Place Demon " , grid_pos)
					var temp_check_instance =  get_selected_demon().instantiate()
					#if temp_check_instance.is_hero == false:
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					temp_check_instance.queue_free()
					place_demon(grid_pos)

# Convert mouse position to a grid cell position
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size

# Clear a space for a new demon to go 
func clear_space(passed_grid_pos: Vector2) -> void:
	var demon_node: Demon = grid_map.get(passed_grid_pos)
	if demon_node != null:
		print(demon_node , " Demon Node will DIE from CLEAR SPACE")
		demon_node.die_fromClearSpace()
	grid_map.erase(passed_grid_pos)
	Global.game_controller.remove_empty_in_alt_scene(passed_grid_pos)

func clear_space_alt(passed_grid_pos: Vector2) -> void:
	var demon_node: Demon = grid_map.get(passed_grid_pos)
	if demon_node != null:
		demon_node.die_fromClearSpace()
	grid_map.erase(passed_grid_pos)
	#Global.game_controller.remove_empty_in_alt_scene(passed_grid_pos)
	
func detect_demon(passed_grid_pos: Vector2) -> bool:
	#print("QQ Grid Map is ", grid_map)
	var demon_node = grid_map.get(passed_grid_pos)
	
	if demon_node != null:
		#print("Demon Node is , ",demon_node, " returning true" )
		return true
	else:
		#print("Demon Node is , ",demon_node, " returning false" )
		return false 
	

func move_demon(this_demon_to_move: Demon, passed_new_grid_pos: Vector2) -> void:
	this_demon_to_move.toggle_highlight()
	selected_demon_scene = occulum_scene
	place_demon(passed_new_grid_pos)
	#Doesnt Work
	#clear_space(passed_new_grid_pos)
	
	#Works 
	demon_highlighted = false
	print("TRIED MOVE and Time to Clear Space")
	clear_space(highlight_demon_global_pos)
	pass
	
func place_empty_blocker_demon(grid_pos: Vector2) -> void:
	selected_demon_scene = empty_demon_scene
	if(grid_pos.x<769 && grid_pos.y<305 && grid_pos.y > 48):
		pass
	else:
		print("Grid Pos ", grid_pos, " is OUTTA BOUNDS")
		return 
	
	if selected_demon_scene == null:
		print("No demon selected!")
		return
	
	var demon_instance :Demon= selected_demon_scene.instantiate()
	#print("Will Make PPName From ",demon_instance.name)
	demon_instance.name = generate_unique_name(demon_instance.name)
	
	
	#Check if Spot is Occupied
	if grid_pos in grid_map:
		print(get_parent(), grid_pos , " QQW Cell already occupied!")
		return
	
	#Maw is larger, check neighboring cell
	if  "Maw" in demon_instance.name:
		if Vector2(grid_pos.x+32,grid_pos.y) in grid_map:
			print(get_parent(), "QQ Maw is Big, Neighboring Cell Occupied at : ", Vector2(grid_pos.x+32,grid_pos.y) )
			return 
	
	if blood_points >= -99999: 
		#Maw Handling, occupies two cells
		if "Maw" in demon_instance.name:
			demon_instance.position = Vector2(grid_pos.x+16,grid_pos.y)
			grid_map[grid_pos] = demon_instance
			grid_map[Vector2(grid_pos.x+32,grid_pos.y)] = demon_instance

			
		else: #Only occupies one cell
			demon_instance.position = Vector2(grid_pos.x,grid_pos.y)
			grid_map[grid_pos] = demon_instance
	
		#Add To The GameLayer 
		#demon_instance.set_process(false)
		get_parent().get_node("GameLayer").call_deferred("add_child",demon_instance)

		#Play the sound
		AudioManager.create_2d_audio_at_location(demon_instance.position, SoundEffect.SOUND_EFFECT_TYPE.DEMON_SUMMON)

	else:
		pass
		#print("Not enough blood points!")

	
	
# Place the selected demon on the grid
func place_demon(grid_pos: Vector2) -> void:
	if(grid_pos.x<769 && grid_pos.y<336 && grid_pos.y > 48):
		pass
	else:
		return 
	if grid_manager.is_blocked(grid_pos):
		return 
	
	# Dynamically get the selected demon	
	selected_demon_scene = get_selected_demon()  
	
	if selected_demon_scene == null:
		#print("No demon selected!")
		return
	
	var demon_instance = selected_demon_scene.instantiate()
	demon_instance.name = generate_unique_name(demon_instance.name)
	if "Alternate" in get_parent().name :
		demon_instance.add_to_group("Green")
		demon_instance.set_collision_layer_value(1,false)
		demon_instance.set_collision_layer_value(2,false)
		demon_instance.set_collision_layer_value(3,true)
	else:
		print("Add ", demon_instance, " to purple group")
		demon_instance.add_to_group("Purple")
		demon_instance.set_collision_layer_value(1,false)
		demon_instance.set_collision_layer_value(2,true)
		demon_instance.set_collision_layer_value(3,false)	

	#Check if Spot is Occupied
	if grid_pos in grid_map:
		#print(get_parent(), grid_pos , " QQV Cell already occupied! Grid Map is ", grid_map)
		return
	
	#Maw is larger, check neighboring cell
	if  "Maw" in demon_instance.name:
		if Vector2(grid_pos.x+32,grid_pos.y) in grid_map:
			#print("QQ Maw is Big, Neighboring Cell Occupied at : ", Vector2(grid_pos.x+32,grid_pos.y) )
			return 
		else:
			Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x+32,grid_pos.y))
	if "Heart" in demon_instance.name:
		#print("About to Place Heart Demon")
		if Vector2(grid_pos.x+32,grid_pos.y) in grid_map:
			return 
		if Vector2(grid_pos.x+32,grid_pos.y+32) in grid_map:
			return 
		if Vector2(grid_pos.x+32,grid_pos.y-32) in grid_map:
			return 
		if Vector2(grid_pos.x,grid_pos.y+32) in grid_map:
			return 
		if Vector2(grid_pos.x,grid_pos.y-32) in grid_map:
			return 
		if Vector2(grid_pos.x-32,grid_pos.y) in grid_map:
			return 
			
		grid_map[Vector2(grid_pos.x+32,grid_pos.y)] = demon_instance
		grid_map[Vector2(grid_pos.x+32,grid_pos.y+32)] = demon_instance
		grid_map[Vector2(grid_pos.x+32,grid_pos.y-32)] = demon_instance
		grid_map[Vector2(grid_pos.x,grid_pos.y+32)] = demon_instance
		grid_map[Vector2(grid_pos.x,grid_pos.y-32)] = demon_instance
		grid_map[Vector2(grid_pos.x-32,grid_pos.y)] = demon_instance

		hero_demon = demon_instance  
		Global.game_controller.register_heart_alt_scene(hero_demon)
		print("Heart Demon Should Be Placed : ", hero_demon)
	
	#Get The Cost 
	demon_cost = demon_instance.get_cost()
	#print("Demon CCost is : ", demon_cost)
	
	if blood_points >= demon_cost: 
		#Maw Handling, occupies two cells
		if "Maw" in demon_instance.name:
			demon_instance.position = Vector2(grid_pos.x+16,grid_pos.y)
			demon_instance.position = Vector2(demon_instance.position.x-256,demon_instance.position.y-256)
			grid_map[grid_pos] = demon_instance
			grid_map[Vector2(grid_pos.x+32,grid_pos.y)] = demon_instance
			
		else: #Only occupies one cell
			demon_instance.position = Vector2(grid_pos.x,grid_pos.y )
			grid_map[grid_pos] = demon_instance
	
		#Add To The GameLayer 
		AudioManager.create_2d_audio_at_location(demon_instance.position, SoundEffect.SOUND_EFFECT_TYPE.DEMON_SUMMON)
		AudioManager.create_2d_audio_at_location(demon_instance.position, SoundEffect.SOUND_EFFECT_TYPE.DEMON_PLACE)
		get_parent().get_node("GameLayer").call_deferred("add_child", demon_instance)

		#Reduce Blood Points
		blood_points -= demon_cost
		
		#Global.ui_layer.set_blood(str(blood_points))
		get_parent().get_node("UILayer").set_blood(blood_points)
		
		
		camera.screen_shake(1.25,0.7)

		print("Pdemon name is ", demon_instance.name)
		demon_placed.emit(grid_pos)
		if "SpinalOcculum" in demon_instance.name:
			spinalOcculum_placed.emit(grid_pos)
			print("Spinal Occulum Should Emit")
		elif "Occulum" in demon_instance.name:
			#print("Selected Demon Scene is : ", demon_instance.name)
			#TODO change to occulum_placed
			occulum_placed.emit(grid_pos)
			Global.incrementOcculumCount()
		elif "Crawler" in demon_instance.name:
			#print("[TUTORIAL] Emit Crawler Placed")
			crawler_placed.emit(grid_pos)
			crawler_not_placed = false
		elif "Wyrm" in demon_instance.name:
			wyrm_placed.emit(grid_pos)
		elif "Hive" in demon_instance.name:
			wasp_placed.emit(grid_pos)
		elif "Maw" in demon_instance.name:
			maw_placed.emit(grid_pos)

		
	else:
		#print("NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
		#Global.notification_bar.show()
		#Global.notification_bar.set_text(" CANNOT AFFORD DEMON")
		pass

	selection_menu.deselect_demon()

# Helper function to generate sequential names
func generate_unique_name(base_name: String) -> String:
	var used_numbers: Array = []
	# Collect all existing numbers from siblings
	for child in get_parent().get_node("GameLayer").get_children():
		if child.name.begins_with(base_name):
			var suffix :String= child.name.substr(base_name.length())
			if suffix.is_valid_int():
				used_numbers.append(suffix.to_int())
					
	used_numbers.sort()

	# Find first available number (fills gaps)
	var candidate :int= 1
	for num:int in used_numbers: 
		if candidate < num:
			break  # Gap found
		if candidate == num:
			candidate = num + 1
	return base_name + str(candidate)
	
 
func add_blood(amount: int) -> void:
	blood_points += amount
	#Global.ui_layer.set_blood(str(blood_points))
	get_parent().get_node("UILayer").set_blood(blood_points)
	

func play_blood_collect() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.SUN_COLLECT)
	

func _on_SetBlood_timeout() -> void:
	if(get_parent().name == "Main"):
		get_parent().get_node("UILayer").set_blood(blood_points)
	else:
		get_parent().get_node("UILayer").set_blood(blood_points)

func swap_heart() -> void:
	print("Hero Demon Is ", hero_demon)
	if hero_demon != null:
		if "Alternate" in get_parent().name :
			#hero_demon.add_to_group("Green")
			#hero_demon.remove_from_group("Purple")
			#hero_demon.reparent(get_parent().get_node("GameLayer"))
			#hero_demon.set_attack_collision()
			#
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y+32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y-32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y+32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y-32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x-32,hero_demon.global_position.y)] = hero_demon
			
		else:
			#hero_demon.add_to_group("Purple")
			#hero_demon.remove_from_group("Green")
			#hero_demon.reparent(get_parent().get_node("GameLayer"))
			#hero_demon.set_attack_collision()
			#
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y+32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y-32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y+32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y-32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x-32,hero_demon.global_position.y)] = hero_demon

#Clear Hero Demon When Swapping Dimensions 
func clear_hero_demon() -> void:
	if hero_demon != null:
		grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y+32)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y-32)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y+32)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y-32)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x-32,hero_demon.global_position.y)] = empty_demon_scene
