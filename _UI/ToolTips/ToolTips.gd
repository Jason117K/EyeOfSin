extends Control

#@onready var visual_tutorial_nine_patch := $VisualNinePatchBG
var zombie_nine_patch_texture := preload("res://_UI/PurpleCard_WIP.png")
var demon_nine_patch_texture := preload("res://_Entities/Demons/Cards/Empty_Display_CARD.png")

#@onready var visual_tutorial_button_nine_patch := $VisualUnderStoodButton_9Patch

@onready var basicTutorialMessageContainer := $BasicTutorialMessage
@onready var basicTutorialLabel := $BasicTutorialMessage/BasicTutorialVbox/BasicTutorialLabel
@onready var basicTutorialButton :=$BasicTutorialMessage/BasicTutorialVbox/PanelContainer/MarginContainer/BasicTutorialUnderstoodButton
@onready var basicTutorialButton_Container := $BasicTutorialMessage/BasicTutorialVbox/PanelContainer
@onready var basicTutorialVbox := $BasicTutorialMessage/BasicTutorialVbox

@onready var visual_tutorial_panel_container := $VisualTutorialVBox/VisualTutorialPanelContainer
@onready var visualTutorialContainer := $VisualTutorialVBox
@onready var visualTutorialLabel := $VisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialMarginContainer/VisualTutorialHBox/VisualTutorialLabel
@onready var visualTutorialButton := $VisualTutorialVBox/PanelContainer/MarginContainer/VisualTutorialUnderstoodButton
								
@onready var visualTutorialVisual: CenterContainer = $VisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialMarginContainer/VisualTutorialHBox/VisualTutorialVisual
@onready var visualTutorialVisualParent := $VisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialMarginContainer/VisualTutorialHBox
@onready var countdown_timer : Timer = $CountdownTimer

@onready var demon_visual_tutorial_vbox_container := $DemonVisualTutorialVBox
@onready var demon_visual_tutorial_visual := $DemonVisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialVBox/VisualTutorialVisual
@onready var demon_visual_tutorial_parent := $DemonVisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialVBox
@onready var demon_visual_tutorial_button := $DemonVisualTutorialVBox/PanelContainer/MarginContainer/DemonVisualTutorialUnderstoodButton
@onready var demon_visual_tutorial_panel_container := $DemonVisualTutorialVBox/VisualTutorialPanelContainer
@onready var demon_visual_tutorial_label := $DemonVisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialVBox/VisualTutorialLabel
@onready var demon_title_label := $DemonVisualTutorialVBox/VisualTutorialPanelContainer/VisualTutorialVBox/DemonTitle

#@onready var blockInputPanel := $BlockInput

@export var max_basic_tutorial_characters := 200
@export var small_basic_tutorial_text := 22
@export var large_basic_tutorial_text := 32
@export var max_visual_tutorial_characters := 200
@export var small_visual_tutorial_text := 20
@export var large_visual_tutorial_text := 24

@export var tooltip_dissappear_wait_time := 5 

var char_count : int
var index : int
var og_visual_tutorial_location : Vector2
var og_demon_visual_tutorial_vbox_container_position : Vector2



# Thickness of the highlight border (in pixels)
@export var highlight_border_thickness: int = 1

# Color of the highlight border
@export var highlight_border_color: Color = Color.RED
signal ToolTipHid

func _ready() -> void:
	countdown_timer.timeout.connect(hide_self)
	countdown_timer.wait_time = tooltip_dissappear_wait_time
	print("HIDEEE Ready")
	hide()
	demon_visual_tutorial_vbox_container.hide()
	if not basicTutorialButton.pressed.is_connected(_on_basic_tutorial_understood_button_pressed):
		basicTutorialButton.pressed.connect(_on_basic_tutorial_understood_button_pressed)
	if not visualTutorialButton.pressed.is_connected(_on_visual_tutorial_understood_button_pressed):
		visualTutorialButton.pressed.connect(_on_visual_tutorial_understood_button_pressed)

	index = visualTutorialVisual.get_index()
	
	og_visual_tutorial_location = visualTutorialContainer.position
	og_demon_visual_tutorial_vbox_container_position = demon_visual_tutorial_vbox_container.position
	
	
func set_basic_tutorial_text(newFile: String, shouldPause: bool, location : Vector2 = Vector2(0,0)) -> void:
	#visual_tutorial_nine_patch.hide()
	show()
	basicTutorialButton_Container.show()
	basicTutorialVbox.show()
	hide_basic_tutorial_button()
	basicTutorialMessageContainer.visible = true
	basicTutorialMessageContainer.position = location
	visualTutorialContainer.visible = false

	var file := FileAccess.open(newFile, FileAccess.READ)
	var newText := file.get_as_text()
	file.close()

	basicTutorialLabel.text = newText
	char_count = newText.length()
	if char_count > max_basic_tutorial_characters:
		basicTutorialLabel.add_theme_font_size_override("normal_font_size", small_basic_tutorial_text)
	else:
		basicTutorialLabel.add_theme_font_size_override("normal_font_size", large_basic_tutorial_text)
	
	if shouldPause:
		show_basic_tutorial_button()
		get_tree().paused = true

func get_basic_tutorial_container()->Control:
	return basicTutorialMessageContainer

func show_basic_tutorial_button() -> void:
	basicTutorialButton.show()
	basicTutorialButton_Container.show()
	basicTutorialVbox.show()


func hide_basic_tutorial_button() -> void:
	basicTutorialButton.hide()
	basicTutorialButton_Container.hide()
	#basicTutorialVbox.hide()
		
