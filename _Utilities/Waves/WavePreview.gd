extends Node2D

signal game_start_requested
signal call_wave_early_requested

@onready var visual_preview_container := $ZombiePreviewControl

#@onready var preview_text: RichTextLabel = $Control/EnemyPreviewText
@onready var start_game_button: Button = $StartGameButton
@onready var wave_progress_bar: TextureProgressBar = $WaveProgressBar
@onready var next_wave_timer: Timer = $NextWaveTimer

@onready var rebornTexture: TextureRect = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/RebornVbox/RebornTexture
@onready var severedTexture: TextureRect = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/SeveredVbox/SeveredTexture
@onready var unhallowerTexture: TextureRect = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/UnhallowerVbox/UnhallowerTexture
@onready var erupterTexture: TextureRect = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/ErupterVbox/ErupterTexture
@onready var reanimatorTexture: TextureRect = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/ReanimatorVbox/ReanimatorTexture
#@onready var wretchTexture: TextureRect = 
@onready var flesheaterTexture: TextureRect = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/FlesheaterVbox/FlesheaterTexture
@onready var amalgamTexture: TextureRect = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/AmalgamVbox/AmalgamTexture
@onready var sunderedTexture: TextureRect = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/SunderedVbox/SunderedTexture

@onready var ALL_ZOMBIE_TEXTURES := [rebornTexture,severedTexture,unhallowerTexture, \
									erupterTexture,reanimatorTexture, \
									flesheaterTexture,amalgamTexture , sunderedTexture]
									
@onready var rebornLabel: Label = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/RebornVbox/Reborn
@onready var severedabel: Label = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/SeveredVbox/Severed
@onready var unhallowerLabel: Label = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/UnhallowerVbox/Unhallower
@onready var erupterLabel: Label = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/ErupterVbox/Erupter 
@onready var reanimatorLabel: Label = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/ReanimatorVbox/Reanimator
#@onready var wretchLabel: Label = $Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row2/Wretch
@onready var flesheaterLabel: Label = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/FlesheaterVbox/Flesheater
@onready var amalgamLabel: Label = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/AmalgamVbox/Amalgam
@onready var sunderedLabel: Label = $ZombiePreviewControl/ZombiePreviewPanel/AllZombieTexturesHBox/SunderedVbox/Sundered

@onready var zombie_preview_panel : PanelContainer = $ZombiePreviewControl/ZombiePreviewPanel

@onready var timer_label : Label = $TimerLabel

@onready var ALL_ZOMBIE_LABELS := [rebornLabel,severedabel,unhallowerLabel, \
									erupterLabel, reanimatorLabel, \
									flesheaterLabel, amalgamLabel, sunderedLabel]
									
@onready var zombie_preview_control := $ZombiePreviewControl

var can_click := false 
var preview_lead_time :float= 15
var _spawner: ZombieSpawner
var _preview_wave_index: int = -1
var progressing := false
var elapsed: float = 0.0

var ui_layer_is_green := false
var is_green := false

signal hover_over_preview
signal preview_setup 

func _ready() -> void:
	#zombie_preview_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	#reset_panel_size()
	Global.register_wave_preview(self)
	_spawner = get_parent() as ZombieSpawner
	start_game_button.pressed.connect(_on_start_game_button_pressed)
	hide_preview()
	show_preview(0)
	
	ui_layer_is_green = get_parent().get_parent().get_parent().get_node("UILayer").make_green
	if ui_layer_is_green == true :
		is_green = true
		
	#_on_Area2D_mouse_entered()

func reset_panel_size()->void:
	var right_edge = zombie_preview_panel.position.x + zombie_preview_panel.size.x
	zombie_preview_panel.reset_size()
	zombie_preview_panel.position.x = right_edge - zombie_preview_panel.size.x
	preview_setup.emit()

func set_green() -> void:
	ui_layer_is_green = get_parent().get_parent().get_parent().get_node("UILayer").make_green
	if ui_layer_is_green == true :
		is_green = true			

func make_preview_visible()->void:
	if _preview_wave_index < 0:
		return
	var config := _spawner.get_wave_config(_preview_wave_index)
	if config.size() > 0:
		self.visible = true 
	else:
		self.visible = false

func show_preview(wave_index: int, show_start_button: bool = false) -> void:
	Global.adjust_ui_layer()
	reset_panel_size()
	#print("SHOW PREVIEW")
	_preview_wave_index = wave_index
	$PreviewSprite.visible = true
	self.visible = true
	start_game_button.visible = show_start_button
	$Area2D/CollisionShape2D.disabled = false
	next_wave_timer.start()
	if Global.get_wave_manager()._current_wave > -1:
		#print("Make visible, current wave is ",Global.get_wave_manager()._current_wave )
		wave_progress_bar.visible = true
		#timer_label.visible = true
	else:
		wave_progress_bar.visible = false
		timer_label.visible = false 
		#print("Global Current Wave is , ",  Global.get_wave_manager()._current_wave)
	progressing = true
	#get_parent().emit_show_preview()
	get_parent().emit_signal("show_preview_icon")
	


