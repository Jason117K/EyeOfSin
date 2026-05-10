extends Control
#DemonSelectionMenu.gd

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

var demon_normal_stylebox_default = preload("res://_Common/StyleBoxes/demon_normal_button.tres")
var demon_highlight_stylebox = preload("res://_Common/StyleBoxes/demon_highlight_stylebox.tres")

#var demon_hover_stylebox = preload()

#var hive_scene = preload("res://Scenes/PlantScenes/phantom_hive.tscn")

# Label for Current Plant 
var currentPlantLabel
var currentPlantCost
var deselectText = " PRESS [X] TO DESELECT"

@onready var preview_container = Node2D.new()
@onready var panelContainer = $PanelContainer
@onready var portalButton := $PanelContainer/VBoxContainer/HBoxContainer/Portal/PortalButton
@onready var swapButton := $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/WorldSwap/WorldSwapButton
@onready var removeDemonButton := $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/RemovePlant/RemovePlantButton
@onready var codexButton := $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Codex2/CodexButton
@onready var fastForwardButton := $PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/FastForward/FastForwardButton
@onready var all_extra_buttons := [fastForwardButton,swapButton,removeDemonButton, codexButton]

@onready var OcculumButton = $PanelContainer/VBoxContainer/HBoxContainer/Occulum/OcculumButton
@onready var SpinalOcculumButton = $PanelContainer/VBoxContainer/HBoxContainer/SpinalOcculum/SpinalOcculumButton
@onready var  WyrmButton = $PanelContainer/VBoxContainer/HBoxContainer/Wyrm/WyrmButton
@onready var  MawButton = $PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton
@onready var HiveButton = $PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton
@onready var  CrawlerButton = $PanelContainer/VBoxContainer/HBoxContainer/Crawler/CrawlerButton
@onready var HeartButton := $PanelContainer/VBoxContainer/HBoxContainer/Heart/HeartButton

@onready var all_demon_buttons = [OcculumButton,SpinalOcculumButton,
							WyrmButton,MawButton,HiveButton,
							CrawlerButton]


@onready var OcculumCostLabel := $PanelContainer/VBoxContainer/HBoxContainer/Occulum/OcculumCostLabel
@onready var crawlerCostLabel  := $PanelContainer/VBoxContainer/HBoxContainer/Crawler/CrawlerCostLabel
@onready var SpinalOcculumCostLabel  := $PanelContainer/VBoxContainer/HBoxContainer/SpinalOcculum/SpinalOcculumCostLabel
@onready var wyrmCostLabel  := $PanelContainer/VBoxContainer/HBoxContainer/Wyrm/WyrmCostLabel
@onready var mawCostLabel  := $PanelContainer/VBoxContainer/HBoxContainer/Maw/MawCostLabel
@onready var hiveCostLabel   := $PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveCostLabel

@onready var OcculumCost := 50

var canSwapScenes = false

# Thickness of the highlight border (in pixels)
@export var highlight_border_thickness: int = 4

# Color of the highlight border
@export var highlight_border_color: Color = Color.RED

var doubleSpeed = false 

func _ready():
	add_child(preview_container)
	swap_ability_instance = swap_ability.instantiate()
	#print("swap_ability_instance is : ",  swap_ability_instance)
	get_parent().call_deferred("add_child", swap_ability_instance)
	#print("swap_ability_i")
