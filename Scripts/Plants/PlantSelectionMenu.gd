extends Control
#PlantSelectionMenu.gd

var selected_plant = sunflower_scene  # Holds the currently selected plant scene
var preview_sprite: AnimatedSprite = null  # Holds the sprite currently being previewed 
#var is_previewing: bool = false

var preview_sprites: Array = [] # Holds array of preview sprites 
var is_previewing: bool = false # Whether or not we are currently previewing 


# Preload the plant scenes
var peashooter_scene = preload("res://Scenes/PlantScenes/Peashooter.tscn")
var sunflower_scene := preload("res://Scenes/PlantScenes/Sunflower.tscn")
var walnut_scene = preload("res://Scenes/PlantScenes/WalnutTree.tscn")
var maw_scene = preload("res://Scenes/PlantScenes/Maw.tscn")
var egg_scene = preload("res://Scenes/PlantScenes/EggWorm.tscn")
var bomb_scene = preload("res://Scenes/PlantScenes/EyeBomb.tscn")
var hive_scene = preload("res://Scenes/PlantScenes/Hive.tscn")

# Label for Current Plant 
var currentPlantLabel
var currentPlantCost
var deselectText = " PRESS [X] TO DESELECT"

onready var preview_container = Node2D.new()


var sunFlowerCostLabel
var peaShooterCostLabel
var walnutCostLabel
var eyeCostLabel 
var eggCostLabel
var mawCostLabel
var hiveCostLabel 


