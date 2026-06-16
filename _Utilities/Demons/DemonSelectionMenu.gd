extends Control
#DemonSelectionMenu.gd

@export var is_alt := false
var swap_ability := preload("res://_Entities/SwapAbilities/blood_rain_swap_ability.tscn")
var swap_ability_instance: Node

var root : String
var selected_demon := occulum_scene  # Holds the currently selected demon scene
var preview_sprite: AnimatedSprite2D = null  # Holds the sprite currently being previewed 

var preview_sprites: Array = [] # Holds array of preview sprites 
var is_previewing: bool = false # Whether or not we are currently previewing 
var canRemove := false
var purple_scene := true
var preview_sprite_modulation := Color(1,1,1,0.8)

signal clicked_Eye
signal codex_clicked

@export var card_spring: float = 150.0
@export var card_damp: float = 10.0
@export var card_velocity_multiplier: float = 2.0

var preview_card_sprites: Array = []   # the rotating card duplicates
var preview_last_mouse: Vector2
var card_osc_velocity: float = 0.0
var card_displacement: float = 0.0

# Preload the demon scenes
var crawler_scene := preload("res://_Entities/Demons/_Crawler/Crawler.tscn")
var occulum_scene := preload("res://_Entities/Demons/_Occulum/Occulum.tscn")
var spinalOcculum_scene := preload("res://_Entities/Demons/_CagedOculum/SpinalOcculum.tscn")
#var maw_scene := preload("res://_Entities/Demons/_Maw/MawTest.tscn")
var maw_scene := preload("res://_Entities/Demons/_Maw/Maw.tscn")

var wyrm_scene := preload("res://_Entities/Demons/_Wyrm/Wyrm.tscn")
var hive_scene := preload("res://_Entities/Demons/_Hive/Hive.tscn")
var heart_scene := preload("res://_Entities/Demons/_HeartDemon/HeartDemon.tscn")
var portal_scene := preload("res://_Entities/SpecialElementsPortal/Portal.tscn")
var green_portal_icon := preload("res://_Assets/UI/DemonCard_Portal_GreenButton.png")
var purple_portal_icon := preload("res://_Assets/UI/DemonCard_Portal.png")

var demon_normal_stylebox_default := preload("res://_Common/StyleBoxes/demon_normal_button.tres")
var demon_highlight_stylebox := preload("res://_Common/StyleBoxes/demon_highlight_stylebox.tres")


# Label for Current Demon 
var currentDemonLabel : Control
var currentDemonCostLabel : Label
var deselectText := " PRESS [X] TO DESELECT"

@onready var pause_button := $UtilityPanelContainer/MarginContainer/UtilityVBoxContainer/HBoxContainer/PauseButton
@onready var preview_container := Node2D.new()
@onready var panelContainer := $PanelContainer
@onready var portalButton := $PanelContainer/VBoxContainer/HBoxContainer/Portal/PortalButton
@onready var swapButton := $UtilityPanelContainer/MarginContainer/UtilityVBoxContainer/HBoxContainer/WorldSwap/WorldSwapButton
@onready var removeDemonButton := $PanelContainer2/UtilityVBoxContainer/HBoxContainer/RemoveDemon/RemoveDemonButton
@onready var codexButton := $UtilityPanelContainer/MarginContainer/UtilityVBoxContainer/HBoxContainer2/Codex2/CodexButton
@onready var fastForwardButton := $UtilityPanelContainer/MarginContainer/UtilityVBoxContainer/HBoxContainer2/FastForward/FastForwardButton
@onready var all_extra_buttons := [fastForwardButton,swapButton,removeDemonButton, codexButton]

@onready var OcculumButton := $PanelContainer/VBoxContainer/HBoxContainer/Occulum/OcculumButton
@onready var SpinalOcculumButton := $PanelContainer/VBoxContainer/HBoxContainer/SpinalOcculum/SpinalOcculumButton
@onready var WyrmButton := $PanelContainer/VBoxContainer/HBoxContainer/Wyrm/WyrmButton
@onready var MawButton := $PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton
@onready var HiveButton := $PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveButton
@onready var CrawlerButton := $PanelContainer/VBoxContainer/HBoxContainer/Crawler/CrawlerButton
@onready var HeartButton := $PanelContainer/VBoxContainer/HBoxContainer/Heart/HeartButton
@onready var PortalButton := $PanelContainer/VBoxContainer/HBoxContainer/Portal/PortalButton

@onready var all_demon_buttons := [OcculumButton,SpinalOcculumButton,
							WyrmButton,MawButton,HiveButton,
							CrawlerButton]


