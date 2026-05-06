extends Control
#PlantSelectionMenu.gd

@export var is_alt := false
var swap_ability := preload("res://_Entities/SwapAbilities/blood_rain.tscn")
var swap_ability_instance : Node

var root
var selected_plant = sunflower_scene  # Holds the currently selected plant scene
var preview_sprite: AnimatedSprite2D = null  # Holds the sprite currently being previewed 
#var is_previewing: bool = false

var preview_sprites: Array = [] # Holds array of preview sprites 
var is_previewing: bool = false # Whether or not we are currently previewing 
var canRemove := false 
var purple_scene := true 

signal clicked_Eye
signal codex_clicked

# Preload the plant scenes
var peashooter_scene = preload("res://_Entities/Demons/_Crawler/Crawler.tscn")
var sunflower_scene := preload("res://_Entities/Demons/_Occulum/Occulum.tscn")
var walnut_scene = preload("res://_Entities/Demons/_CagedOculum/WalnutTree.tscn")
var maw_scene = preload("res://_Entities/Demons/_Maw/Maw.tscn")
var egg_scene = preload("res://_Entities/Demons/_Wyrm/EggWorm.tscn")
var hive_scene = preload("res://_Entities/Demons/_Hive/Hive.tscn")
var heart_scene = preload("res://_Entities/Demons/_HeartDemon/HeartDemon.tscn")
var portal_scene = preload("res://_Entities/SpecialElementsPortal/Portal.tscn")
var green_portal_icon = preload("res://_Assets/UI/DemonCard_Portal_GreenButton.png")
var purple_portal_icon = preload("res://_Assets/UI/DemonCard_Portal.png")

#var hive_scene = preload("res://Scenes/PlantScenes/phantom_hive.tscn")

# Label for Current Plant 
var currentPlantLabel
var currentPlantCost
var deselectText = " PRESS [X] TO DESELECT"

@onready var preview_container = Node2D.new()
@onready var panelContainer = $PanelContainer
@onready var portalButton := $PanelContainer/VBoxContainer/HBoxContainer/Portal/PortalButton

var SunFlowerButton
var WalnutButton
var EggButton
var MawButton
var HiveButton
var PeaShooterButton


var sunFlowerCostLabel
var sunflowerCost := 50
var peaShooterCostLabel
var walnutCostLabel
var eyeCostLabel 
var eggCostLabel
var mawCostLabel
var hiveCostLabel 

var canSwapScenes = false

# Thickness of the highlight border (in pixels)
@export var highlight_border_thickness: int = 4

# Color of the highlight border
@export var highlight_border_color: Color = Color.RED

var doubleSpeed = false 

func _ready():
	swap_ability_instance = swap_ability.instantiate()
	#print("swap_ability_instance is : ",  swap_ability_instance)
	get_parent().call_deferred("add_child", swap_ability_instance)
	#print("swap_ability_i")
