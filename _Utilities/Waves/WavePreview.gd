extends Node2D

signal game_start_requested
signal call_wave_early_requested

@onready var preview_text: RichTextLabel = $Node2D/Control/EnemyPreviewText
@onready var start_game_button: Button = $StartGameButton

var _spawner: ZombieSpawner
var _preview_wave_index: int = -1


func _ready():
	_spawner = get_parent() as ZombieSpawner
	start_game_button.pressed.connect(_on_start_game_button_pressed)
	hide_preview()


func show_preview(wave_index: int, show_start_button: bool = false) -> void:
	print("SHOW PREVIEW")
	_preview_wave_index = wave_index
	$PreviewSprite.visible = true
	self.visible = true
	start_game_button.visible = show_start_button
	$Area2D/CollisionShape2D.disabled = false


func hide_preview() -> void:
	print("HIDE PREIVEW")
	_preview_wave_index = -1
	$PreviewSprite.visible = false
	$Node2D/Control.visible = false
	start_game_button.visible = false
	$Area2D/CollisionShape2D.disabled = true
	preview_text.clear()


func _on_Area2D_mouse_entered():
	if _preview_wave_index < 0 or not $PreviewSprite.visible:
		return
	var config := _spawner.get_wave_config(_preview_wave_index)
	preview_text.clear()
	for type_name in config:
		var count: int = config[type_name]
		if count > 0:
			preview_text.append_text(str(type_name) + " : " + str(count) + "\n")
	$Node2D/Control.visible = true


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
