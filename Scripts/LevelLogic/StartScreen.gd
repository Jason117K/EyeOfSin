extends Control
#StartScreen.gd

@onready var startGameButton = $CenterContainer/VBoxContainer/StartGame
@onready var levelSelectButton = $CenterContainer/VBoxContainer/LevelSelectButton
@onready var bgMusic = $BackGroundMuisc
#Sets up the startscreen tiles
func _ready():
	# Get fresh reference
	startGameButton = $CenterContainer/VBoxContainer/StartGame
		# Always disconnect any existing connections first
	if startGameButton.pressed.is_connected(_on_start_game_pressed):
		startGameButton.pressed.disconnect(_on_start_game_pressed)
	print("=== Button Debug Info ===")
	print("Button exists: ", startGameButton != null)
	print("Button disabled: ", startGameButton.disabled if startGameButton else "null")
	print("Button visible: ", startGameButton.visible if startGameButton else "null")
	print("Button mouse_filter: ", startGameButton.mouse_filter if startGameButton else "null")
	print("Button instance ID: ", startGameButton.get_instance_id() if startGameButton else "null")
	
	if startGameButton and not startGameButton.pressed.is_connected(_on_start_game_pressed):
		var result = startGameButton.pressed.connect(_on_start_game_pressed)
		print("Connection result: ", result)
		
	#$GridManager.set_tiles_for_rows(0,1, 68)
	#$GridManager.set_tiles_for_rows(1,2, 66)
	#
	#$GridManager.set_tiles_for_rows(2,3, 63)
	#$GridManager.set_tiles_for_rows(3,4, 63)
	#$GridManager.set_tiles_for_rows(4,5, 63)
	#$GridManager.set_tiles_for_rows(5,6, 63)
	#$GridManager.set_tiles_for_rows(6,7, 63)
	#
	#$GridManager.set_tiles_for_rows(7,8, 66)
	#$GridManager.set_tiles_for_rows(8,9, 69)
	
	startGameButton.get_theme_stylebox("normal").bg_color = Color.BLACK


	bgMusic.playing = true
	
	levelSelectButton.pressed.connect(_on_level_select_button_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_start_game_pressed() -> void:
	print("I KNOW U WERE CLICKED")
	Global.game_controller.change_scene("res://Scenes/LevelScenes/Main.tscn")



func _on_level_select_button_pressed() -> void:
	print("Button Worky")
	Global.game_controller.change_scene("res://Scenes/LevelScenes/LevelSelect.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit() 


func _on_credits_pressed() -> void:
	Global.game_controller.change_scene("res://Scenes/LevelScenes/CreditsScene.tscn")


func _on_options_pressed() -> void:
	Global.game_controller.change_scene("res://Scenes/Systems/OptionsMenu.tscn")
