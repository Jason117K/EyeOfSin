extends Control

enum TutorialState {
	FORCE_SELECT_MAW,
	FORCE_PLACE_MAW,
	EXPLAIN_CODEX,
	EXPLAIN_CHIMERA_ZOMBIE
}


@onready var toolTips = $"../ToolTips"
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $PlantSelectionMenu
@onready var waveManager = $GameLayer/WaveManager
@onready var levelSwitcher = 	$"../LevelSwitcher"
@onready var spotlight_overlay = $"../SpotlightOverlay"  # Reference to CanvasLayer


var level04 = "res://Scenes/LevelScenes/Level0-3.tscn"
var level04Alt = "res://Scenes/LevelScenes/Level0-3_Alternate.tscn"
var tutorial_state: TutorialState = TutorialState.FORCE_SELECT_MAW
var green_dimension


const TUTORIAL_SELECT_MAW = "res://Assets/Text/TextFiles/Level0_2_Tutorial_SelectSunflower.txt"


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	toolTips.set_text(TUTORIAL_SELECT_MAW)
	toolTips.noButtonShow()
	Global.resetSunflowerCount()
	green_dimension = get_parent().get_node("Level0-3_Alternate")
	
	toolTips.connect("ToolTipHid", Callable(self, "_on_tooltip_hidden"))
	waveManager.connect("wave1Started", Callable(self, "_on_wave_1_started"))
	waveManager.connect("wave2Started", Callable(self, "_on_wave_2_started"))
	waveManager.connect("wave3Started", Callable(self, "_on_wave_3_started"))
	
	# Connect to button presses
	var maw_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Maw/MawButton")
	maw_button.connect("pressed", Callable(self, "_on_maw_button_pressed"))
	# Start tutorial
	_transition_to_state(TutorialState.FORCE_SELECT_MAW)
	
	
	levelSwitcher.update_level(level04,level04Alt)


# State transition system
func _transition_to_state(new_state: TutorialState):
	print("[Tutorial] Transition: ", TutorialState.keys()[tutorial_state], " → ", TutorialState.keys()[new_state])
	tutorial_state = new_state

	match new_state:
		TutorialState.FORCE_SELECT_MAW:
			_start_force_select_maw()
		TutorialState.FORCE_PLACE_MAW:
			_start_force_place_maw()
		TutorialState.EXPLAIN_CHIMERA_ZOMBIE:
			_start_explain_chimera()
		TutorialState.EXPLAIN_CODEX:
			_start_explain_codex()

func _start_force_select_maw():
	toolTips.set_text(TUTORIAL_SELECT_MAW)
	toolTips.noButtonShow()

	hide_all_plant_buttons_except_maw()
	highlight_maw_button()

	# ADD THIS: Show spotlight on Maw button
	var maw_button = plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton")
	show_spotlight_at_node(maw_button)

	waveManager.canStartGame = false
	plantSelectionMenu.canSwapScenes = false
	
