extends Node2D
#PlantManager.gd

onready var selection_menu = get_parent().get_node("PlantSelectionMenu")

var selected_plant_scene = null  # Updated: Holds the selected plant scene
var grid_size = 32 #64  # Assuming each grid cell is 64x64 pixels
var grid_map = {}  # Dictionary to store occupied cells
var sun_points = 200
var plant_cost = 25

# Updated: Reference the PlantSelectionMenu dynamically
func get_selected_plant():
	return get_parent().get_node("PlantSelectionMenu").selected_plant

func ready():
	#print(get_parent().get_name())
	
	pass
#384,256



func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			#print("Clicked mouse_pos is : ", mouse_pos)

			var grid_pos = mouse_pos_to_grid(mouse_pos)
			#print("Clicked grid_pos is : ", grid_pos)

			grid_pos = Vector2(grid_pos.x+16,grid_pos.y+16)
			#print(get_parent().name)
			
			
			# Add early return if no sun points
			if selected_plant_scene:
				#print("SEKE PLANETR IS")
				var temp_instance = selected_plant_scene.instance()
				var cost = temp_instance.get_cost()
				temp_instance.queue_free()
				
				if sun_points < cost:
					selection_menu.clear_preview()
					return
			
			
			
			if(get_parent().name == "Main"):
				if(grid_pos.x<769 && grid_pos.y<321 && grid_pos.y > 128):
					#print("Place Plant " , grid_pos)
					place_plant(grid_pos)
			else:
				if(grid_pos.x<769 && grid_pos.y<288 && grid_pos.y > 31):
					#print("Place Plant " , grid_pos)
					place_plant(grid_pos)

# Convert mouse position to a grid cell position
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size

func clear_space(passed_grid_pos):
	var new_passed_grid_pos = mouse_pos_to_grid(passed_grid_pos)
	new_passed_grid_pos = Vector2(new_passed_grid_pos.x,new_passed_grid_pos.y+64)
	#print("New Passed Grid Pos : ",new_passed_grid_pos)
	#print("Grid Map is : ", grid_map)
	grid_map.erase(new_passed_grid_pos)
	#print("Grid Map is : ", grid_map)
	

func get_cost(this_selected_plant_scene):
	#print(this_selected_plant_scene)
	if("Sunflower" in this_selected_plant_scene.name):
		plant_cost = 25
	if("Peashooter" in this_selected_plant_scene.name):
		plant_cost = 50
	if("Walnut" in this_selected_plant_scene.name):
		plant_cost = 75

# Place the selected plant on the grid
func place_plant(grid_pos: Vector2):
	
	#Check if Spot is Occupied
	if grid_pos in grid_map:
		print("Cell already occupied!")
		return
		
	# Dynamically get the selected plant	
	selected_plant_scene = get_selected_plant()  
	
	if selected_plant_scene == null:
		print("No plant selected!")
		return
	
	#Get The Cost 
	var plant_instance = selected_plant_scene.instance()
	get_cost(plant_instance)
	plant_cost = plant_instance.get_cost()
	
	if sun_points >= plant_cost: 
		
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
		
		# Clear preview after successful placement, or do this when deselect Hit 
		#selection_menu.clear_preview()
		
	else:
		print("Not enough sun points!")

func add_sun(amount):
	#print("Add Sun: " , amount)
	sun_points += amount
	get_parent().get_node("UILayer/SunCounter/Label").text = "Blood: " + str(sun_points)
	
func play_sun_collect():
	$SunCollectPlayer.play()
	


func _on_SetSun_timeout():
	if(get_parent().name == "Main"):
		sun_points = 300 #75
		get_parent().get_node("UILayer/SunCounter/Label").text = "Blood: " + str(sun_points)
	else:
		sun_points = 900 #700
		get_parent().get_node("UILayer/SunCounter/Label").text = "Blood: " + str(sun_points)