func hide_preview() -> void:
	reset_panel_size()
	#print("HIDE PREIVEW")
	_preview_wave_index = -1
	$PreviewSprite.visible = false
	zombie_preview_control.visible = false
	start_game_button.visible = false
	$Area2D/CollisionShape2D.disabled = true
	#preview_text.clear()
	wave_progress_bar.visible = false
	next_wave_timer.stop()
	progressing = false


func _on_Area2D_mouse_entered() -> void:
	if !can_click:
		print($Area2D, " was mouse EARLY RETURN entered ", get_parent().get_parent().get_parent())
		print($Area2D, " input pickable was set to ", $Area2D.input_pickable)
		return 
	print($Area2D, " was mouse entered ", get_parent().get_parent().get_parent())
	reset_panel_size()
	hover_over_preview.emit()
	if _preview_wave_index < 0 or not $PreviewSprite.visible:
		return
	var config := _spawner.get_wave_config(_preview_wave_index)
	var has_one_zombie : bool = false
	#preview_text.clear()
	
	for this_label:Label in ALL_ZOMBIE_LABELS:
		this_label.hide()
		var base_name :String= this_label.get_name()
		this_label.text = base_name.to_upper() + " X"
	for this_image:TextureRect in ALL_ZOMBIE_TEXTURES:
		this_image.hide()
		this_image.get_parent().hide()
		
	for type_name:String in config:
		
		var count: int = config[type_name]
		#print("Type Name is ", type_name, " with count ", count)
		if count > 0:
			#preview_text.append_text(str(type_name) + " : " + str(count) + "\n")
			for this_label:Label in ALL_ZOMBIE_LABELS:
				if str(type_name) in this_label.get_name():
					#this_label.text = this_label.get_name().to_upper() + " X" + str(count)
					this_label.text = "X" + str(count)
					this_label.show()
			for this_image:TextureRect in ALL_ZOMBIE_TEXTURES:
				if str(type_name) in this_image.get_name():
					this_image.show()
					this_image.get_parent().show()
					has_one_zombie = true 
	reset_panel_size()			
	if has_one_zombie:	
		self.visible = true 
		visual_preview_container.visible = true
	else:
		self.visible = false 
		visual_preview_container.visible = false
	
	if Global.get_wave_manager()._current_wave > -1:
		timer_label.visible = true
	else:
		timer_label.visible = false 

func set_image_value(this_type_name:String, this_count:int) -> void:
	reset_panel_size()
	for this_label:Label in ALL_ZOMBIE_LABELS:
		if this_type_name in this_label.get_name():
			this_label.show()
			this_label.text = this_label.text + str(this_count)
#			this_label.append_text(this_count)
		else:
			this_label.hide()
	for this_image:TextureRect in ALL_ZOMBIE_TEXTURES:
		if this_type_name in this_image.get_name():
			this_image.show()
		else:
			this_image.hide()

func _on_Area2D_mouse_exited() -> void:
	if !can_click:
		return 
	reset_panel_size()
	visual_preview_container.visible = false
	timer_label.visible = false 
	#preview_text.clear()

func get_preview_icon_panel()->Control:
	
	return start_game_button

func _on_start_game_button_pressed() -> void:
	
	if Global.gameIsStarted:
		print("RequestingGGGGGGG")
		call_wave_early_requested.emit()
		return
	print("starttttttSSS")
	Global.start_game()
	Global.gameIsStarted = true
	game_start_requested.emit()

func _process(delta: float) -> void:
	if progressing:
		elapsed += delta
		wave_progress_bar.value = next_wave_timer.wait_time - next_wave_timer.time_left
		timer_label.text = str(int(next_wave_timer.time_left))
		#wave_progress_bar.value = max(next_wave_timer.wait_time - elapsed, 0.0)

func set_preview_lead_time(new_preview_lead_time:float) -> void:
	preview_lead_time = new_preview_lead_time
	wave_progress_bar.max_value = preview_lead_time
	next_wave_timer.wait_time = preview_lead_time
	
func set_detect_mouse(detection_enabled:bool)->void:
	if detection_enabled:
		print(self, " Enable detection for ", get_parent().get_parent().get_parent())
		$Area2D.input_pickable = true
		start_game_button.mouse_filter = Control.MOUSE_FILTER_STOP
		can_click = true

		
	else:
		print(self, " Disable detection for ", get_parent().get_parent().get_parent())
		$Area2D.input_pickable = false
		start_game_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		can_click = false
		
		#self.visible = false
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	##