#	swap_ability_instance._ready()
	
	setPanelContainerWidth(100)
	#Global.plant_selection_menu = self
	if is_alt:
		Global.plant_selection_menu_alt = self
	else:
		Global.plant_selection_menu = self
	Global.resetSunflowerCount()

	#add_button_highlight
	set_process_input(true)
	
	# Connect button signals to their respective functions
	root = get_parent().get_name()
	
	#Set Up Label for Displaying Current Plant
	currentPlantLabel = $CurrentPlantLabel
	
	var temp_instance
	
	SunFlowerButton = $PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton
	sunFlowerCostLabel = $PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel
	temp_instance = sunflower_scene.instantiate()
	#print("Temp Instance.get_cost() is : ", str(temp_instance.get_cost()))
	sunFlowerCostLabel.text = str(temp_instance.get_cost())
	
	temp_instance.queue_free()
	
	#add_button_highlight(SunFlowerButton)
	
	PeaShooterButton = $PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2
	peaShooterCostLabel = $PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel
	temp_instance = peashooter_scene.instantiate()
	peaShooterCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	WalnutButton = $PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton
	walnutCostLabel = $PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel
	temp_instance = walnut_scene.instantiate()
	walnutCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	
	EggButton = $PanelContainer/VBoxContainer/HBoxContainer/Egg/EggButton
	eggCostLabel = $PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel
	temp_instance = egg_scene.instantiate()
	eggCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	MawButton = $PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton
	mawCostLabel = $PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel
	temp_instance = maw_scene.instantiate()
	mawCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
			
	HiveButton = $PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton
	hiveCostLabel = $PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel
	temp_instance = hive_scene.instantiate()
	hiveCostLabel.text = str(temp_instance.get_cost())
	temp_instance.queue_free()		
	
	# Make sure the appropirate plants are available per level
	if root == "Main": #or root == "Level2":
		#assert(PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))== OK)
		PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))== OK
		PeaShooterButton.visible = false 
		peaShooterCostLabel.visible = false
		WalnutButton.visible = false
		walnutCostLabel.visible = false
		
		#assert(SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))== OK)
		SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))== OK
		SunFlowerButton.visible = false
		sunFlowerCostLabel.visible = false 
		
		$PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel.visible = false
		EggButton.visible = false

		$PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel.visible = false
		MawButton.visible = false

		$PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel.visible = false
		HiveButton.visible = false
		
		
	elif root == "Level2":
		#assert(PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))== OK)
		PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))
		#assert(SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))== OK)
		SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))
		#assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		$HBoxContainer/WalnutButton.connect("pressed", Callable(self, "_on_WalnutButton_pressed"))
		MawButton.visible = false
		mawCostLabel.visible = false
		$PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel.visible = false
		EggButton.visible = false

		$PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel.visible = false
		MawButton.visible = false

		$PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel.visible = false
		HiveButton.visible = false
	elif root == "Level3":
		#assert(PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))== OK)
		PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))
		#assert(SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))== OK)
		SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))
		

		$PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel.visible = false
		MawButton.visible = false

		$PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel.visible = false
		HiveButton.visible = false
	elif root == "Level4":
	#	assert(PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))== OK)
		PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))
		#assert(SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))== OK)
		SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))
		$PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel.visible = false
		MawButton.visible = false
	else:
		assert(PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))== OK)
		PeaShooterButton.connect("pressed", Callable(self, "_on_PeashooterButton_pressed"))
		assert(SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))== OK)
		SunFlowerButton.connect("pressed", Callable(self, "_on_SunflowerButton_pressed"))
	add_child(preview_container)
	preview_container.z_index = 100  # Ensure preview appears above other elements

	#print(root)
	
	
# Handle Deselection
func _input(event):
	
	if event is InputEventKey and event.pressed:
		#print("Key Pressed")
		if event.keycode == KEY_X:
			deselect_plant()
			#clear_preview()
			#release_all_focus()
			#selected_plant = null 
		if event.keycode == KEY_Y:
			#print("Y Key Pressed")
			if canSwapScenes:
				#print("Can Swap Scenes is ", canSwapScenes)
				#Global.game_controller.swap_scenes()
				Global.swap_scenes()
			else:
				print("Can Swap Scenes is ", canSwapScenes, " no swapping possible")
		if event.keycode == KEY_1:
			print("1 Key Pressed")
			_on_SunflowerButton_pressed()
		if event.keycode == KEY_2:
			print("2 Key Pressed")
			_on_PeashooterButton_pressed()
		if event.keycode == KEY_3:
			print("3 Key Pressed")
			_on_WalnutButton_pressed()
		if event.keycode == KEY_4:
			print("4 Key Pressed")
			_on_MawButton_pressed()
		if event.keycode == KEY_5:
			print("5 Key Pressed")
			_on_EggButton_pressed()
		if event.keycode == KEY_6:
			print("6 Key Pressed")
			_on_HiveButton_pressed()			

func setPanelContainerWidth(newWidth: int):
	#print("Panel Container Dimensions is ", panelContainer.size)
	panelContainer.size.x = 71
	#print("Panel Container Dimensions is ", panelContainer.size)

		
func deselect_plant():
	clear_preview()
	release_all_focus()
	selected_plant = null 			
	setCanRemoveFalse()

# Plays Sound and Makes the Peashooter the current selected plant, changing label & preview image 
func _on_PeashooterButton_pressed():
	setCanRemoveFalse()
	selected_plant = peashooter_scene
	var temp_instance = peashooter_scene.instantiate()
	create_preview(peashooter_scene)
	
	currentPlantLabel.text = "SPIDER SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	print("Peashooter selected")
	#$UIClickAudio.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	var PeaShooterButton = $PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2
	#remove_button_highlight(PeaShooterButton)

func increaseSunflowerCost():
	sunFlowerCostLabel.text = str(50+(Global.getSunflowerCount()*5))
	
