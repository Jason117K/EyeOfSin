extends Control
#PlantSelectionMenu.gd

var selected_plant = sunflower_scene  # Holds the currently selected plant scene
var preview_sprite: AnimatedSprite = null  # Add type hint for clarity
var is_previewing: bool = false
#var preview_container: Node2D

# Preload the plant scenes
var peashooter_scene = preload("res://Scenes/PlantScenes/Peashooter.tscn")
var sunflower_scene = preload("res://Scenes/PlantScenes/Sunflower.tscn")
var walnut_scene = preload("res://Scenes/PlantScenes/WalnutTree.tscn")
var maw_scene = preload("res://Scenes/PlantScenes/Maw.tscn")
var egg_scene = preload("res://Scenes/PlantScenes/EggWorm.tscn")
var bomb_scene = preload("res://Scenes/PlantScenes/EyeBomb.tscn")


onready var preview_container = Node2D.new()

func _ready():
	# Connect button signals to their respective functions
	var root = get_parent().get_parent().get_name()
	
	if root == "Main": #or root == "Level2":
		assert($HBoxContainer/PeashooterButton2.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert($HBoxContainer/SunflowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		$HBoxContainer/WalnutButton.visible = true
		$HBoxContainer/MawButton.visible = false
		$HBoxContainer/EggButton.visible = false
		$HBoxContainer/EyeButton.visible = false
		
	elif root == "Level2":
		assert($HBoxContainer/PeashooterButton2.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert($HBoxContainer/SunflowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		#assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		$HBoxContainer/MawButton.visible = false
	else: #root = Level3
		assert($HBoxContainer/PeashooterButton2.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert($HBoxContainer/SunflowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		#assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		$HBoxContainer/MawButton.visible = true
		
	add_child(preview_container)
	preview_container.z_index = 100  # Ensure preview appears above other elements

	#print(root)

	
func _on_PeashooterButton_pressed():
	selected_plant = peashooter_scene
	create_preview(peashooter_scene)
	("Peashooter selected")
	$UIClickAudio.play()
	
func _on_SunflowerButton_pressed():
	selected_plant = sunflower_scene
	create_preview(sunflower_scene)
	print("Sunflower selected")
	$UIClickAudio.play()
	
func _on_WalnutButton_pressed():
	selected_plant = walnut_scene
	create_preview(walnut_scene)
	print("Walnut selected")
	$UIClickAudio.play()


func _on_MawButton_pressed():
	selected_plant = maw_scene
	create_preview(maw_scene)
	print("Maw Selected")
	$UIClickAudio.play()


func _on_EggButton_pressed():
	selected_plant = egg_scene
	create_preview(egg_scene)
	print("EggWorm Selected")
	$UIClickAudio.play()



func _on_EyeButton_pressed():
	selected_plant = bomb_scene
	create_preview(bomb_scene)
	print("EyeBomb Selected")
	$UIClickAudio.play()


func create_preview(plant_scene):
	clear_preview()  # Clear any existing preview
	
	# Instance the plant scene
	var temp_plant = plant_scene.instance()
	
	# Get the AnimatedSprite node from the plant
	#var sprite_node = find_animated_sprite(temp_plant)
	var sprite_node = find_preview_sprite(temp_plant)
	if sprite_node:
		preview_sprite = sprite_node.duplicate()
		preview_sprite.modulate = Color(1, 1, 1, 0.5)  # Make transparent
		
		# Set the scale based on the plant type
		if "Sunflower" in plant_scene.resource_path:
			preview_sprite.scale = Vector2(0.5, 0.5)  # Adjust this value as needed
		elif "Peashooter" in plant_scene.resource_path:
			preview_sprite.scale = sprite_node.scale  # Keep peashooter's existing scale
		elif "EyeBomb" in plant_scene.resource_path:
			preview_sprite.scale = Vector2(0.1,0.1) # Keep peashooter's existing scale
		elif "WalnutTree" in plant_scene.resource_path:
			preview_sprite.scale = Vector2(0.1,0.1) # Keep peashooter's existing scale
		elif "Maw" in plant_scene.resource_path:
			preview_sprite.scale = Vector2(0.8,0.8) # Keep peashooter's existing scale
		else:
			preview_sprite.scale = sprite_node.scale  # Keep existing scale
		
		preview_container.add_child(preview_sprite)
		is_previewing = true
	
	# Clean up temporary instance
	temp_plant.queue_free()

func clear_preview():
	if preview_sprite:
		preview_sprite.queue_free()
		preview_sprite = null
	is_previewing = false
	
func find_preview_sprite(node):
	# Recursively search for AnimatedSprite node
	if node is AnimatedSprite:
		if("Preview" in node.name):
			return node
			
	return null
	
# Add _process to update preview position
func _process(_delta):
	if is_previewing and preview_sprite:
		preview_sprite.global_position = get_global_mouse_position()


func find_animated_sprite(node):
	# Recursively search for AnimatedSprite node
	if node is AnimatedSprite:
		return node
	
	for child in node.get_children():
		var result = find_animated_sprite(child)
		if result:
			return result
	return null
