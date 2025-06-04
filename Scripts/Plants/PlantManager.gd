extends Node2D
#PlantManager.gd

# Get a reference to the plant selection menu 
@onready var selection_menu = get_parent().get_node("PlantSelectionMenu")

var selected_plant_scene = null  # Holds the selected plant scene
var grid_size = 32 # Defines the size of each grid cell 
var grid_map = {}  # Dictionary to store occupied cells
@export var sun_points = 200 # Holds how many sun points we have currently 
var plant_cost = 25  # Holds the cost of the currently selected plant 
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
	return get_parent().get_node("PlantSelectionMenu").selected_plant


# Handles Player Interaction with the Plant Menu 
func _input(event):
	# Dynamically get the selected plant	
	selected_plant_scene = get_selected_plant()  
	
	if event is InputEventMouseButton and event.pressed:
		# If they left click, grab the positon and place a plant there 
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			var grid_pos = mouse_pos_to_grid(mouse_pos)
			grid_pos = Vector2(grid_pos.x+16,grid_pos.y+16)

			if selected_plant_scene:
				var temp_instance = selected_plant_scene.instantiate()
				
				var cost = temp_instance.get_cost()
				print("Temp instance is ", temp_instance.get_name(), " with a cost of " , cost)
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
			
			# Place the plant assuming it's within bounds of the level
			if(parentName == "Main"):
				if(grid_pos.x<769 && grid_pos.y<208 && grid_pos.y > 80):
					print("Place Plant " , grid_pos)
					place_plant(grid_pos)
			elif(parentName == "Level3"):
				print("Grid map size is ", grid_map.size())
				if grid_map.size() == 0 && selected_plant_scene:
					var temp_instance = selected_plant_scene.instantiate()
					if "Egg" in temp_instance.get_name():
						print("Place Plant1 " , grid_pos)
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
							place_plant(grid_pos)
					else:
						pass
				else:
					print("Place Plant2 " , grid_pos)
					place_plant(grid_pos)
				
			else:
				if(grid_pos.x<769 && grid_pos.y<240 && grid_pos.y > 49):
					print("Otro Place Plant " , grid_pos)
					place_plant(grid_pos)

# Convert mouse position to a grid cell position
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size

# Clear a space for a new plant to go 
func clear_space(passed_grid_pos):
	print("Erase Plant??? ", passed_grid_pos)
	var new_passed_grid_pos = mouse_pos_to_grid(passed_grid_pos)
	new_passed_grid_pos = Vector2(new_passed_grid_pos.x,new_passed_grid_pos.y+64)
	print("Erase PLANT ", new_passed_grid_pos)
	grid_map.erase(passed_grid_pos)
	
# Place the selected plant on the grid
func place_plant(grid_pos: Vector2):
	
	print("About to Place Plant")
	if(grid_pos.x<769 && grid_pos.y<240 && grid_pos.y > 31):
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
	
	
	#Check if Spot is Occupied
	if grid_pos in grid_map:
		print("Cell already occupied!")
		return
	
	#Maw is larger, check neighboring cell
	if  "Maw" in plant_instance.name:
		if Vector2(grid_pos.x+32,grid_pos.y) in grid_map:
			print("Maw is Big, Neighboring Cell Occupied")
			return 
		
	
	#Get The Cost 
	plant_cost = plant_instance.get_cost()
	
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
		get_parent().get_node("UILayer/SunCounter/Label").text = "Blood: " + str(sun_points)
		
		#Play the sound
		
		$PlacePlantAudioPlayer.play()
		#print("PPLant name is ", plant_instance.name)
		if "Sunflower" in plant_instance.name:
			print("Selected Plant Scene is : ", plant_instance.name)
			#TODO change to sunflower_placed
			plant_placed.emit()
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
	
	print("Plant Was Placed ")

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
	#print("Add Sun: " , amount)
	sun_points += amount
	get_parent().get_node("UILayer/SunCounter/Label").text = "Blood: " + str(sun_points)
	
# Play the sun collection sound 
func play_sun_collect():
	$SunCollectPlayer.play()
	
# Set the starting sun amount depending on level 
func _on_SetSun_timeout():
	if(get_parent().name == "Main"):
		#sun_points = 300 #75
		get_parent().get_node("UILayer/SunCounter/Label").text = "Blood: " + str(sun_points)
	else:
		#sun_points = 900 #700
		get_parent().get_node("UILayer/SunCounter/Label").text = "Blood: " + str(sun_points)