@onready var OcculumCostLabel := $PanelContainer/VBoxContainer/HBoxContainer/Occulum/OcculumCostLabel
@onready var crawlerCostLabel  := $PanelContainer/VBoxContainer/HBoxContainer/Crawler/CrawlerCostLabel
@onready var SpinalOcculumCostLabel  := $PanelContainer/VBoxContainer/HBoxContainer/SpinalOcculum/SpinalOcculumCostLabel
@onready var wyrmCostLabel  := $PanelContainer/VBoxContainer/HBoxContainer/Wyrm/WyrmCostLabel
@onready var mawCostLabel  := $PanelContainer/VBoxContainer/HBoxContainer/Maw/MawCostLabel
@onready var hiveCostLabel   := $PanelContainer/VBoxContainer/HBoxContainer/Hive/HiveCostLabel

@onready var alt_portal_texture : Texture2D = preload("res://_Entities/SpecialElementsPortal/PurplePortalCard.png")

@onready var OcculumCost := 50

var canSwapScenes := true
const MAX_SHADOW_OFFSET := 8.0
# Thickness of the highlight border (in pixels)
@export var highlight_border_thickness: int = 1

# Color of the highlight border
@export var highlight_border_color: Color = Color.RED

var doubleSpeed := true

func _ready() -> void:
	is_alt = get_parent().isGreenDimension
	add_child(preview_container)
	if is_alt:
		PortalButton.texture_normal = alt_portal_texture
		
	Global.register_demon_selection_menu(self)
	Global.resetOcculumCount()
	Global._load_demon_costs()
	
	if not CrawlerButton.pressed.is_connected(_on_CrawlerButton_pressed):
		CrawlerButton.pressed.connect(_on_CrawlerButton_pressed)
	if not OcculumButton.pressed.is_connected(_on_OcculumButton_pressed):
		OcculumButton.pressed.connect(_on_OcculumButton_pressed)
	if not SpinalOcculumButton.pressed.is_connected(_on_SpinalOcculumButton_pressed):
		SpinalOcculumButton.pressed.connect(_on_SpinalOcculumButton_pressed)
	if not WyrmButton.pressed.is_connected(_on_WyrmButton_pressed):
		WyrmButton.pressed.connect(_on_WyrmButton_pressed)
	if not MawButton.pressed.is_connected(_on_MawButton_pressed):
		MawButton.pressed.connect(_on_MawButton_pressed)
	if not HiveButton.pressed.is_connected(_on_HiveButton_pressed):
		HiveButton.pressed.connect(_on_HiveButton_pressed)
		
	if not HeartButton.pressed.is_connected(_on_heart_button_pressed):
		HeartButton.pressed.connect(_on_heart_button_pressed)		



	
	OcculumCostLabel.text = str(Global.get_demon_cost("Occulum"))
	crawlerCostLabel.text = str(Global.get_demon_cost("Crawler"))
	SpinalOcculumCostLabel.text = str(Global.get_demon_cost("SpinalOcculum"))
	wyrmCostLabel.text = str(Global.get_demon_cost("Wyrm"))
	mawCostLabel.text = str(Global.get_demon_cost("Maw"))
	hiveCostLabel.text = str(Global.get_demon_cost("Hive"))
	
#	removeDemonButton.pressed.connect(_on_remove_demon_button_pressed)

	#add_button_highlight
	set_process_input(true)
	
	# Connect button signals to their respective functions
	root = get_parent().get_name()
	

# Handle Deselection
func _input(event:InputEvent) -> void:

	if event is InputEventKey and event.pressed:
		#print("Key Pressed")
		if event.keycode == KEY_X:
			deselect_demon()
		if event.keycode == KEY_Y:
			#print("Y Key Pressed")
			if canSwapScenes:
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

func set_pause_process_mode():
	pause_button.set_pause_process_mode()



func setPanelContainerWidth(_newWidth: int) -> void:
	#print("Panel Container Dimensions is ", panelContainer.size)
	panelContainer.size.x = 71
	#print("Panel Container Dimensions is ", panelContainer.size)

		
func deselect_demon() -> void:
	#print("Clearing Preview Because of Deselect")
	clear_preview()
	release_all_focus()
	selected_demon = null 			
	setCanRemoveFalse()
	
