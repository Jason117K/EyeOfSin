extends Control

var startScreen = ("res://Scenes/LevelScenes/StartScreen.tscn")
var backButton 

func _ready() -> void:
	print("=== OptionsMenu _ready() Debug ===")
	print("Master slider exists: ", $CenterContainer/VBoxContainer/masterVolumeSlider != null)
	print("Music slider exists: ", $CenterContainer/VBoxContainer/musicVolumeSlider != null)
	print("SFX slider exists: ", $CenterContainer/VBoxContainer/sfxVolumeSlider != null)
	print("Master slider value: ", $CenterContainer/VBoxContainer/masterVolumeSlider.value if $CenterContainer/VBoxContainer/masterVolumeSlider else "null")
	print("Available audio buses: ")
	for i in AudioServer.bus_count:
		print("  Bus ", i, ": ", AudioServer.get_bus_name(i))
	backButton = get_node("BackButton")
	print("Baack Button is ", backButton)
	print("Back button disabled: ", backButton.disabled)
	print("Back button mouse_filter: ", backButton.mouse_filter)
	print("Process mode: ", process_mode)
	print("Tree paused: ", get_tree().paused)
	backButton.connect("pressed",_on_back_button_pressed)
	
func _on_back_button_pressed() -> void:
	print("=== BACK BUTTON CLICKED ===")
	print("About to change scene to: ", startScreen)
	Global.game_controller.change_scene(startScreen)