#	swap_ability_instance._ready()
	
	#setPanelContainerWidth(100)
	#Global.plant_selection_menu = self
	if is_alt:
		Global.plant_selection_menu_alt = self
	else:
		Global.plant_selection_menu = self
	Global.resetSunflowerCount()
	Global._load_demon_costs()
	
	CrawlerButton.pressed.connect(_on_CrawlerButton_pressed)
	OcculumButton.pressed.connect(_on_OcculumButton_pressed)
	SpinalOcculumButton.pressed.connect(_on_SpinalOcculumButton_pressed)
	WyrmButton.pressed.connect(_on_WyrmButton_pressed)
	MawButton.pressed.connect(_on_MawButton_pressed)
	HiveButton.pressed.connect(_on_HiveButton_pressed)
	HeartButton.pressed.connect(_on_heart_button_pressed)

	
	OcculumCostLabel.text = str(Global.get_demon_cost("Occulum"))
	crawlerCostLabel.text = str(Global.get_demon_cost("Crawler"))
	SpinalOcculumCostLabel.text = str(Global.get_demon_cost("SpinalOcculum"))
	wyrmCostLabel.text = str(Global.get_demon_cost("Wyrm"))
	mawCostLabel.text = str(Global.get_demon_cost("Maw"))
	hiveCostLabel.text = str(Global.get_demon_cost("Hive"))

	#add_button_highlight
	set_process_input(true)
	
	# Connect button signals to their respective functions
	root = get_parent().get_name()
	
	#Set Up Label for Displaying Current Plant
	#currentPlantLabel = $CurrentPlantLabel
	

	
	
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
			_on_OcculumButton_pressed()
		if event.keycode == KEY_2:
			print("2 Key Pressed")
			_on_CrawlerButton_pressed()
		if event.keycode == KEY_3:
			print("3 Key Pressed")
			_on_SpinalOcculumButton_pressed()
		if event.keycode == KEY_4:
			print("4 Key Pressed")
			_on_MawButton_pressed()
		if event.keycode == KEY_5:
			print("5 Key Pressed")
			_on_WyrmButton_pressed()
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
func _on_CrawlerButton_pressed():
	setCanRemoveFalse()
	selected_plant = peashooter_scene
	var temp_instance = peashooter_scene.instantiate()
	create_preview(peashooter_scene)
	add_button_highlight(CrawlerButton)
	
	#currentPlantLabel.text = "SPIDER SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	
	print("Peashooter selected")
	#$UIClickAudio.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	var CrawlerButton = $PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2
	#remove_button_highlight(CrawlerButton)

func increaseSunflowerCost():
	OcculumCostLabel.text = str(50+(Global.getSunflowerCount()*5))
	
# Plays Sound and Makes the Sunflower the current selected plant, changing label & preview image 
func _on_OcculumButton_pressed():
	setCanRemoveFalse()
	selected_plant = sunflower_scene
	var temp_instance = sunflower_scene.instantiate()
	create_preview(sunflower_scene)
	add_button_highlight(OcculumButton)
	
	#currentPlantLabel.text = "EVIL EYE SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel
	#currentPlantCost.text = str(temp_instance.get_name(), "IS", temp_instance.get_cost())
	OcculumCost  += 5
	
	
	#currentPlantCost.text = "Penis"
	temp_instance.queue_free()
	
##	print("3Label text is ", OcculumCostLabel.text)
#	print("Sunflower selected", temp_instance.get_name())
#	$UIClickAudio.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	clicked_Eye.emit()


# Plays Sound and Makes the Walnut the current selected plant, changing label & preview image 
func _on_SpinalOcculumButton_pressed():
	selected_plant = walnut_scene
	var temp_instance = walnut_scene.instantiate()
	create_preview(walnut_scene)
	add_button_highlight(SpinalOcculumButton)
	setCanRemoveFalse()
	#currentPlantLabel.text = "OCCULAR SPINE SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Walnut/WalnutLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	var SpinalOcculumButton = $PanelContainer/VBoxContainer/HBoxContainer/Walnut/SpinalOcculumButton
	#SpinalOcculumButton.release_focus()
	print("Walnut selected")
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	#$UIClickAudio.play()

# Plays Sound and Makes the Maw the current selected plant, changing label & preview image 
func _on_MawButton_pressed():
	selected_plant = maw_scene
	var temp_instance = maw_scene.instantiate()	
	create_preview(maw_scene)
	add_button_highlight(MawButton)
	setCanRemoveFalse()
	#currentPlantLabel.text = "MAW SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Maw/MawLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
		
	print("Maw Selected")
	#$UIClickAudio.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)

# Plays Sound and Makes the EggWorm the current selected plant, changing label & preview image 
func _on_WyrmButton_pressed():
	selected_plant = egg_scene
	create_preview(egg_scene)
	add_button_highlight(WyrmButton)
	var temp_instance = egg_scene.instantiate()
	setCanRemoveFalse()
	#currentPlantLabel.text = "EGGWORM SELECTED " + deselectText
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
	add_button_highlight(HiveButton)
	var temp_instance = hive_scene.instantiate()
	setCanRemoveFalse()	
	#currentPlantLabel.text = "HIVE SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
		
	print("Hive Selected")
	#$UIClickAudio.play()
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
# Creates a transparent preview image for a given plant scene 

