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
			else:
				if(grid_pos.x<769 && grid_pos.y<288 && grid_pos.y > 31):
					print("INCORRECT Place Plant " , grid_pos)
					place_plant(grid_pos)

# Convert mouse position to a grid cell position
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size

# Clear a space for a new plant to go 
func clear_space(passed_grid_pos):
	var new_passed_grid_pos = mouse_pos_to_grid(passed_grid_pos)
	new_passed_grid_pos = Vector2(new_passed_grid_pos.x,new_passed_grid_pos.y+64)
	grid_map.erase(new_passed_grid_pos)
	
# Place the selected plant on the grid
func place_plant(grid_pos: Vector2):
	
	print("About to Place Plant")
	
	# Dynamically get the selected plant	
	selected_plant_scene = get_selected_plant()  
	
	if selected_plant_scene == null:
		print("No plant selected!")
		return
	
	var plant_instance = selected_plant_scene.instantiate()
	
	#Check if Spot is Occupied
	if grid_pos in grid_map:
		print("Cell already occupied!")
		return
	
	#Maw is larger, check neighboring cell
	if plant_instance.name == "Maw":
		if Vector2(grid_pos.x+32,grid_pos.y) in grid_map:
			print("Maw is Big, Neighboring Cell Occupied")
			return 
		
	
	#Get The Cost 
	plant_cost = plant_instance.get_cost()
	
	if sun_points >= plant_cost: 
		
		print("Have enough sun, placing plant ")
		#Maw Handling, occupies two cells
		if plant_instance.name == "Maw":
			plant_instance.position = Vector2(grid_pos.x+16,grid_pos.y)
			grid_map[grid_pos] = plant_instance
			grid_map[Vector2(grid_pos.x+16,grid_pos.y)] = plant_instance
			
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
		#print("Selected Plant Scene is : ", plant_instance)
		
		
		# Clear preview after successful placement, or do this when deselect Hit 
		#selection_menu.clear_preview()
		
	else:
		print("Not enough sun points!")
	
	print("Plant Was Placed ")

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