func on_demon_button_pressed(demon_scene:PackedScene, demon_button:Control, demon_label:Control) -> void:
	Global.hide_notification_bar()
	setCanRemoveFalse()
	selected_demon = demon_scene
	var temp_instance :Demon= demon_scene.instantiate()
	create_preview(demon_scene)
	add_button_highlight(demon_button)
	temp_instance.queue_free()
	print(demon_scene, " selected")
	currentDemonCostLabel = demon_label
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)	

func _on_CrawlerButton_pressed() -> void:
	on_demon_button_pressed(crawler_scene,CrawlerButton,crawlerCostLabel)


func _on_OcculumButton_pressed() -> void:
	on_demon_button_pressed(occulum_scene,OcculumButton,OcculumCostLabel)
	OcculumCost  += 5
	clicked_Eye.emit()
	
func increaseOcculumCost() -> void:
	OcculumCostLabel.text = str(50+(Global.getOcculumCount() * 10))


func _on_SpinalOcculumButton_pressed() -> void:
	on_demon_button_pressed(spinalOcculum_scene,SpinalOcculumButton,SpinalOcculumCostLabel)


func _on_MawButton_pressed() -> void:
	on_demon_button_pressed(maw_scene,MawButton,mawCostLabel)


func _on_WyrmButton_pressed() -> void:
	on_demon_button_pressed(wyrm_scene,WyrmButton,wyrmCostLabel)


func _on_HiveButton_pressed() -> void:
	on_demon_button_pressed(hive_scene,HiveButton,hiveCostLabel)


func create_preview(demon_scene:PackedScene) -> void:
	#print("MAKE A PREVIEW", demon_scene)
	# Clear the last preview
	#print("Clearing Preview Because of Create Preview")
	clear_preview()

	Global.show_guide()

	var temp_demon  = demon_scene.instantiate()
	var preview_node : Node = find_preview_nodes(temp_demon)
	
	if preview_node:
		#print("Found Preview Node : ", preview_node)
		# Duplicate all child sprites
		for child in preview_node.get_children():
			#print("Preview Node Child is ", child)
			# Create the preview sprite and make it semi-transparent 
			var this_preview_sprite : Node = child.duplicate()
			this_preview_sprite.modulate = preview_sprite_modulation
			#this_preview_sprite.scale = Vector2(1.25,1.25)
			this_preview_sprite.z_index = 100
			if this_preview_sprite is AnimatedSprite2D:
				this_preview_sprite.play()
			
			# Store original position and print it
			var original_pos := Vector2(child.position.x, child.position.y)
			this_preview_sprite.set_meta("original_offset", original_pos)
			
			# Add the preview sprite to the container and array 
			#print("Add ", this_preview_sprite , " to preview container")
			preview_container.add_child(this_preview_sprite)
			
			if this_preview_sprite.name.begins_with("PreviewCard"): 
			#and not this_preview_sprite.name.begins_with("PreviewCardShadow"):
				preview_card_sprites.append(this_preview_sprite)
			if "Level0-1" in Global.game_controller.get_active_dimension().name:
				if "BloodTile" in this_preview_sprite.name:
					this_preview_sprite.modulate = Color(1,1,1,0)
				else:
					preview_sprites.append(this_preview_sprite)
			else:
				preview_sprites.append(this_preview_sprite)
				
		is_previewing = true
		preview_last_mouse = get_global_mouse_position()
		card_osc_velocity = 0.0
		card_displacement = 0.0
	temp_demon.queue_free()

func get_tooltips()->Control:
	return $"../ToolTips"

	
# Clears the current preview image 
func clear_preview() -> void:
	#print("Clear BUTTON PReview")
	Global.clear_guide()
	for sprite:Node in preview_sprites:
		if sprite:
			sprite.visible = false
			#sprite.queue_free()
	for demonButton:TextureButton in all_demon_buttons:
		#print("Demon Button ia ",demonButton )
		remove_button_highlight(demonButton)
	preview_sprites.clear()
	#print("Preview Sprites Is ", preview_sprites)
	preview_card_sprites.clear()
	#currentDemonLabel.text = ""
	is_previewing = false
	
	for child in preview_container.get_children():
		child.queue_free()

func release_all_focus() -> void:
		
	OcculumButton.release_focus()
	SpinalOcculumButton.release_focus()
	WyrmButton.release_focus()
	MawButton.release_focus()
	HiveButton.release_focus()
	CrawlerButton.release_focus()
	


# Gets all the previewNodes
func find_preview_nodes(node:Node) -> Node:
	#print("Must Find Preview For : ", node)
	if node.name == "PreviewNodes":
		return node
	
	for child:Node in node.get_children():
		var result : Node = find_preview_nodes(child)
		if result:
			return result
	return null