func _ready():

	set_process_input(true)
	
	# Connect button signals to their respective functions
	var root = get_parent().get_name()
	
	#Set Up Label for Displaying Current Plant
	currentPlantLabel = $CurrentPlantLabel
	
	var temp_instance
	
	var SunFlowerButton = $VBoxContainer/HBoxContainer/Sunflower/SunflowerButton
	sunFlowerCostLabel = $VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel
	temp_instance = sunflower_scene.instance()
	sunFlowerCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	var PeaShooterButton = $VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2
	peaShooterCostLabel = $VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel
	temp_instance = peashooter_scene.instance()
	peaShooterCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	var WalnutButton = $VBoxContainer/HBoxContainer/Walnut/WalnutButton
	walnutCostLabel = $VBoxContainer/HBoxContainer/Walnut/WalnutLabel
	temp_instance = walnut_scene.instance()
	walnutCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	var EyeButton = $VBoxContainer/HBoxContainer/Eye/EyeButton
	eyeCostLabel = $VBoxContainer/HBoxContainer/Eye/EyeLabel
	temp_instance = bomb_scene.instance()
	eyeCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()		
	
	var EggButton = $VBoxContainer/HBoxContainer/Egg/EggButton
	eggCostLabel = $VBoxContainer/HBoxContainer/Egg/EggLabel
	temp_instance = egg_scene.instance()
	eggCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	var MawButton = $VBoxContainer/HBoxContainer/Maw/MawButton
	mawCostLabel = $VBoxContainer/HBoxContainer/Maw/MawLabel
	temp_instance = maw_scene.instance()
	mawCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
			
	var HiveButton = $VBoxContainer/HBoxContainer/Hive/HiveButton
	hiveCostLabel = $VBoxContainer/HBoxContainer/Hive/HiveLabel
	temp_instance = hive_scene.instance()
	hiveCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()		
	
	# Make sure the appropirate plants are available per level
	if root == "Main": #or root == "Level2":
		assert(PeaShooterButton.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		
		assert(SunFlowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		
		$VBoxContainer/HBoxContainer/Egg/EggLabel.visible = false
		EggButton.visible = false

		$VBoxContainer/HBoxContainer/Eye/EyeLabel.visible = false
		EyeButton.visible = false

		$VBoxContainer/HBoxContainer/Maw/MawLabel.visible = false
		MawButton.visible = false

		$VBoxContainer/HBoxContainer/Hive/HiveLabel.visible = false
		HiveButton.visible = false
		
		
	elif root == "Level2":
		assert(PeaShooterButton.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert(SunFlowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		#assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		MawButton.visible = false
		mawCostLabel.visible = false
	else: #root = Level3
		assert(PeaShooterButton.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert(SunFlowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		#assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		MawButton.visible = true
		
	add_child(preview_container)
	preview_container.z_index = 100  # Ensure preview appears above other elements

	#print(root)
	
	
# Handle Deselection
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_X:
			clear_preview()
			

# Plays Sound and Makes the Peashooter the current selected plant, changing label & preview image 
func _on_PeashooterButton_pressed():
	selected_plant = peashooter_scene
	var temp_instance = peashooter_scene.instance()
	create_preview(peashooter_scene)
	
	currentPlantLabel.text = "SPIDER SELECTED " + deselectText
	currentPlantCost = $VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel
	currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	print("Peashooter selected")
	$UIClickAudio.play()

# Plays Sound and Makes the Sunflower the current selected plant, changing label & preview image 
func _on_SunflowerButton_pressed():
	
	selected_plant = sunflower_scene
	var temp_instance = sunflower_scene.instance()
	create_preview(sunflower_scene)
	
	currentPlantLabel.text = "EVIL EYE SELECTED " + deselectText
	currentPlantCost = $VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel
	#currentPlantCost.text = str(temp_instance.get_name(), "IS", temp_instance.get_cost())
	temp_instance.queue_free()
	
	print("3Label text is ", sunFlowerCostLabel.text)
	print("Sunflower selected", temp_instance.get_name())
	$UIClickAudio.play()

# Plays Sound and Makes the Walnut the current selected plant, changing label & preview image 
func _on_WalnutButton_pressed():
	selected_plant = walnut_scene
	var temp_instance = walnut_scene.instance()
	create_preview(walnut_scene)
	
	currentPlantLabel.text = "OCCULAR SPINE SELECTED " + deselectText
	currentPlantCost = $VBoxContainer/HBoxContainer/Walnut/WalnutLabel
	currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
		
	print("Walnut selected")
	$UIClickAudio.play()

# Plays Sound and Makes the Maw the current selected plant, changing label & preview image 
func _on_MawButton_pressed():
	selected_plant = maw_scene
	var temp_instance = maw_scene.instance()	
	create_preview(maw_scene)
	
	currentPlantLabel.text = "MAW SELECTED " + deselectText
	currentPlantCost = $VBoxContainer/HBoxContainer/Maw/MawLabel
	currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
		
	print("Maw Selected")
	$UIClickAudio.play()

# Plays Sound and Makes the EggWorm the current selected plant, changing label & preview image 
func _on_EggButton_pressed():
	selected_plant = egg_scene
	create_preview(egg_scene)
	var temp_instance = egg_scene.instance()
		
	currentPlantLabel.text = "EGGWORM SELECTED " + deselectText
	currentPlantCost = $VBoxContainer/HBoxContainer/Egg/EggLabel
	currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	print("EggWorm Selected")
	$UIClickAudio.play()

# Plays Sound and Makes the EyeBomb the current selected plant, changing label & preview image 
func _on_EyeButton_pressed():
	selected_plant = bomb_scene
	create_preview(bomb_scene)
	var temp_instance = bomb_scene.instance()
		
	currentPlantLabel.text = "EYE MINE SELECTED " + deselectText
	currentPlantCost = $VBoxContainer/HBoxContainer/Eye/EyeLabel
	currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	print("EyeBomb Selected")
	$UIClickAudio.play()
	
# Plays Sound and Makes the Hive the current selected plant, changing label & preview image 
func _on_HiveButton_pressed():
	selected_plant = hive_scene
	create_preview(hive_scene)
	var temp_instance = hive_scene.instance()
		
	currentPlantLabel.text = "HIVE SELECTED " + deselectText
	currentPlantCost = $VBoxContainer/HBoxContainer/Hive/HiveLabel
	currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
		
	print("Hive Selected")
	$UIClickAudio.play()
	
# Creates a transparent preview image for a given plant scene 
func create_preview(plant_scene):
	# Clear the last preview 
	clear_preview()
	
	var temp_plant = plant_scene.instance()
	var preview_node = find_preview_nodes(temp_plant)
	
	if preview_node:
		# Duplicate all child sprites
		for child in preview_node.get_children():
			# Create the preview sprite and make it semi-transparent 
			var preview_sprite = child.duplicate()
			preview_sprite.modulate = Color(1, 1, 1, 0.5)
			preview_sprite.scale = Vector2(2,2)
			
			# Store original position and print it
			var original_pos = Vector2(child.position.x, child.position.y)
			preview_sprite.set_meta("original_offset", original_pos)
			print(preview_container.name)
			
			# Add the preview sprite to the container and array 
			preview_container.add_child(preview_sprite)
			preview_sprites.append(preview_sprite)
		
		is_previewing = true

	
	temp_plant.queue_free()
	
# Clears the current preview image 
func clear_preview():
	for sprite in preview_sprites:
		if sprite:
			sprite.queue_free()
	preview_sprites.clear()
	currentPlantLabel.text = ""
	is_previewing = false

# Gets all the previewNodes
func find_preview_nodes(node):
	if node.name == "PreviewNodes":
		return node
	
	for child in node.get_children():
		var result = find_preview_nodes(child)
		if result:
			return result
	return null
	
	
func find_preview_sprite(node):
	# Recursively search for AnimatedSprite node
	if node is AnimatedSprite:
		if("Preview" in node.name):
			return node
			
	return null
	
# Drags the preview sprite around with the cursor 
func _process(_delta):
	if is_previewing and not preview_sprites.empty():
		var base_pos = get_global_mouse_position()

		for sprite in preview_sprites:
			if sprite and sprite.has_meta("original_offset"):
				var offset = sprite.get_meta("original_offset") as Vector2
				sprite.global_position = base_pos + offset

func find_animated_sprite(node):
	# Recursively search for AnimatedSprite node
	if node is AnimatedSprite:
		return node
	
	for child in node.get_children():
		var result = find_animated_sprite(child)
		if result:
			return result
	return null

