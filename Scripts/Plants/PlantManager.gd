extends Node2D
#PlantManager.gd

# Get a reference to the plant selection menu 
@onready var selection_menu = get_parent().get_node("PlantSelectionMenu")

var selected_plant_scene = null  # Holds the selected plant scene
var grid_size = 32 # Defines the size of each grid cell 
var grid_map = {}  # Dictionary to store occupied cells
@export var sun_points = 200 # Holds how many sun points we have currently 
var plant_cost = 25  # Holds the cost of the currently selected plant 
var plant_to_move
var plant_highlighted := false
var highlight_plant_global_pos 
var sunflower_scene := preload("res://Scenes/PlantScenes/Sunflower.tscn")
var empty_demon_scene := preload("res://Scenes/PlantScenes/EmptyDemon.tscn")

@onready var parentName = get_parent().get_name()

signal plant_placed
signal spyder_placed
signal walnut_placed 
signal eyeBomb_placed
signal eggWorm_placed
signal wasp_placed
signal maw_placed



# Reference the PlantSelectionMenu dynamically
func get_selected_plant():
	if plant_highlighted:
		print("Returning HighLight Sunflower.R")
		return sunflower_scene
	else:
		return get_parent().get_node("PlantSelectionMenu").selected_plant


# Handles Player Interaction with the Plant Menu 
func _input(event):
	# Dynamically get the selected plant	
	selected_plant_scene = get_selected_plant()  
	
	if selected_plant_scene == null:
		#print("Plant Scene is Null")
		pass
	
	if event is InputEventMouseButton and event.pressed:
		# If they left click, grab the positon and place a plant there 
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			var mouse_pos = get_global_mouse_position()
			var grid_pos = mouse_pos_to_grid(mouse_pos)
			#print("GRID POS IS ", grid_pos)
			grid_pos = Vector2(grid_pos.x+16,grid_pos.y+16)
			#print("GRID POS IS NOW ", grid_pos)
			
			if plant_highlighted:
				move_plant(plant_to_move, grid_pos)

			if selected_plant_scene != null:
				var temp_instance = selected_plant_scene.instantiate()
				
				var cost = temp_instance.get_cost()
				#print("Temp instance is ", temp_instance.get_name(), " with a cost of " , cost)
				if(parentName == "Level3"):
					print("Grid map size is ", grid_map.size())
					if grid_map.size() == 0 && selected_plant_scene:
					
						if "Egg" in temp_instance.get_name():
							print("Place Plant11 " , grid_pos)
							place_plant(grid_pos)
							return
						else:
							return
					
				temp_instance.queue_free()
				# early return if no sun points
				if sun_points < cost:
					selection_menu.clear_preview()
					print("Sun Points is : ", sun_points, "which is less than ", cost)
					return
			else: #Plant Scene Null
				#TODO Make Double Click
				print("Clicked and Plant Scene Null NN")
				if selection_menu.getCanRemove():
					clear_space(grid_pos)
					selection_menu.setCanRemoveFalse()
				if detect_plant(grid_pos):
					print("Plant Detected")
					highlight_plant(grid_pos)
					pass
				return 
			# Place the plant assuming it's within bounds of the level
			if(parentName == "Main"):
				if(grid_pos.x<769 && grid_pos.y<208 && grid_pos.y > 80):
					print("Place Plant " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_plant(grid_pos)
			elif(parentName == "Level0-1" || parentName == "Level0-1_Alternate"):
				if(grid_pos.x<769 && grid_pos.y<176 && grid_pos.y > 112):
					print("Place Plant " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_plant(grid_pos)
			elif(parentName == "Level3"):
				print("Grid map size is ", grid_map.size())
				if grid_map.size() == 0 && selected_plant_scene:
					var temp_instance = selected_plant_scene.instantiate()
					if "Egg" in temp_instance.get_name():
						print("Place Plant1 " , grid_pos)
						Global.game_controller.place_empty_in_alt_scene(grid_pos)
						place_plant(grid_pos)
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
							print("Try place plant")
							Global.game_controller.place_empty_in_alt_scene(grid_pos)
							place_plant(grid_pos)
					else:
						pass
				else:
					print("Place Plant2 " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_plant(grid_pos)
				
			else:
				if(grid_pos.x<769 && grid_pos.y<304 && grid_pos.y > 48):
					print("Otro Place Plant " , grid_pos)
					Global.game_controller.place_empty_in_alt_scene(grid_pos)
					place_plant(grid_pos)

# Convert mouse position to a grid cell position
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size

# Clear a space for a new plant to go 
func clear_space(passed_grid_pos):
	#print(" QQ Erase Plant At :", passed_grid_pos)
	var plant_node = grid_map.get(passed_grid_pos)
	#print(" QQ Plant to Erase Is  ", plant_node)
	#plantToErase.die()
	if plant_node != null:
		#print("The Right DDDDDDD Function is Being Called ")
		plant_node.die_fromClearSpace()
		#plant_node.queue_free()
	grid_map.erase(passed_grid_pos)

func detect_plant(passed_grid_pos):
	var plant_node = grid_map.get(passed_grid_pos)
	
	if plant_node != null:
		print("Plant Node is , ",plant_node, " returning true" )
		return true
	else:
		print("Plant Node is , ",plant_node, " returning false" )
		return false 
	
func highlight_plant(passed_grid_pos):
	var plant_node = grid_map.get(passed_grid_pos)
	plant_to_move = plant_node
	if plant_node.has_method("highlight"):
		print("HighLight Should Turn On")
		highlight_plant_global_pos = plant_node.global_position 
		plant_node.toggle_highlight()
		plant_highlighted = true
		
		
		pass

func move_plant(this_plant_to_move, passed_new_grid_pos):
	this_plant_to_move.toggle_highlight()
	
	print("HighLight Should Turn Off")
	print("HighLight Selected Plant is ", selected_plant_scene)
	selected_plant_scene = sunflower_scene
	print("HighLight Selected Plant is NOW ", selected_plant_scene)
	print("HighLight OLD Plant is ", this_plant_to_move)
	place_plant(passed_new_grid_pos)
	#Doesnt Work
	#clear_space(passed_new_grid_pos)
	
	#Works 
	plant_highlighted = false
	clear_space(highlight_plant_global_pos)
	pass
	
func place_empty_blocker_plant(grid_pos):
	print("Should Place Block Plant")
	selected_plant_scene = empty_demon_scene
	print("About to Place Plant")
	if(grid_pos.x<769 && grid_pos.y<304 && grid_pos.y > 48):
		pass
	else:
		print("Grid Pos ", grid_pos, " is OUTTA BOUNDS")
		return 
	
	
	if selected_plant_scene == null:
		print("No plant selected!")
		return
	
	var plant_instance = selected_plant_scene.instantiate()
	#print("Will Make PPName From ",plant_instance.name)
	plant_instance.name = generate_unique_name(plant_instance.name)
	
	
	#Check if Spot is Occupied
	if grid_pos in grid_map:
		print(grid_pos , " QQ Cell already occupied!")
		return
	
	#Maw is larger, check neighboring cell
	if  "Maw" in plant_instance.name:
		if Vector2(grid_pos.x+32,grid_pos.y) in grid_map:
			print("QQ Maw is Big, Neighboring Cell Occupied at : ", Vector2(grid_pos.x+32,grid_pos.y) )
			return 
	
	if sun_points >= -99999: 
		
		print("Have enough sun, placing plant ")
		#Maw Handling, occupies two cells
		if "Maw" in plant_instance.name:
			plant_instance.position = Vector2(grid_pos.x+16,grid_pos.y)
			grid_map[grid_pos] = plant_instance
			grid_map[Vector2(grid_pos.x+32,grid_pos.y)] = plant_instance
			#Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x+32,grid_pos.y))
			
		else: #Only occupies one cell
			plant_instance.position = Vector2(grid_pos.x,grid_pos.y)
			grid_map[grid_pos] = plant_instance
	
		#Add To The GameLayer 
		get_parent().get_node("GameLayer").add_child(plant_instance)

		
		#Play the sound
		AudioManager.create_2d_audio_at_location(plant_instance.position, SoundEffect.SOUND_EFFECT_TYPE.DEMON_SUMMON)

	else:
		print("Not enough sun points!")
	
	print("QQ Plant Was Placed At " , plant_instance.position)
	
	
# Place the selected plant on the grid
func place_plant(grid_pos: Vector2):
	
	print("About to Place Plant")
	if(grid_pos.x<769 && grid_pos.y<304 && grid_pos.y > 48):
		pass
	else:
		print("Grid Pos ", grid_pos, " is OUTTA BOUNDS")
		return 
	
	# Dynamically get the selected plant	
	selected_plant_scene = get_selected_plant()  
	
	if selected_plant_scene == null:
		print("No plant selected!")
		return
	
	var plant_instance = selected_plant_scene.instantiate()
	#print("Will Make PPName From ",plant_instance.name)
	plant_instance.name = generate_unique_name(plant_instance.name)
	if "Alternate" in get_parent().name :
		plant_instance.add_to_group("Green")
	else:
		plant_instance.add_to_group("Purple")
	
	#Check if Spot is Occupied
	if grid_pos in grid_map:
		print(grid_pos , " QQ Cell already occupied!")
		return
	
	#Maw is larger, check neighboring cell
	if  "Maw" in plant_instance.name:
		if Vector2(grid_pos.x+32,grid_pos.y) in grid_map:
			print("QQ Maw is Big, Neighboring Cell Occupied at : ", Vector2(grid_pos.x+32,grid_pos.y) )
			return 
		else:
			Global.game_controller.place_empty_in_alt_scene(Vector2(grid_pos.x+32,grid_pos.y))

	
	#Get The Cost 
	plant_cost = plant_instance.get_cost()
	print("Plant CCost is : ", plant_cost)
	
	if sun_points >= plant_cost: 
		
		print("Have enough sun, placing plant ")
		#Maw Handling, occupies two cells
		if "Maw" in plant_instance.name:
			plant_instance.position = Vector2(grid_pos.x+16,grid_pos.y)
			grid_map[grid_pos] = plant_instance
			grid_map[Vector2(grid_pos.x+32,grid_pos.y)] = plant_instance
			
		else: #Only occupies one cell
			plant_instance.position = Vector2(grid_pos.x,grid_pos.y)
			grid_map[grid_pos] = plant_instance
	
		#Add To The GameLayer 
		get_parent().get_node("GameLayer").add_child(plant_instance)

		#Reduce Sun Points
		sun_points -= plant_cost
		get_parent().get_node("UILayer/SunCounter/HBoxContainer/BloodCounter").text = "Blood: " + str(sun_points)
		
		#Play the sound
		AudioManager.create_2d_audio_at_location(plant_instance.position, SoundEffect.SOUND_EFFECT_TYPE.DEMON_SUMMON)
		#$PlacePlantAudioPlayer.play()
		#print("PPLant name is ", plant_instance.name)
		if "Sunflower" in plant_instance.name:
			print("Selected Plant Scene is : ", plant_instance.name)
			#TODO change to sunflower_placed
			plant_placed.emit()
			Global.incrementSunflowerCount()
			pass
		elif "Peashooter" in plant_instance.name:
			spyder_placed.emit()
			pass
		elif "Walnut" in plant_instance.name:
			walnut_placed.emit()
			pass
		elif "Bomb" in plant_instance.name:
			eyeBomb_placed.emit()
		elif "EggWorm" in plant_instance.name:
			eggWorm_placed.emit()
		elif "Hive" in plant_instance.name:
			wasp_placed.emit()
		elif "Maw" in plant_instance.name:
			maw_placed.emit()
			
		#print("Selected Plant Scene is : ", plant_instance)
		
		
		# Clear preview after successful placement, or do this when deselect Hit 
		#selection_menu.clear_preview()
		
	else:
		print("Not enough sun points!")
	
	print("QQ Plant Was Placed At " , plant_instance.position)

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
	
#Add sun to total 
func add_sun(amount):
	print("Add SunWW: " , amount)
	sun_points += amount
	get_parent().get_node("UILayer/SunCounter/HBoxContainer/BloodCounter").text = "Blood: " + str(sun_points)
	
# Play the sun collection sound 
func play_sun_collect():
	#$SunCollectPlayer.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.SUN_COLLECT)
	
# Set the starting sun amount depending on level 
func _on_SetSun_timeout():
	if(get_parent().name == "Main"):
		#sun_points = 300 #75
		get_parent().get_node("UILayer/SunCounter/HBoxContainer/BloodCounter").text = "Blood: " + str(sun_points)
	else:
		#sun_points = 900 #700
		get_parent().get_node("UILayer/SunCounter/HBoxContainer/BloodCounter").text = "Blood: " + str(sun_points)


	