func create_preview(plant_scene):
	#print("MAKE A PREVIEW", plant_scene)
	# Clear the last preview 
	clear_preview()
	
	Global.show_guide()
	
	var temp_plant = plant_scene.instantiate()
	var preview_node = find_preview_nodes(temp_plant)
	
	if preview_node:
		#print("Found Preview Node : ", preview_node)
		# Duplicate all child sprites
		for child in preview_node.get_children():
			#print("Preview Node Child is ", child)
			# Create the preview sprite and make it semi-transparent 
			var preview_sprite = child.duplicate()
			preview_sprite.modulate = Color(1, 1, 1, 0.5)
			preview_sprite.scale = Vector2(1.25,1.25)
			preview_sprite.z_index = 100
			if preview_sprite is AnimatedSprite2D:
				preview_sprite.play()
			
			# Store original position and print it
			var original_pos = Vector2(child.position.x, child.position.y)
			preview_sprite.set_meta("original_offset", original_pos)
			#print(preview_container.name)
			
			# Add the preview sprite to the container and array 
			preview_container.add_child(preview_sprite)
			preview_sprites.append(preview_sprite)
		for sprite in preview_sprites:
			if sprite is AnimatedSprite2D:
				pass
				#print("Preview Animation: ", sprite.animation, " | Frame: ", sprite.frame, " | Frames: ", sprite.sprite_frames)		
		is_previewing = true
	#	print("Preview container visible: ", preview_container.visible)
		#print("Preview container global pos: ", preview_container.global_position)
	#	print("Preview sprites count: ", preview_sprites.size())

	
	temp_plant.queue_free()
	
# Clears the current preview image 
func clear_preview():
	#print("Clear BUTTON PReview")
	Global.clear_guide()
	for sprite in preview_sprites:
		if sprite:
			sprite.visible = false
			#sprite.queue_free()
	for demonButton in all_demon_buttons:
		#print("Demon Button ia ",demonButton )
		remove_button_highlight(demonButton)
	preview_sprites.clear()
	#currentPlantLabel.text = ""
	is_previewing = false

func release_all_focus():
		
	OcculumButton.release_focus()
	SpinalOcculumButton.release_focus()
	WyrmButton.release_focus()
	MawButton.release_focus()
	HiveButton.release_focus()
	CrawlerButton.release_focus()
	


# Gets all the previewNodes
func find_preview_nodes(node):
	#print("Must Find Preview For : ", node)
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

func add_button_highlight(button: TextureButton) -> void:
	if not button:
		push_error("Button node is null!")
		return
	## Set the background to be transparent or match button's original background
	#highlight_style.bg_color = Color.TRANSPARENT
	#
	## Configure the border
	#highlight_style.border_width_left = highlight_border_thickness
	#highlight_style.border_width_right = highlight_border_thickness  
	#highlight_style.border_width_top = highlight_border_thickness
	#highlight_style.border_width_bottom = highlight_border_thickness
	#highlight_style.border_color = highlight_border_color
	#
	#
	## Apply some corner rounding for a smoother look
	#highlight_style.corner_radius_top_left = 4
	#highlight_style.corner_radius_top_right = 4
	#highlight_style.corner_radius_bottom_left = 4
	#highlight_style.corner_radius_bottom_right = 4
	#
	
	# Store the original style so we can restore it later
	if not button.has_meta("original_normal_style"):
		button.set_meta("original_normal_style", button.get_theme_stylebox("normal"))
	
	## Apply the highlight style to the button's normal state
	button.add_theme_stylebox_override("normal", demon_highlight_stylebox)
	
	
func add_pulsing_button_highlight(button: TextureButton) -> void:
	if not button:
		push_error("Button node is null!")
		return

	# Remove any existing highlight
	if button.has_meta("highlight_panel"):
		var old: Panel = button.get_meta("highlight_panel")
		if is_instance_valid(old):
			old.queue_free()

	# Create a Panel as a child to act as the border/glow
	var panel := Panel.new()
	panel.name = "HighlightPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't eat clicks


	button.add_child(panel)
	panel.top_level = true
	#panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Expand slightly beyond the button to create a border effect
	var margin := highlight_border_thickness + 4
	panel.global_position = button.global_position - Vector2(margin, margin)
	panel.size = button.size + Vector2(margin * 2, margin * 2)	
	#panel.offset_left = -margin
	#panel.offset_top = -margin
	#panel.offset_right = margin
	#panel.offset_bottom = margin
	#panel.z_index = -1  # Draw behind the button's textures
	panel.z_index = 2

	# Build the stylebox for the panel
	var highlight_style := StyleBoxFlat.new()
	highlight_style.bg_color = Color.TRANSPARENT
	highlight_style.border_width_left = highlight_border_thickness
	highlight_style.border_width_right = highlight_border_thickness
	highlight_style.border_width_top = highlight_border_thickness
	highlight_style.border_width_bottom = highlight_border_thickness
	highlight_style.border_color = highlight_border_color
	highlight_style.shadow_color = Color(highlight_border_color, 0.5)
	highlight_style.shadow_size = 8
	highlight_style.shadow_offset = Vector2.ZERO
	highlight_style.corner_radius_top_left = 4
	highlight_style.corner_radius_top_right = 4
	highlight_style.corner_radius_bottom_left = 4
	highlight_style.corner_radius_bottom_right = 4

	panel.add_theme_stylebox_override("panel", highlight_style)
	button.set_meta("highlight_panel", panel)



	
	start_glow_pulse(button, panel, highlight_style)