# Plays Sound and Makes the Sunflower the current selected plant, changing label & preview image 
func _on_SunflowerButton_pressed():
	setCanRemoveFalse()
	selected_plant = sunflower_scene
	var temp_instance = sunflower_scene.instantiate()
	create_preview(sunflower_scene)
	
	currentPlantLabel.text = "EVIL EYE SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel
	#currentPlantCost.text = str(temp_instance.get_name(), "IS", temp_instance.get_cost())
	sunflowerCost  += 5
	
	
	#currentPlantCost.text = "Penis"
	temp_instance.queue_free()
	
##	print("3Label text is ", sunFlowerCostLabel.text)
#	print("Sunflower selected", temp_instance.get_name())
#	$UIClickAudio.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	clicked_Eye.emit()


# Plays Sound and Makes the Walnut the current selected plant, changing label & preview image 
func _on_WalnutButton_pressed():
	selected_plant = walnut_scene
	var temp_instance = walnut_scene.instantiate()
	create_preview(walnut_scene)
	setCanRemoveFalse()
	currentPlantLabel.text = "OCCULAR SPINE SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	var WalnutButton = $PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton
	#WalnutButton.release_focus()
	print("Walnut selected")
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	#$UIClickAudio.play()

# Plays Sound and Makes the Maw the current selected plant, changing label & preview image 
func _on_MawButton_pressed():
	selected_plant = maw_scene
	var temp_instance = maw_scene.instantiate()	
	create_preview(maw_scene)
	setCanRemoveFalse()
	currentPlantLabel.text = "MAW SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
		
	print("Maw Selected")
	#$UIClickAudio.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)

# Plays Sound and Makes the EggWorm the current selected plant, changing label & preview image 
func _on_EggButton_pressed():
	selected_plant = egg_scene
	create_preview(egg_scene)
	var temp_instance = egg_scene.instantiate()
	setCanRemoveFalse()
	currentPlantLabel.text = "EGGWORM SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Egg/EggLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	print("EggWorm Selected")
	#$UIClickAudio.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)


	
# Plays Sound and Makes the Hive the current selected plant, changing label & preview image 
func _on_HiveButton_pressed():
	selected_plant = hive_scene
	create_preview(hive_scene)
	var temp_instance = hive_scene.instantiate()
	setCanRemoveFalse()	
	currentPlantLabel.text = "HIVE SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
		
	print("Hive Selected")
	#$UIClickAudio.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
# Creates a transparent preview image for a given plant scene 

func create_preview(plant_scene):
	print("MAKE A PREVIEW", plant_scene)
	# Clear the last preview 
	clear_preview()
	
	Global.show_guide()
	
	var temp_plant = plant_scene.instantiate()
	var preview_node = find_preview_nodes(temp_plant)
	
	if preview_node:
		print("Found Preview Node")
		# Duplicate all child sprites
		for child in preview_node.get_children():
			print("Preview Node Child is ", preview_node)
			# Create the preview sprite and make it semi-transparent 
			var preview_sprite = child.duplicate()
			preview_sprite.modulate = Color(1, 1, 1, 0.5)
			preview_sprite.scale = Vector2(1.25,1.25)
			
			# Store original position and print it
			var original_pos = Vector2(child.position.x, child.position.y)
			preview_sprite.set_meta("original_offset", original_pos)
			#print(preview_container.name)
			
			# Add the preview sprite to the container and array 
			preview_container.add_child(preview_sprite)
			preview_sprites.append(preview_sprite)
		
		is_previewing = true

	
	temp_plant.queue_free()
	
# Clears the current preview image 
func clear_preview():
	Global.clear_guide()
	for sprite in preview_sprites:
		if sprite:
			sprite.visible = false
			#sprite.queue_free()
	preview_sprites.clear()
	currentPlantLabel.text = ""
	is_previewing = false

func release_all_focus():
		
	SunFlowerButton.release_focus()
	WalnutButton.release_focus()
	EggButton.release_focus()
	MawButton.release_focus()
	HiveButton.release_focus()
	PeaShooterButton.release_focus()
	


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
	if node is AnimatedSprite2D:
		if("Preview" in node.name):
			return node
			
	return null
	
# Drags the preview sprite around with the cursor 
func _process(_delta):
	if is_previewing and not preview_sprites.is_empty():
		var base_pos = get_global_mouse_position()

		for sprite in preview_sprites:
			if sprite and sprite.has_meta("original_offset"):
				var offset = sprite.get_meta("original_offset") as Vector2
				sprite.global_position = base_pos + offset

