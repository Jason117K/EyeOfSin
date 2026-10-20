extends Control

@onready var swap_ability_display : TextureRect = $PanelContainer/VBoxContainer/SwapPanel/VBoxContainer/HBoxContainer/SwapAbilityDisplayTexture
@onready var syn_ability_display : TextureRect = $PanelContainer/VBoxContainer/SynPanel/VBoxContainer/HBoxContainer2/SynAbilityDisplayTexture

@onready var swap_label := $PanelContainer/VBoxContainer/SwapPanel/VBoxContainer/HBoxContainer/VBoxContainer/SwapLabel
@onready var swap_title := $PanelContainer/VBoxContainer/SwapPanel/VBoxContainer/HBoxContainer/VBoxContainer/SwapTitle

@onready var syn_label := $PanelContainer/VBoxContainer/SynPanel/VBoxContainer/HBoxContainer2/VBoxContainer/SynAbilityLabel
@onready var syn_ability_title := $PanelContainer/VBoxContainer/SynPanel/VBoxContainer/HBoxContainer2/VBoxContainer/SynAbilityTitle


@onready var blood_rain_button := $PanelContainer/VBoxContainer/SwapPanel/VBoxContainer/SwapAbilitiesMargin/SwapAbilitiesHbox/BloodRainButton
@onready var lucretia_grasp_button := $PanelContainer/VBoxContainer/SwapPanel/VBoxContainer/SwapAbilitiesMargin/SwapAbilitiesHbox/LucretiaGraspButton
@onready var lightning_storm_button := $PanelContainer/VBoxContainer/SwapPanel/VBoxContainer/SwapAbilitiesMargin/SwapAbilitiesHbox/LightningStormButton
@onready var baal_gaze_button := $PanelContainer/VBoxContainer/SwapPanel/VBoxContainer/SwapAbilitiesMargin/SwapAbilitiesHbox/BaalGazeButton

@onready var blood_rain := preload("res://_Entities/SwapAbilities/blood_rain_swap_ability.tscn")
@onready var lucretia_grasp := preload("res://_Entities/SwapAbilities/lucretia_grasp_swap_ability.tscn")
@onready var lightning_storm := preload("res://_Entities/SwapAbilities/lightning_storm_swap_ability.tscn")
@onready var baal_gaze := preload("res://_Entities/SwapAbilities/gaze_of_baal_swap_ability.tscn")

@onready var lightning_strike_button := $PanelContainer/VBoxContainer/SynPanel/VBoxContainer/SynAbilitiesHbox/LightningStrikeButton
@onready var shield_button := $PanelContainer/VBoxContainer/SynPanel/VBoxContainer/SynAbilitiesHbox/ShieldButton
@onready var blood_ice_button := $PanelContainer/VBoxContainer/SynPanel/VBoxContainer/SynAbilitiesHbox/BloodIceButton
@onready var death_mark_button := $PanelContainer/VBoxContainer/SynPanel/VBoxContainer/SynAbilitiesHbox/DeathMarkButton
@onready var shroomie_button := $PanelContainer/VBoxContainer/SynPanel/VBoxContainer/SynAbilitiesHbox/ShroomieButton

@onready var lightning_strike := preload("res://_Entities/SynAbility/syn_lightning_ability_bolt.tscn")
@onready var syn_shield := preload("res://_Entities/SynAbility/syn_shield_ability.tscn")
@onready var blood_ice := preload("res://_Entities/SynAbility/syn_ice_ability.tscn")
@onready var death_mark := preload("res://_Entities/SynAbility/syn_ability_mark.tscn")
@onready var shroomie := preload("res://_Entities/SynAbility/syn_torch_ability.tscn")

var map_screen := "res://_Stages/LevelSelect/LevelSelect_Map.tscn"
var level_select_screen := "res://_Stages/LevelSelect/act_select.tscn"

