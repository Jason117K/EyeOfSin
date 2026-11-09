extends Control

var startScreen := "res://_Stages/StartScreen/StartScreen.tscn"
var backButton 
var returning_to_dual_scene := false

@onready var submit_scores_toggle: CheckButton = %SubmitScoresToggle
@onready var sort_by_time_toggle: CheckButton = %SortByTimeToggle

func _ready() -> void:
	# Set process mode to handle input even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	#print("=== OptionsMenu _ready() Debug ===")
	#print("Master slider exists: ", $CenterContainer/VBoxContainer/masterVolumeSlider != null)
	#print("Music slider exists: ", $CenterContainer/VBoxContainer/musicVolumeSlider != null)
	#print("SFX slider exists: ", $CenterContainer/VBoxContainer/sfxVolumeSlider != null)
	#print("Master slider value: ", $CenterContainer/VBoxContainer/masterVolumeSlider.value if $CenterContainer/VBoxContainer/masterVolumeSlider else "null")
	#print("Available audio buses: ")
	for i in AudioServer.bus_count:
		pass
		#print("  Bus ", i, ": ", AudioServer.get_bus_name(i))
	backButton = get_node("BackButton")
	#print("Baack Button is ", backButton)
	#print("Back button disabled: ", backButton.disabled)
	#print("Back button mouse_filter: ", backButton.mouse_filter)
	#print("Process mode: ", process_mode)
	#print("Tree paused: ", get_tree().paused)
	backButton.connect("pressed",_on_back_button_pressed)
	_setup_language_dropdown()
	_setup_leaderboard_toggles()

func _setup_leaderboard_toggles() -> void:
	var has_leaderboards := SteamPlatform.is_available()
	submit_scores_toggle.visible = has_leaderboards
	sort_by_time_toggle.visible = has_leaderboards
	submit_scores_toggle.set_pressed_no_signal(LeaderboardSettings.submits_scores())
	sort_by_time_toggle.set_pressed_no_signal(LeaderboardSettings.sorts_by_time())
	submit_scores_toggle.toggled.connect(LeaderboardSettings.set_submits_scores)
	sort_by_time_toggle.toggled.connect(LeaderboardSettings.set_sorts_by_time)

func _setup_language_dropdown() -> void:
	var dropdown: OptionButton = $CenterContainer/VBoxContainer/languageDropdown
	for entry: Dictionary in Loc.LOCALES:
		dropdown.add_item(str(entry.name))
	var current := Loc.match_supported_locale(TranslationServer.get_locale())
	for i: int in Loc.LOCALES.size():
		if str(Loc.LOCALES[i].code) == current:
			dropdown.select(i)
			break
	dropdown.item_selected.connect(_on_language_selected)

func _on_language_selected(index: int) -> void:
	Loc.set_locale(str(Loc.LOCALES[index].code))

func _on_back_button_pressed() -> void:
	#print("=== BACK BUTTON CLICKED ===")
	#print("About to change scene to: ", startScreen)
#	Global.game_controller.change_scene(startScreen)
	if !returning_to_dual_scene:
		Global.game_controller.change_scene(startScreen)
	else:
		Global.unHideDemonSelectionMenu()
		Global.game_controller.restore_dual_scenes_with_pause()


func make_from_dual_scene_true()->void:
	returning_to_dual_scene = true

func make_from_dual_scene_false()->void:
	returning_to_dual_scene = false
	
	
	
	
	##	