func find_animated_sprite(node):
	# Recursively search for AnimatedSprite node
	if node is AnimatedSprite2D:
		return node
	
	for child in node.get_children():
		var result = find_animated_sprite(child)
		if result:
			return result
	return null

func add_button_highlight(button: Button) -> void:
	if not button:
		push_error("Button node is null!")
		return
	
	# Create a new StyleBoxFlat for the highlight
	var highlight_style = StyleBoxFlat.new()
	
	# Set the background to be transparent or match button's original background
	highlight_style.bg_color = Color.TRANSPARENT
	
	# Configure the border
	highlight_style.border_width_left = highlight_border_thickness
	highlight_style.border_width_right = highlight_border_thickness  
	highlight_style.border_width_top = highlight_border_thickness
	highlight_style.border_width_bottom = highlight_border_thickness
	highlight_style.border_color = highlight_border_color
	
	
	# Apply some corner rounding for a smoother look
	highlight_style.corner_radius_top_left = 4
	highlight_style.corner_radius_top_right = 4
	highlight_style.corner_radius_bottom_left = 4
	highlight_style.corner_radius_bottom_right = 4
	
	
	# Store the original style so we can restore it later
	if not button.has_meta("original_normal_style"):
		button.set_meta("original_normal_style", button.get_theme_stylebox("normal"))
	
	# Apply the highlight style to the button's normal state
	button.add_theme_stylebox_override("normal", highlight_style)
	
	
func add_pulsing_button_highlight(button: Button) -> void:
	if not button:
		push_error("Button node is null!")
		return
	
	# Create a new StyleBoxFlat for the highlight
	var highlight_style = StyleBoxFlat.new()
	
	# Set the background to be transparent or match button's original background
	highlight_style.bg_color = Color.TRANSPARENT
	
	# Configure the border
	highlight_style.border_width_left = highlight_border_thickness
	highlight_style.border_width_right = highlight_border_thickness  
	highlight_style.border_width_top = highlight_border_thickness
	highlight_style.border_width_bottom = highlight_border_thickness
	highlight_style.border_color = highlight_border_color
	
	# Add a glow effect using the shadow properties
	highlight_style.shadow_color = Color(highlight_border_color, 0.5)
	highlight_style.shadow_size = 8
	highlight_style.shadow_offset = Vector2.ZERO
	
	# Apply some corner rounding for a smoother look
	highlight_style.corner_radius_top_left = 4
	highlight_style.corner_radius_top_right = 4
	highlight_style.corner_radius_bottom_left = 4
	highlight_style.corner_radius_bottom_right = 4
	
	button.add_theme_stylebox_override("normal", highlight_style)
	start_glow_pulse(button)
	
	# Store the original style so we can restore it later
	if not button.has_meta("original_normal_style"):
		button.set_meta("original_normal_style", button.get_theme_stylebox("normal"))
	
	# Apply the highlight style to the button's normal state
	button.add_theme_stylebox_override("normal", highlight_style)