# Sorcery id (Progress.SORCERY_UNLOCKS key) -> its button, scene, tr() key stem
# (ABILITY_<key>_TITLE/_DESC) and slot (Swap or Syn).
@onready var _sorceries : Dictionary = {
	&"blood_rain": {"button": blood_rain_button, "scene": blood_rain, "key": "BLOOD_RAIN", "swap": true},
	&"lightning_storm": {"button": lightning_storm_button, "scene": lightning_storm, "key": "LIGHTNING_STORM", "swap": true},
	&"lucretia_grasp": {"button": lucretia_grasp_button, "scene": lucretia_grasp, "key": "LUCRETIA_GRASP", "swap": true},
	&"baal_gaze": {"button": baal_gaze_button, "scene": baal_gaze, "key": "BAAL_GAZE", "swap": true},
	&"lightning_strike": {"button": lightning_strike_button, "scene": lightning_strike, "key": "LIGHTNING_STRIKE", "swap": false},
	&"syn_shields": {"button": shield_button, "scene": syn_shield, "key": "SYN_SHIELDS", "swap": false},
	&"blood_ice": {"button": blood_ice_button, "scene": blood_ice, "key": "BLOOD_ICE", "swap": false},
	&"death_mark": {"button": death_mark_button, "scene": death_mark, "key": "DEATH_MARK", "swap": false},
	&"shroomie": {"button": shroomie_button, "scene": shroomie, "key": "SHROOMIE", "swap": false},
}

var stars_label : Label # built in _ready from a copy of swap_title


func _ready() -> void:
	stars_label = swap_title.duplicate()
	stars_label.name = "StarsLabel"
	var panel_vbox := $PanelContainer/VBoxContainer
	panel_vbox.add_child(stars_label)
	panel_vbox.move_child(stars_label, 0)
	refresh_locks()
	# The only menu that shows the Swap/Syn bars (change_scene hides them on the way out).
	Global.game_controller.show_swap_syn()


# Also called by GameController after the Ctrl+U debug unlock.
func refresh_locks() -> void:
	for id: StringName in _sorceries:
		var button : TextureButton = _sorceries[id].button
		var unlocked := Progress.is_sorcery_unlocked(id)
		button.modulate = Color.WHITE if unlocked else UiFx.LOCKED_MODULATE
		button.tooltip_text = "" if unlocked else Progress.sorcery_requirement_text(id)
	stars_label.text = tr("UI_STARS_TOTAL").format({"stars": Progress.total_stars()})


func undo_swap_opacity()->void:
	swap_ability_display.self_modulate = Color(1,1,1,1)

func undo_syn_opacity()->void:
	syn_ability_display.self_modulate = Color(1,1,1,1)


# Locked sorceries stay clickable so the player can read the requirement, but never equip.
func _select(id : StringName) -> void:
	var entry : Dictionary = _sorceries[id]
	var is_swap : bool = entry.swap
	var display : TextureRect = swap_ability_display if is_swap else syn_ability_display
	var title : Label = swap_title if is_swap else syn_ability_title
	var label : RichTextLabel = swap_label if is_swap else syn_label
	display.texture = entry.button.texture_normal
	title.text = tr("ABILITY_%s_TITLE" % entry.key)
	if not Progress.is_sorcery_unlocked(id):
		display.self_modulate = UiFx.LOCKED_MODULATE
		label.text = Progress.sorcery_requirement_text(id)
		return
	display.self_modulate = Color(1,1,1,1)
	label.text = tr("ABILITY_%s_DESC" % entry.key)
	if is_swap:
		Global.register_swap_ability(entry.scene)
	else:
		Global.register_syn_ability(entry.scene)


func _on_blood_rain_button_pressed() -> void:
	_select(&"blood_rain")

func _on_lightning_storm_button_pressed() -> void:
	_select(&"lightning_storm")

func _on_lucretia_grasp_button_pressed() -> void:
	_select(&"lucretia_grasp")

func _on_baal_gaze_button_pressed() -> void:
	_select(&"baal_gaze")

func _on_lightning_strike_button_pressed() -> void:
	_select(&"lightning_strike")

func _on_shield_button_pressed() -> void:
	_select(&"syn_shields")

func _on_blood_ice_button_pressed() -> void:
	_select(&"blood_ice")

func _on_death_mark_button_pressed() -> void:
	_select(&"death_mark")

func _on_shroomie_button_pressed() -> void:
	_select(&"shroomie")

func _on_back_plain_button_pressed() -> void:
	Global.game_controller.change_scene(level_select_screen)
	
