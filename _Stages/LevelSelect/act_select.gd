extends Control

var startScreen := ("res://_Stages/StartScreen/StartScreen.tscn")

var act_1_level_select := "res://_Stages/LevelSelect/LevelSelect_A1.tscn"
var act_2_level_select := "res://_Stages/LevelSelect/LevelSelect_A2.tscn"
var act_3_level_select := "res://_Stages/LevelSelect/LevelSelect_A3.tscn"

@onready var act_1_button := $CenterContainer/HBoxContainer/Act1_PanelContainer/Act1_Button
@onready var act_buttons_hbox := $CenterContainer/HBoxContainer

func _ready() -> void:
	# The scene already wires this; connect only if it was removed there.
	if not act_1_button.pressed.is_connected(_on_act_1_button_pressed):
		act_1_button.pressed.connect(_on_act_1_button_pressed)
	refresh_locks()


# Also called by GameController after the Ctrl+U debug unlock.
func refresh_locks() -> void:
	for act in range(2, Progress.ACTS.size() + 1):
		var panel: Control = act_buttons_hbox.get_node("Act%d_PanelContainer" % act)
		var button: BaseButton = panel.get_node("Act%d_Button" % act)
		UiFx.set_locked(panel, button, not Progress.is_act_unlocked(act))


func _on_act_1_button_pressed() -> void:
	print("Act 1 Button Pressed")
	Global.game_controller.change_scene(act_1_level_select)


func _on_act_2_button_pressed() -> void:
	Global.game_controller.change_scene(act_2_level_select)


func _on_act_3_button_pressed() -> void:
	Global.game_controller.change_scene(act_3_level_select)


func _on_back_button_pressed() -> void:
	Global.game_controller.change_scene(startScreen)