func start_glow_pulse(button: TextureButton, panel: Panel, style: StyleBoxFlat, glow_color: Color = highlight_border_color) -> void:
	if button.has_meta("glow_tween"):
		var old_tween: Tween = button.get_meta("glow_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween := button.create_tween()
	tween.set_loops()

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


func stop_glow_pulse(button: TextureButton) -> void:
	print("STOP PULSE")
	if button.has_meta("glow_tween"):
		var tween: Tween = button.get_meta("glow_tween")
		if tween and tween.is_valid():
			tween.kill()
		button.remove_meta("glow_tween")
	
	# Remove the highlight panel
	if button.has_meta("highlight_panel"):
		var panel: Panel = button.get_meta("highlight_panel")
		if is_instance_valid(panel):
			panel.queue_free()
		button.remove_meta("highlight_panel")
		
func remove_pulsing_button_highlight(button: TextureButton) -> void:
	if button.has_meta("glow_tween"):
		var tw: Tween = button.get_meta("glow_tween")
		if tw and tw.is_valid():
			tw.kill()
	if button.has_meta("highlight_panel"):
		var p: Panel = button.get_meta("highlight_panel")
		if is_instance_valid(p):
			p.queue_free()
			
					
# Function to remove highlight from a button
func remove_button_highlight(button: TextureButton) -> void:
	if not button:
		push_error("Button node is null!")
		return
	#button.remove_theme_stylebox_override("normal")
	#print("Button to REMOVVE Is ", button)
	button.add_theme_stylebox_override("normal", demon_normal_stylebox_default )
		#
		


func _on_plant_manager_plant_placed() -> void:
	var CrawlerButton = $PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2
	CrawlerButton.visible = true 
	crawlerCostLabel.visible = true 
	#add_button_highlight(CrawlerButton)

func showEyeSummon():
	var OcculumButton = $PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton
	OcculumButton.visible = true 
	OcculumCostLabel.visible = true 


func _on_wave_manager_wave_2_almost_start() -> void:
	if root == "Main":
		
		var SpinalOcculumButton = $PanelContainer/VBoxContainer/HBoxContainer/Walnut/SpinalOcculumButton
		SpinalOcculumCostLabel.visible = true 
		SpinalOcculumButton.visible = true 
		
	elif root == "Level2":
		var WyrmButton = $VBoxContainer/HBoxContainer/Egg/WyrmButton
		wyrmCostLabel.visible = true 
		WyrmButton.visible = true 
		


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
	Global.game_controller.change_scene_with_pause("res://_UI/LoreBooks/lore_book_opener.tscn")


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
	#currentPlantLabel.text = "HEART DEMON SELECTED " + deselectText
	currentPlantCost = $PanelContainer/VBoxContainer/HBoxContainer/Heart/HeartLabel
	#currentPlantCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	var HeartButton = $PanelContainer/VBoxContainer/HBoxContainer/Heart/HeartButton
	#SpinalOcculumButton.release_focus()
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
	#currentPlantLabel.text = "PORTAL SELECTED " + deselectText
	temp_instance.queue_free()
	print("Portal selected")
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	
	
func swap_portal_button():
	if purple_scene:
		portalButton.texture_normal = purple_portal_icon#green_portal_icon
		purple_scene = false
		return 
	else:
		portalButton.texture_normal = green_portal_icon #purple_portal_icon
		purple_scene = true 
		return 
		
func get_crawler_button():
	return CrawlerButton

func get_occulum_button():
	return OcculumButton
	
func get_wyrm_button():
	return WyrmButton
	
func get_hive_button():
	return HiveButton
	
func get_spinal_occulum_button():
	return SpinalOcculumButton
	
func get_maw_button():
	return MawButton
	
func get_world_swap_button():
	return swapButton
	
func get_remove_demon_button():
	return removeDemonButton
	
func get_codex_button():
	return codexButton
	
func get_panel_container():
	return panelContainer

func get_all_extra_buttons():
	return all_extra_buttons
