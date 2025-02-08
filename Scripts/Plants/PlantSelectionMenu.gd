extends Control
#PlantSelectionMenu.gd

var selected_plant = sunflower_scene  # Holds the currently selected plant scene
var preview_sprite: AnimatedSprite = null  # Holds the sprite currently being previewed 
#var is_previewing: bool = false

var preview_sprites: Array = [] # Holds array of preview sprites 
var is_previewing: bool = false # Whether or not we are currently previewing 


# Preload the plant scenes
var peashooter_scene = preload("res://Scenes/PlantScenes/Peashooter.tscn")
var sunflower_scene = preload("res://Scenes/PlantScenes/Sunflower.tscn")
var walnut_scene = preload("res://Scenes/PlantScenes/WalnutTree.tscn")
var maw_scene = preload("res://Scenes/PlantScenes/Maw.tscn")
var egg_scene = preload("res://Scenes/PlantScenes/EggWorm.tscn")
var bomb_scene = preload("res://Scenes/PlantScenes/EyeBomb.tscn")
var hive_scene = preload("res://Scenes/PlantScenes/Hive.tscn")

# Label for Current Plant 
var currentPlantLabel
var deselectText = " PRESS [X] TO DESELECT"

onready var preview_container = Node2D.new()

func _ready():
	set_process_input(true)
	
	# Connect button signals to their respective functions
	var root = get_parent().get_parent().get_name()
	
	currentPlantLabel = $VBoxContainer/CurrentPlantLabel
	
	var SunFlowerButton = $VBoxContainer/HBoxContainer/SunflowerButton
	var PeaShooterButton = $VBoxContainer/HBoxContainer/PeashooterButton2
	var WalnutButton = $VBoxContainer/HBoxContainer/WalnutButton
	var EyeButton = $VBoxContainer/HBoxContainer/EyeButton
	var EggButton = $VBoxContainer/HBoxContainer/EggButton
	var MawButton = $VBoxContainer/HBoxContainer/MawButton
	var HiveButton = $VBoxContainer/HBoxContainer/HiveButton
	
	# Make sure the appropirate plants are available per level
	if root == "Main": #or root == "Level2":
		assert(PeaShooterButton.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert(SunFlowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		WalnutButton.visible = true
		MawButton.visible = false
		EggButton.visible = false
		EyeButton.visible = false
		
	elif root == "Level2":
		assert(PeaShooterButton.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert(SunFlowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		#assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		MawButton.visible = false
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
	create_preview(peashooter_scene)
	print("Peashooter selected")
	currentPlantLabel.text = "SPIDER SELECTED " + deselectText
	$UIClickAudio.play()

# Plays Sound and Makes the Sunflower the current selected plant, changing label & preview image 
func _on_SunflowerButton_pressed():
	selected_plant = sunflower_scene
	create_preview(sunflower_scene)
	print("Sunflower selected")
	currentPlantLabel.text = "EVIL EYE SELECTED " + deselectText
	$UIClickAudio.play()

# Plays Sound and Makes the Walnut the current selected plant, changing label & preview image 
func _on_WalnutButton_pressed():
	selected_plant = walnut_scene
	create_preview(walnut_scene)
	print("Walnut selected")
	currentPlantLabel.text = "OCCULAR SPINE SELECTED " + deselectText
	$UIClickAudio.play()

# Plays Sound and Makes the Maw the current selected plant, changing label & preview image 
func _on_MawButton_pressed():
	selected_plant = maw_scene
	create_preview(maw_scene)
	print("Maw Selected")
	currentPlantLabel.text = "MAW SELECTED " + deselectText
	$UIClickAudio.play()

# Plays Sound and Makes the EggWorm the current selected plant, changing label & preview image 
func _on_EggButton_pressed():
	selected_plant = egg_scene
	create_preview(egg_scene)
	print("EggWorm Selected")
	currentPlantLabel.text = "EGGWORM SELECTED " + deselectText
	$UIClickAudio.play()

# Plays Sound and Makes the EyeBomb the current selected plant, changing label & preview image 
func _on_EyeButton_pressed():
	selected_plant = bomb_scene
	create_preview(bomb_scene)
	print("EyeBomb Selected")
	currentPlantLabel.text = "EYE MINE SELECTED " + deselectText
	$UIClickAudio.play()
	
# Plays Sound and Makes the Hive the current selected plant, changing label & preview image 
func _on_HiveButton_pressed():
	selected_plant = hive_scene
	create_preview(hive_scene)
	print("Hive Selected")
	currentPlantLabel.text = "HIVE SELECTED " + deselectText
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
			
			# Store original position and print it
			var original_pos = Vector2(child.position.x, child.position.y)
			preview_sprite.set_meta("original_offset", original_pos)
			
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

