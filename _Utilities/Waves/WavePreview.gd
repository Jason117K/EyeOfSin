extends Node2D

signal game_start_requested
signal call_wave_early_requested

@onready var preview_text: RichTextLabel = $Node2D/Control/EnemyPreviewText
@onready var start_game_button: Button = $StartGameButton
@onready var wave_progress_bar : TextureProgressBar = $WaveProgressBar
@onready var next_wave_timer : Timer = $NextWaveTimer

@onready var rebornTexture : TextureRect = $Node2D/Control/AllZombieRowTextures/Row1/RebornTexture
@onready var severedTexture : TextureRect =  $Node2D/Control/AllZombieRowTextures/Row1/SeveredTexture
@onready var unhallowerTexture : TextureRect =  $Node2D/Control/AllZombieRowTextures/Row1/UnhallowerTexture
@onready var erupterTexture : TextureRect =  $Node2D/Control/AllZombieRowTextures/Row2/ErupterTexture
@onready var reanimatorTexture : TextureRect =  $Node2D/Control/AllZombieRowTextures/Row2/ReanimatorTexture
@onready var wretchTexture : TextureRect =  $Node2D/Control/AllZombieRowTextures/Row2/WretchTexture
@onready var flesheaterTexture : TextureRect =  $Node2D/Control/AllZombieRowTextures/Row3/FlesheaterTexture
@onready var amalgamTexture : TextureRect =  $Node2D/Control/AllZombieRowTextures/Row3/AmalgamTexture
@onready var sunderedTexture : TextureRect =  $Node2D/Control/AllZombieRowTextures/Row3/SunderedTexture

@onready var ALL_ZOMBIE_TEXTURES = [rebornTexture,severedTexture,unhallowerTexture, \
									erupterTexture,reanimatorTexture,wretchTexture, \
									flesheaterTexture,amalgamTexture , sunderedTexture]
									
@onready var rebornLabel : Label = $Node2D/Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row1/Reborn
@onready var severedabel : Label = $Node2D/Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row1/Severed
@onready var unhallowerLabel : Label = $Node2D/Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row1/Unhallower
@onready var erupterLabel : Label = $Node2D/Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row2/Erupter
@onready var reanimatorLabel : Label = $Node2D/Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row2/Reanimator
@onready var wretchLabel : Label = $Node2D/Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row2/Wretch
@onready var flesheaterLabel : Label = $Node2D/Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row3/Flesheater
@onready var amalgamLabel : Label = $Node2D/Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row3/Amalgam
@onready var sunderedLabel : Label = $Node2D/Control/ZombieLabelMarginContainer/AllZombieRowLabels/Row3/Sundered

@onready var ALL_ZOMBIE_LABELS = [rebornLabel,severedabel,unhallowerLabel, \
									erupterLabel, reanimatorLabel, wretchLabel, \
									flesheaterLabel, amalgamLabel, sunderedLabel]

var preview_lead_time = 15
var _spawner: ZombieSpawner
var _preview_wave_index: int = -1
var progressing := false 
var elapsed :float = 0.0 


func _ready():
	_spawner = get_parent() as ZombieSpawner
	start_game_button.pressed.connect(_on_start_game_button_pressed)
	hide_preview()


func show_preview(wave_index: int, show_start_button: bool = false) -> void:
	#print("SHOW PREVIEW")
	_preview_wave_index = wave_index
	$PreviewSprite.visible = true
	self.visible = true
	start_game_button.visible = show_start_button
	$Area2D/CollisionShape2D.disabled = false
	next_wave_timer.start()
	if Global.get_wave_manager()._current_wave > -1:
		print("Make visible, current wave is ",Global.get_wave_manager()._current_wave )
		wave_progress_bar.visible = true 
	else:
		wave_progress_bar.visible = false 
		#print("Global Current Wave is , ",  Global.get_wave_manager()._current_wave)
	progressing = true 
	


func hide_preview() -> void:
	#print("HIDE PREIVEW")
	_preview_wave_index = -1
	$PreviewSprite.visible = false
	$Node2D/Control.visible = false
	start_game_button.visible = false
	$Area2D/CollisionShape2D.disabled = true
	preview_text.clear()
	wave_progress_bar.visible = false 
	next_wave_timer.stop()
	progressing = false


func _on_Area2D_mouse_entered():
	if _preview_wave_index < 0 or not $PreviewSprite.visible:
		return
	var config := _spawner.get_wave_config(_preview_wave_index)
	preview_text.clear()
	
	for this_label in ALL_ZOMBIE_LABELS:
		this_label.hide()
		var base_name = this_label.get_name()
		this_label.text = base_name + " x"
	for this_image in ALL_ZOMBIE_TEXTURES:
		this_image.hide()
		
	for type_name in config:
		
		var count: int = config[type_name]
		#print("Type Name is ", type_name, " with count ", count)
		if count > 0:
			preview_text.append_text(str(type_name) + " : " + str(count) + "\n")
			for this_label in ALL_ZOMBIE_LABELS:
				if str(type_name) in this_label.get_name():
					this_label.text = this_label.get_name() + " x" + str(count)
					this_label.show()
			for this_image in ALL_ZOMBIE_TEXTURES:
				if str(type_name) in this_image.get_name():
					this_image.show()
	$Node2D/Control.visible = true

func set_image_value(this_type_name,this_count):
	for this_label in ALL_ZOMBIE_LABELS:
		if this_type_name in this_label.get_name():
			this_label.show()
			this_label.text = this_label.text + str(this_count)
#			this_label.append_text(this_count)
		else:
			this_label.hide()
	for this_image in ALL_ZOMBIE_TEXTURES:
		if this_type_name in this_image.get_name():
			this_image.show()
		else:
			this_image.hide()

func _on_Area2D_mouse_exited():
	$Node2D/Control.visible = false
	preview_text.clear()

func _on_start_game_button_pressed() -> void:
	
	if Global.gameIsStarted:
		print("RequestingGGGGGGG")
		call_wave_early_requested.emit()
		return
	print("starttttttSSS")
	Global.gameIsStarted = true
	game_start_requested.emit()

func _process(delta: float) -> void:
	if progressing:
		elapsed += delta
		wave_progress_bar.value = next_wave_timer.wait_time - next_wave_timer.time_left
		#wave_progress_bar.value = max(next_wave_timer.wait_time - elapsed, 0.0)

func set_preview_lead_time(new_preview_lead_time):
	preview_lead_time = new_preview_lead_time
	wave_progress_bar.max_value = preview_lead_time
	next_wave_timer.wait_time = preview_lead_time
