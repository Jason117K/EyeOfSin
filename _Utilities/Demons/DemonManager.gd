extends Node2D
#DemonManager.gd

# Get a reference to the demon selection menu 
@onready var selection_menu = get_parent().get_parent().get_node("DemonSelectionMenu")
@onready var notification_bar = Global.notification_bar
@onready var parentName = get_parent().get_name()

@export var blood_points = 200 # Holds how many blood points we have currently 

var selected_demon_scene = null  # Holds the selected demon scene
var grid_size = 32 # Defines the size of each grid cell 
var grid_map = {}  # Dictionary to store occupied cells
var demon_cost = 25  # Holds the cost of the currently selected demon 
var demon_to_move
var demon_highlighted := false
var highlight_demon_global_pos 
var occulum_scene := preload("res://_Entities/Demons/_Occulum/Occulum.tscn")
var empty_demon_scene := preload("res://_Entities/Demons/Empty/EmptyDemon.tscn")
var crawler_not_placed := true 
var hero_demon : Demon 

signal demon_placed(grid_position: Vector2)
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
	get_parent().get_node("UILayer").set_initial_blood(str(blood_points))


# Reference the DemonSelectionMenu dynamically
func get_selected_demon():
	#print("Emit Test")
	test_signal.emit()
	if demon_highlighted:
		#print("Returning HighLight Occulum.R")
		return occulum_scene
	else:
		return get_parent().get_parent().get_node("DemonSelectionMenu").selected_demon


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
			if get_parent().visible == false:
				#print(get_parent(), " is not visible, return early qqx")
				return 
			#print(get_parent()," QQx Grid Map on Click is ", grid_map)
			var mouse_pos = get_global_mouse_position()
			var grid_pos = mouse_pos_to_grid(mouse_pos)
			#print("GRID POS IS ", grid_pos)
			grid_pos = Vector2(grid_pos.x+16,grid_pos.y+16)
			#print("GRID POS IS NOW ", grid_pos)
			
			if demon_highlighted:
				move_demon(demon_to_move, grid_pos)

			if selected_demon_scene != null:
				var temp_instance = selected_demon_scene.instantiate()
				
				var cost = temp_instance.get_cost()
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
				#TODO Make Double Click
				#print("Clicked1 and Demon Scene Null NN")
				if selection_menu.getCanRemove():
					#print("Clicked1 and Time to Clear Space")
					clear_space(grid_pos)
					#selection_menu.setCanRemoveFalse()
				if detect_demon(grid_pos):
				#	print("Demon Detected")
					highlight_demon(grid_pos)
					pass
				return 
			# Place the demon assuming it's within bounds of the level
			if(parentName == "Main"):
				if(grid_pos.x<769 && grid_pos.y<208 && grid_pos.y > 80):
					print("Place Demon " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_demon(grid_pos)
			elif(parentName == "Level0-1" || parentName == "Level0-1_Alternate"):
				if(grid_pos.x<769 && grid_pos.y<176 && grid_pos.y > 112):
					print("Place Demon " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_demon(grid_pos)
			elif(parentName == "Level0-2" || parentName == "Level0-2_Alternate"):
				if(grid_pos.x<769 && grid_pos.y<208 && grid_pos.y > 80):
					print("Place Demon " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_demon(grid_pos)
			elif(parentName == "Level3"):
				print("Grid map size is ", grid_map.size())
				if grid_map.size() == 0 && selected_demon_scene:
					var temp_instance = selected_demon_scene.instantiate()
					if "Wyrm" in temp_instance.get_name():
						print("Place Demon1 " , grid_pos)
						Global.game_controller.place_empty_in_alt_scene(grid_pos)
						place_demon(grid_pos)
					temp_instance.queue_free()
					
				if grid_map.size() == 1:
					var keys = grid_map.keys()
					
					var first_key = keys[0]
					var first_value = grid_map[first_key]
					print("First key: ", first_key, ", First value: ", first_value)
					print("Thiss grd: ", grid_pos)
					print(abs(first_key.x - grid_pos.x))
							
					
					if  abs(first_key.x - grid_pos.x) < 65 &&  (abs(first_key.y - grid_pos.y) < 32):
						if grid_pos.x > first_key.x:
							print("Try place demon")
							Global.game_controller.place_empty_in_alt_scene(grid_pos)
							place_demon(grid_pos)
					else:
						pass
				else:
					#print("Place Demon2 " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_demon(grid_pos)
				
			else:
				if(grid_pos.x<769 && grid_pos.y<500 && grid_pos.y > 80):
					#print(get_parent(), "QQOtro Place Demon " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_demon(grid_pos)

# Convert mouse position to a grid cell position
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size

# Clear a space for a new demon to go 
func clear_space(passed_grid_pos):
	#print("QQ Grid Map is ", grid_map)
	#print(" QQ Erase Demon At :", passed_grid_pos)
	var demon_node = grid_map.get(passed_grid_pos)
	#print(" QQ Demon to Erase Is  ", demon_node)
	#demonToErase.die()
	if demon_node != null:
		demon_node.die_fromClearSpace()
		#print("The Right DDDDDDD Function is Being Called ")
		#if "Empty" in demon_node.name:
			##return
			#pass
		#else:
			#demon_node.die_fromClearSpace()
		#demon_node.queue_free()
	grid_map.erase(passed_grid_pos)
	Global.game_controller.remove_empty_in_alt_scene(passed_grid_pos)

func clear_space_alt(passed_grid_pos):
#	print("QQ Grid Map is ", grid_map)
	#print(" QQ Erase Demon At :", passed_grid_pos)
	var demon_node = grid_map.get(passed_grid_pos)
	#print(" QQ Demon to Erase Is  ", demon_node)
	#demonToErase.die()
	if demon_node != null:
		demon_node.die_fromClearSpace()
		#print("The Right DDDDDDD Function is Being Called ")
		#if "Empty" in demon_node.name:
			##return
			#pass
		#else:
			#demon_node.die_fromClearSpace()
		#demon_node.queue_free()
	grid_map.erase(passed_grid_pos)
	#Global.game_controller.remove_empty_in_alt_scene(passed_grid_pos)
	
func detect_demon(passed_grid_pos):
	#print("QQ Grid Map is ", grid_map)
	var demon_node = grid_map.get(passed_grid_pos)
	
	if demon_node != null:
		#print("Demon Node is , ",demon_node, " returning true" )
		return true
	else:
		#print("Demon Node is , ",demon_node, " returning false" )
		return false 
	
func highlight_demon(passed_grid_pos):
	#print("QQ Grid Map is ", grid_map)
	var demon_node = grid_map.get(passed_grid_pos)
	demon_to_move = demon_node
	if demon_node.has_method("highlight"):
	#	print("HighLight Should Turn On")
		highlight_demon_global_pos = demon_node.global_position 
		demon_node.toggle_highlight()
		demon_highlighted = true
		
		
		pass

func move_demon(this_demon_to_move, passed_new_grid_pos):
	this_demon_to_move.toggle_highlight()
	#print("QQ Grid Map is ", grid_map)
	#print("HighLight Should Turn Off")
	#print("HighLight Selected Demon is ", selected_demon_scene)
	selected_demon_scene = occulum_scene
#	print("HighLight Selected Demon is NOW ", selected_demon_scene)
	#print("HighLight OLD Demon is ", this_demon_to_move)
	place_demon(passed_new_grid_pos)
	#Doesnt Work
	#clear_space(passed_new_grid_pos)
	
	#Works 
	demon_highlighted = false
	clear_space(highlight_demon_global_pos)
	pass
	
func place_empty_blocker_demon(grid_pos):
	#print(get_parent(), " QQ1 Grid Map is ", grid_map)
	#Add Scene Names 
	#print("Should Place Block Demon")
	selected_demon_scene = empty_demon_scene
#	print("About to Place Demon")
	if(grid_pos.x<769 && grid_pos.y<304 && grid_pos.y > 48):
		pass
	else:
		print("Grid Pos ", grid_pos, " is OUTTA BOUNDS")
		return 
	
	
	if selected_demon_scene == null:
		print("No demon selected!")
		return
	
	var demon_instance = selected_demon_scene.instantiate()
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
		
		#print("Have enough blood, placing demon ")
		#Maw Handling, occupies two cells
		if "Maw" in demon_instance.name:
			demon_instance.position = Vector2(grid_pos.x+16,grid_pos.y)
			grid_map[grid_pos] = demon_instance
			#print(get_parent(), "QQZGirdMap Now Contains",grid_pos)
			grid_map[Vector2(grid_pos.x+32,grid_pos.y)] = demon_instance
			#print(get_parent(), "QQZGirdMap Now Contains",Vector2(grid_pos.x+32,grid_pos.y))
			#Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x+32,grid_pos.y))
			
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
	
	#print(get_parent(), "QQ Blocker Demon Was Placed At " , demon_instance.position)
	
	
# Place the selected demon on the grid
func place_demon(grid_pos: Vector2):
	#print(get_parent(), "QQ Grid Map Place Demon is ", grid_map)
	#print("About to Place Demon")
	if(grid_pos.x<769 && grid_pos.y<336 && grid_pos.y > 48):
		pass
	else:
		#print("Grid Pos ", grid_pos, " is OUTTA BOUNDS")
		return 
	
	# Dynamically get the selected demon	
	selected_demon_scene = get_selected_demon()  
	
	if selected_demon_scene == null:
		print("No demon selected!")
		return
	
	var demon_instance = selected_demon_scene.instantiate()
	#print("Will Make PPName From ",demon_instance.name)
	demon_instance.name = generate_unique_name(demon_instance.name)
	if "Alternate" in get_parent().name :
		demon_instance.add_to_group("Green")
	else:
		print("Add ", demon_instance, " to purple group")
		demon_instance.add_to_group("Purple")
	
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
		
		#Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x+32,grid_pos.y))
		#Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x+32,grid_pos.y+32))
		#Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x+32,grid_pos.y-32))
		#Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x,grid_pos.y+32))
		#Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x,grid_pos.y-32))
		#Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x-32,grid_pos.y))
		hero_demon = demon_instance  
		Global.game_controller.register_heart_alt_scene(hero_demon)
		print("Heart Demon Should Be Placed : ", hero_demon)
	
	#Get The Cost 
	demon_cost = demon_instance.get_cost()
	print("Demon CCost is : ", demon_cost)
	
	if blood_points >= demon_cost: 
		
		#print("Have enough blood, placing demon ")
		#Maw Handling, occupies two cells
		if "Maw" in demon_instance.name:
			demon_instance.position = Vector2(grid_pos.x+16,grid_pos.y)
			demon_instance.position = Vector2(demon_instance.position.x-256,demon_instance.position.y-256)
			grid_map[grid_pos] = demon_instance
			#print("QQGirdMap Now Contains",grid_pos)
			grid_map[Vector2(grid_pos.x+32,grid_pos.y)] = demon_instance
		#	print("QQGirdMap Now Contains",Vector2(grid_pos.x+32,grid_pos.y))
			
		else: #Only occupies one cell
			demon_instance.position = Vector2(grid_pos.x,grid_pos.y )
			grid_map[grid_pos] = demon_instance
	
		#Add To The GameLayer 
		#demon_instance.set_process(false)
		get_parent().get_node("GameLayer").call_deferred("add_child", demon_instance)

		#Reduce Blood Points
		blood_points -= demon_cost
		
		#Global.ui_layer.set_blood(str(blood_points))
		get_parent().get_node("UILayer").set_blood(str(blood_points))
		
		#Play the sound
		AudioManager.create_2d_audio_at_location(demon_instance.position, SoundEffect.SOUND_EFFECT_TYPE.DEMON_SUMMON)
		#$PlaceDemonAudioPlayer.play()
		print("Pdemon name is ", demon_instance.name)
		if "SpinalOcculum" in demon_instance.name:
			spinalOcculum_placed.emit(grid_pos)
			pass
		elif "Occulum" in demon_instance.name:
			print("Selected Demon Scene is : ", demon_instance.name)
			#demon_instance.position = Vector2(grid_pos.x,grid_pos.y + 13 )
			#TODO change to occulum_placed
			demon_placed.emit(grid_pos)
			Global.incrementOcculumCount()
			pass
		elif "Crawler" in demon_instance.name:
			#if crawler_not_placed:
			print("[TUTORIAL] Emit Crawler Placed")
			crawler_placed.emit(grid_pos)
			crawler_not_placed = false
			pass

		elif "Wyrm" in demon_instance.name:
			wyrm_placed.emit(grid_pos)
		elif "Hive" in demon_instance.name:
			wasp_placed.emit(grid_pos)
		elif "Maw" in demon_instance.name:
			maw_placed.emit(grid_pos)
			
		#print("Selected Demon Scene is : ", demon_instance)
		
		
		# Clear preview after successful placement, or do this when deselect Hit 
		#selection_menu.clear_preview()
		
	else:
		print("NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
		#Global.notification_bar.show()
		#Global.notification_bar.set_text(" CANNOT AFFORD DEMON")
		pass
		#print("Not enough blood points!")
	
	#print("QQZ Demon Was Placed At " , demon_instance.position)
	selection_menu.deselect_demon()

# Helper function to generate sequential names
func generate_unique_name(base_name: String) -> String:
	var used_numbers = []
	# Collect all existing numbers from siblings
	for child in get_parent().get_node("GameLayer").get_children():
		#print("PPChild is ", child.name)
		if child.name.begins_with(base_name):
			var suffix = child.name.substr(base_name.length())
			#print("PPSuffix Is ", suffix)
			if suffix.is_valid_int():
				used_numbers.append(suffix.to_int())
					
	used_numbers.sort()
	#print("Used PP Numbers is ",used_numbers )
	# Find first available number (fills gaps)
	var candidate = 1
	for num in used_numbers: 
		if candidate < num:
			break  # Gap found
		if candidate == num:
			candidate = num + 1
	#print("Will Return PP ", base_name + str(candidate))
	return base_name + str(candidate)
	
#Add blood to total 
func add_blood(amount):
	blood_points += amount
	#Global.ui_layer.set_blood(str(blood_points))
	get_parent().get_node("UILayer").set_blood(str(blood_points))
	
# Play the blood collection sound 
func play_blood_collect():
	#$SunCollectPlayer.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.SUN_COLLECT)
	
# Set the starting blood amount depending on level 
func _on_SetBlood_timeout():
	if(get_parent().name == "Main"):
		#blood_points = 300 #75
		#Global.ui_layer.set_blood(str(blood_points))
		get_parent().get_node("UILayer").set_blood(str(blood_points))
	else:
		#blood_points = 900 #700
		#Global.ui_layer.set_blood(str(blood_points))
		get_parent().get_node("UILayer").set_blood(str(blood_points))

func swap_heart():
	#print("Hero Demon Is ", hero_demon)
	if hero_demon != null:
		if "Alternate" in get_parent().name :
			hero_demon.add_to_group("Green")
			hero_demon.remove_from_group("Purple")
			hero_demon.reparent(get_parent().get_node("GameLayer"))
			hero_demon.set_attack_collision()
			
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y+32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y-32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y+32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y-32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x-32,hero_demon.global_position.y)] = hero_demon
			
		else:
			hero_demon.add_to_group("Purple")
			hero_demon.remove_from_group("Green")
			hero_demon.reparent(get_parent().get_node("GameLayer"))
			hero_demon.set_attack_collision()
			
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y+32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y-32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y+32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y-32)] = hero_demon
			grid_map[Vector2(hero_demon.global_position.x-32,hero_demon.global_position.y)] = hero_demon

#Clear Hero Demon When Swapping Dimensions 
func clear_hero_demon():
	if hero_demon != null:
		grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y+32)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x+32,hero_demon.global_position.y-32)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y+32)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x,hero_demon.global_position.y-32)] = empty_demon_scene
		grid_map[Vector2(hero_demon.global_position.x-32,hero_demon.global_position.y)] = empty_demon_scene
