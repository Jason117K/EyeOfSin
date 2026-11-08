extends Control
## Save-slot picker, reached only from the start screen's Load Game button.
## Picking a slot switches to it at once (see SaveSlots); the screen stays open so the
## purple highlight follows the pick, and Back returns to the start screen.

const START_SCREEN := "res://_Stages/StartScreen/StartScreen.tscn"
const SLOT_COLOR_OVERRIDES: Array[StringName] = [
	&"font_color", &"font_hover_color", &"font_pressed_color", &"font_focus_color", &"font_hover_pressed_color",
]

@export var active_slot_color := Color(0.62, 0.3, 1.0)

@onready var _slot_buttons: Array[Button] = [%SaveButton1, %SaveButton2, %SaveButton3]
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	assert(_slot_buttons.size() == SaveSlots.SLOT_COUNT, "GameSaves needs one button per save slot")
	for i in _slot_buttons.size():
		_slot_buttons[i].pressed.connect(_on_slot_pressed.bind(i + 1))
	_back_button.pressed.connect(_on_back_pressed)
	_refresh()


func _on_slot_pressed(slot: int) -> void:
	if SaveSlots.switch_to(slot):
		_return_sorceries_to_launch_state()
		Global.game_controller.menu_audio.play_menu_music()
	_refresh()


func _on_back_pressed() -> void:
	Global.game_controller.change_scene(START_SCREEN)


func _refresh() -> void:
	for i in _slot_buttons.size():
		var slot := i + 1
		var button := _slot_buttons[i]
		var key := "UI_SAVE_SLOT" if SaveSlots.is_slot_used(slot) else "UI_SAVE_SLOT_EMPTY"
		button.text = tr(key).format({"slot": slot})
		var is_active := slot == SaveSlots.active_slot()
		for color_name: StringName in SLOT_COLOR_OVERRIDES:
			if is_active:
				button.add_theme_color_override(color_name, active_slot_color)
			else:
				button.remove_theme_color_override(color_name)


## Equipped sorceries are session state. Clearing them matches a fresh launch, so a
## sorcery the new slot hasn't unlocked can't carry over, and levels 5+ equip the defaults.
func _return_sorceries_to_launch_state() -> void:
	if is_instance_valid(Global.swap_ability):
		Global.swap_ability.queue_free()
	Global.register_swap_ability_instance(null)
	if is_instance_valid(Global.syn_ability_manager):
		Global.syn_ability_manager.queue_free()
	Global.register_syn_ability_manager(null)