func find_preview_sprite(node:Node)->Node:
	# Recursively search for AnimatedSprite node
	if node is AnimatedSprite2D:
		if("Preview" in node.name):
			return node
			
	return null

# Drags the preview sprite around with the cursor 
func _process(delta:float) -> void:
	if is_previewing and not preview_sprites.is_empty():
		var base_pos := get_global_mouse_position()
		var center_x := get_viewport_rect().size.x / 2.0

		for sprite:Node in preview_sprites:
			if sprite and sprite.has_meta("original_offset"):
				var offset := sprite.get_meta("original_offset") as Vector2
				var extra := Vector2.ZERO
				if sprite.name.begins_with("PreviewCardShadow"):
					var dist := base_pos.x - center_x
					var shadow_x := lerpf(0.0, -signf(dist) * MAX_SHADOW_OFFSET,
											clampf(absf(dist / center_x), 0.0, 1.0))
					extra.x = shadow_x
				sprite.global_position = base_pos + offset + extra
				
		if not preview_card_sprites.is_empty() and delta > 0.0:
			var velocity := (base_pos - preview_last_mouse) / delta
			preview_last_mouse = base_pos

			card_osc_velocity += velocity.normalized().x * card_velocity_multiplier
			var force := -card_spring * card_displacement - card_damp * card_osc_velocity
			card_osc_velocity += force * delta
			card_displacement += card_osc_velocity * delta
#
			#for card in preview_card_sprites:
				#if card:
					#card.rotation = card_displacement
				#print(sprite, " sprite new global pos is ",sprite.global_position )

func find_animated_sprite(node:Node)->Node:
	# Recursively search for AnimatedSprite node
	if node is AnimatedSprite2D:
		return node
	
	for child in node.get_children():
		var result : Node = find_animated_sprite(child)
		if result:
			return result
	return null

func add_button_highlight(button: TextureButton) -> void:
	if not button:
		push_error("Button node is null!")
		return
		
	# Store the original style so we can restore it later
	if not button.has_meta("original_normal_style"):
		button.set_meta("original_normal_style", button.get_theme_stylebox("normal"))
	
	## Apply the highlight style to the button's normal state
	button.add_theme_stylebox_override("normal", demon_highlight_stylebox)
	
	
func add_pulsing_button_highlight(button: TextureButton, should_pulse : bool = true) -> void:
	if not button:
		push_error("Button node is null!")
		return
	#print("Button Global START Pos Is  : ", button.global_position)
	# Remove any existing highlight
	if button.has_meta("highlight_panel"):
		var old: Panel = button.get_meta("highlight_panel")
		if is_instance_valid(old):
			old.queue_free()

	# Create a Panel as a child to act as the border/glow
	var panel := Panel.new()
	#panel.scale = Vector2(0.8,0.8)
	panel.name = "HighlightPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't eat clicks


	button.add_child(panel)
	for child in button.get_children():
		#print(button, " children are ", child)
		pass


	# Expand slightly beyond the button to create a border effect
	var margin := highlight_border_thickness #+ 4
	#panel.position = Vector2(-margin, -margin)
	#panel.position = Vector2(0,0)
	panel.size = button.size #+ Vector2(margin * 2, margin * 2)
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
	highlight_style.shadow_size = 2
	highlight_style.shadow_offset = Vector2.ZERO
	highlight_style.corner_radius_top_left = 2
	highlight_style.corner_radius_top_right = 2
	highlight_style.corner_radius_bottom_left = 2
	highlight_style.corner_radius_bottom_right = 2

	panel.add_theme_stylebox_override("panel", highlight_style)
	button.set_meta("highlight_panel", panel)




	if should_pulse:
		start_glow_pulse(button, panel, highlight_style)