func _on_basic_tutorial_understood_button_pressed() -> void:
	print("HIDEEE Understood Bu")
	hide()
	ToolTipHid.emit()
	get_tree().paused = false
	
			
func set_visual_tutorial_text(newFile: String, show_button: bool = true) -> void:
	show()
	basicTutorialMessageContainer.visible = false
	visualTutorialContainer.visible = true

	var file := FileAccess.open(newFile, FileAccess.READ)
	var newText := file.get_as_text()
	file.close()
	
	visualTutorialLabel.text = newText
	char_count = newText.length()
	get_tree().paused = true
	if char_count > max_visual_tutorial_characters:
		visualTutorialLabel.add_theme_font_size_override("normal_font_size", small_visual_tutorial_text)
	else:
		visualTutorialLabel.add_theme_font_size_override("normal_font_size", large_visual_tutorial_text)
	if show_button:
		visualTutorialButton.show()
	else:
		visualTutorialButton.hide()
	
func set_visual_demon_tutorial_text(newFile: String, show_button: bool = true, demon_title : String = "") -> void:
	show()
	basicTutorialMessageContainer.visible = false
	demon_visual_tutorial_vbox_container.visible = true
	demon_title_label.text = demon_title

	var file := FileAccess.open(newFile, FileAccess.READ)
	var newText := file.get_as_text()
	file.close()
	
	demon_visual_tutorial_label.text = newText
	char_count = newText.length()
	get_tree().paused = true
	if char_count > max_visual_tutorial_characters:
		demon_visual_tutorial_label.add_theme_font_size_override("normal_font_size", small_visual_tutorial_text)
	else:
		demon_visual_tutorial_label.add_theme_font_size_override("normal_font_size", large_visual_tutorial_text)
	if show_button:
		demon_visual_tutorial_button.show()
	else:
		demon_visual_tutorial_button.hide()
			
		
func set_modulate_invis()->void:
	#print("SET INVIS")
	self.modulate = Color(1,1,1,0)
	pass
			
	
		
func set_visual_tutorial_visual(newVisual: CenterContainer, show_button: bool = true, location : Vector2 = Vector2(0,0), zombie_visual : bool = true) -> void:
	visualTutorialVisualParent.remove_child(visualTutorialVisual)
	visualTutorialVisual.queue_free()
	visualTutorialVisualParent.add_child(newVisual)
	visualTutorialVisualParent.move_child(newVisual, index)
	visualTutorialVisual = newVisual
	if show_button:
		visualTutorialButton.show()
	else:
		visualTutorialButton.hide()

		
	visualTutorialContainer.position = og_visual_tutorial_location + location
	if zombie_visual:
		visual_tutorial_panel_container.get_theme_stylebox("panel").texture = zombie_nine_patch_texture
	else:
		visual_tutorial_panel_container.get_theme_stylebox("panel").texture = demon_nine_patch_texture 

func set_visual_demon_tutorial_visual(newVisual: CenterContainer, show_button: bool = true, location : Vector2 = Vector2(0,0)) -> void:
	demon_visual_tutorial_parent.remove_child(visualTutorialVisual)
	demon_visual_tutorial_visual.queue_free()
	demon_visual_tutorial_parent.add_child(newVisual)
	demon_visual_tutorial_parent.move_child(newVisual, index)
	demon_visual_tutorial_visual = newVisual
	demon_visual_tutorial_panel_container.reset_size()
	if show_button:
		demon_visual_tutorial_button.show()
	else:
		demon_visual_tutorial_button.hide()
		
	demon_visual_tutorial_vbox_container.position = og_demon_visual_tutorial_vbox_container_position + location

func new_demon_visual_minimum_size(new_size:Vector2 = Vector2.ZERO)->void:
	demon_visual_tutorial_panel_container.custom_minimum_size = new_size
	demon_visual_tutorial_panel_container.reset_size()
		
		
	
func _on_visual_tutorial_understood_button_pressed() -> void:
	#print("V Button Pressed")
	Global.is_blocking = false
	#print("HIddDEEE")
	hide()
	ToolTipHid.emit()
	get_tree().paused = false


func _on_demon_visual_tutorial_understood_button_pressed() -> void:
	#print("Demon V Button Pressed")
	Global.is_blocking = false
	demon_visual_tutorial_vbox_container.hide()
	#hide()
	ToolTipHid.emit()
	get_tree().paused = false






func start_basic_countdown()->void:
	pass
	print("Start Basic Countdown")
	#countdown_timer.start()

func hide_self()->void:
	pass



func add_pulsing_button_highlight(button:Node, should_pulse : bool = true) -> void:
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
	#for child in button.get_children():
		##print(button, " children are ", child)
		#pass


	# Expand slightly beyond the button to create a border effect
	#var margin := highlight_border_thickness #+ 4
	#panel.position = Vector2(-margin, -margin)
	#panel.position = Vector2(0,0)
	panel.size = button.size #+ Vector2(margin * 2, margin * 2)
	#print(panel.size , " Glow Container Size is ", button.size)
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


func start_glow_pulse(button:Node, _panel: Panel, style: StyleBoxFlat, glow_color: Color = highlight_border_color) -> void:
	if button.has_meta("glow_tween"):
		var old_tween: Tween = button.get_meta("glow_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween :Tween = button.create_tween()
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
	
	
		
	
func stop_glow_pulse(button:Node) -> void:
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
			#print("Going to queue free button highlight : ", button.get_child(0))
			button.get_child(0).queue_free()
			pass