func start_glow_pulse(button: Button, glow_color: Color = highlight_border_color) -> void:
	var style: StyleBoxFlat = button.get_theme_stylebox("normal")
	if not style or not style is StyleBoxFlat:
		return
	
	# Kill any existing glow tween on this button
	if button.has_meta("glow_tween"):
		var old_tween: Tween = button.get_meta("glow_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	
	var tween := button.create_tween()
	tween.set_loops()  # Loop forever
	
	# Pulse: dim -> bright -> dim
	tween.tween_method(
		func(val: float) -> void:
			style.shadow_size = lerpf(4, 12, val)
			style.shadow_color = Color(glow_color, lerpf(0.2, 0.6, val)),
		0.0, 1.0, 0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_method(
		func(val: float) -> void:
			style.shadow_size = lerpf(12, 4, val)
			style.shadow_color = Color(glow_color, lerpf(0.6, 0.2, val)),
		0.0, 1.0, 0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	button.set_meta("glow_tween", tween)


func stop_glow_pulse(button: Button) -> void:
	if button.has_meta("glow_tween"):
		var tween: Tween = button.get_meta("glow_tween")
		if tween and tween.is_valid():
			tween.kill()
		button.remove_meta("glow_tween")
	
	# Reset shadow
	var style: StyleBoxFlat = button.get_theme_stylebox("normal")
	if style and style is StyleBoxFlat:
		style.shadow_size = 0
		style.shadow_color = Color.TRANSPARENT
		
		
# Function to remove highlight from a button
func remove_button_highlight(button: Button) -> void:
	if not button:
		push_error("Button node is null!")
		return
	button.remove_theme_stylebox_override("normal")
	button.get_theme_stylebox("normal").bg_color = Color("0f0a0a00")
	#0f0a0a00
	## Restore the original style if it was saved
	#if button.has_meta("original_normal_style"):
		#var original_style = button.get_meta("original_normal_style")
		#if original_style:
			#print("Original Style Exists")
			#button.add_theme_stylebox_override("normal", original_style)
		#else:
			#print("Original Style Does Not Exists")
			#button.remove_theme_stylebox_override("normal")
		#button.remove_meta("original_normal_style")
	#else:
		#print("original_normal_style Style Exists")
		## If no original style was saved, just remove the override
		#button.remove_theme_stylebox_override("normal")
		#
		


func _on_plant_manager_plant_placed() -> void:
	var PeaShooterButton = $PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2
	PeaShooterButton.visible = true 
	peaShooterCostLabel.visible = true 
	#add_button_highlight(PeaShooterButton)

func showEyeSummon():
	var SunFlowerButton = $PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton
	SunFlowerButton.visible = true 
	sunFlowerCostLabel.visible = true 


func _on_wave_manager_wave_2_almost_start() -> void:
	if root == "Main":
		
		var WalnutButton = $PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutButton
		walnutCostLabel.visible = true 
		WalnutButton.visible = true 
		
	elif root == "Level2":
		var EggButton = $VBoxContainer/HBoxContainer/Egg/EggButton
		eggCostLabel.visible = true 
		EggButton.visible = true 
		


func _on_remove_plant_button_pressed() -> void:
		clear_preview()
		
		selected_plant = null 
		canRemove = true 
		
func setCanRemoveFalse():
	canRemove = false 
	
func getCanRemove():
	return canRemove
	


func _on_open_codex_button_pressed() -> void:
	pass # Replace with function body.


func _on_open_demon_codex_button_pressed() -> void:
	codex_clicked.emit()


func _on_world_swap_button_pressed() -> void:
	if canSwapScenes:
	#	print("Can Swap Scenes is ", canSwapScenes)
		#Global.game_controller.swap_scenes()
		Global.swap_scenes()


func _on_codex_button_pressed() -> void:
	codex_clicked.emit()
	Global.game_controller.change_scene_with_pause("res://Scenes/Systems/lore_book_opener.tscn")


func _on_fast_forward_pressed() -> void:
	if doubleSpeed : 
		Engine.time_scale = 2
		doubleSpeed = false
	else:
		Engine.time_scale = 1
		doubleSpeed = true 


func _on_heart_button_pressed() -> void:
	if Global.hero_demon_is_summoned():
		return 
	
	selected_plant = heart_scene
	var temp_instance = heart_scene.instantiate()
	create_preview(heart_scene)
	setCanRemoveFalse()
	currentPlantLabel.text = "HEART DEMON SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Heart/HeartLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	var HeartButton = $PanelContainer/VBoxContainer/HBoxContainer/Heart/HeartButton
	#WalnutButton.release_focus()
	print("Heart selected")
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)


func _on_portal_button_pressed() -> void:
	if Global.game_controller.on_purple_scene():
		if Global.purple_portal != null:
			if Global.green_portal != null:
				portalButton.self_modulate = Color("7575756b")
			return
	else:
		if Global.green_portal != null:
			if Global.purple_portal != null:
				portalButton.self_modulate = Color("7575756b")
			return
		
	selected_plant = portal_scene
	var temp_instance = portal_scene.instantiate()
	create_preview(portal_scene)
	setCanRemoveFalse()
	currentPlantCost = 0
	#currentPlantCost.text = "0"
	currentPlantLabel.text = "PORTAL SELECTED " + deselectText
	temp_instance.queue_free()
	print("Portal selected")
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	
	
func swap_portal_button():
	if purple_scene:
		portalButton.icon = green_portal_icon
		purple_scene = false
		return 
	else:
		portalButton.icon = purple_portal_icon
		purple_scene = true 
		return 
		
func get_crawler_button():
	return $PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2