func start_glow_pulse(button: TextureButton, _panel: Panel, style: StyleBoxFlat, glow_color: Color = highlight_border_color) -> void:
	if button.has_meta("glow_tween"):
		var old_tween: Tween = button.get_meta("glow_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween := button.create_tween()
	tween.set_loops()

	tween.tween_method(
		func(val: int) -> void:
			style.shadow_size = int(lerpf(4, 8, val))
			style.shadow_color = Color(glow_color, lerpf(0.2, 0.4, val)),
		0.0, 1.0, 1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_method(
		func(val: int) -> void:
			style.shadow_size = int(lerpf(8, 4, val))
			style.shadow_color = Color(glow_color, lerpf(0.4, 0.2, val)),
		0.0, 1.0, 1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	button.set_meta("glow_tween", tween)


func stop_glow_pulse(button: TextureButton) -> void:
	#print("STOP PULSE")
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
	if button.get_child(0) != null:
		if button.get_child(0).name == "HighlightPanel":
			print("Going to queue free button highlight : ", button.get_child(0))
			button.get_child(0).queue_free()
			pass
		
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

	button.add_theme_stylebox_override("normal", demon_normal_stylebox_default )
		#
		


func _on_demon_manager_demon_placed() -> void:
	CrawlerButton.visible = true
	crawlerCostLabel.visible = true
	#add_button_highlight(CrawlerButton)

func showEyeSummon() -> void:
	OcculumButton.visible = true
	OcculumCostLabel.visible = true

		


func _on_remove_demon_button_pressed() -> void:
		print("Clear Guide Because Remove Demon Button Pressed")
		clear_preview()
		
		selected_demon = null
		canRemove = true

func setCanRemoveFalse() -> void:
	canRemove = false

func getCanRemove() -> bool:
	return canRemove
	


func _on_open_codex_button_pressed() -> void:
	pass # Replace with function body.


func _on_open_demon_codex_button_pressed() -> void:
	codex_clicked.emit()


func _on_world_swap_button_pressed() -> void:
	Global.hide_notification_bar()
	if canSwapScenes:
	#	print("Can Swap Scenes is ", canSwapScenes)
		#Global.game_controller.swap_scenes()
		Global.swap_scenes()
	else:
		print("Can Swap Scenes is false")


func _on_pip_toggle_button_pressed() -> void:
	Global.game_controller.toggle_pip_size()


func _on_codex_button_pressed() -> void:
	Global.hide_notification_bar()
	codex_clicked.emit()
	Global.game_controller.change_scene_with_pause("res://_UI/LoreBooks/lore_book_opener.tscn")


func _on_fast_forward_pressed() -> void:
	
	if doubleSpeed : 
		add_pulsing_button_highlight(fastForwardButton,false)
		Engine.time_scale = 2
		doubleSpeed = false
	else:
		stop_glow_pulse(fastForwardButton)
		remove_button_highlight(fastForwardButton)
		Engine.time_scale = 1
		doubleSpeed = true


func _on_heart_button_pressed() -> void:
	Global.hide_notification_bar()
	if Global.hero_demon_is_summoned():
		return

	selected_demon = heart_scene
	var temp_instance := heart_scene.instantiate()
	create_preview(heart_scene)
	setCanRemoveFalse()
	#currentDemonLabel.text = "HEART DEMON SELECTED " + deselectText
	#currentDemonCost = $PanelContainer/VBoxContainer/HBoxContainer/Heart/HeartLabel
	#currentDemonCost.text = str(temp_instance.get_cost())
	temp_instance.queue_free()
	#var HeartButton :TextureButton= $PanelContainer/VBoxContainer/HBoxContainer/Heart/HeartButton
	#SpinalOcculumButton.release_focus()
	print("Heart selected")
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)


func _on_portal_button_pressed() -> void:
	Global.hide_notification_bar()
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
		
	selected_demon = portal_scene
	var temp_instance := portal_scene.instantiate()
	create_preview(portal_scene)
	setCanRemoveFalse()
	#currentDemonCost = 0
	#currentDemonCost.text = "0"
	#currentDemonLabel.text = "PORTAL SELECTED " + deselectText
	temp_instance.queue_free()
	print("Portal selected")
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	
	
func swap_portal_button() -> void:
	if purple_scene:
		portalButton.texture_normal = purple_portal_icon#green_portal_icon
		purple_scene = false
		return
	else:
		portalButton.texture_normal = green_portal_icon #purple_portal_icon
		purple_scene = true
		return
		
func get_crawler_button() -> TextureButton:
	return CrawlerButton

func get_occulum_button() -> TextureButton:
	return OcculumButton
	
func get_wyrm_button() -> TextureButton:
	return WyrmButton
	
func get_hive_button() -> TextureButton:
	return HiveButton
	
func get_spinal_occulum_button() -> TextureButton:
	return SpinalOcculumButton
	
func get_maw_button() -> TextureButton:
	return MawButton
	
func get_world_swap_button() -> TextureButton:
	return swapButton
	
func get_remove_demon_button() -> TextureButton:
	return removeDemonButton
	
func get_codex_button() -> TextureButton:
	return codexButton
	
func get_panel_container()->Control:
	return panelContainer

func get_all_extra_buttons()->Array:
	return all_extra_buttons
