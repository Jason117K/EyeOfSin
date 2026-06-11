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

func undo_swap_opacity()->void:
	swap_ability_display.self_modulate = Color(1,1,1,1)
	
func undo_syn_opacity()->void:
	syn_ability_display.self_modulate = Color(1,1,1,1)
	
	
func _on_blood_rain_button_pressed() -> void:
	undo_swap_opacity()
	print("Blood Rain Button Pressed")
	swap_label.text = "Summon a storm of blood slowing all zombies on the screen"
	swap_title.text = "BLOOD RAIN"
	swap_ability_display.texture = blood_rain_button.texture_normal
	Global.register_swap_ability(blood_rain)


func _on_lightning_storm_button_pressed() -> void:
	undo_swap_opacity()
	swap_ability_display.texture = lightning_storm_button.texture_normal
	Global.register_swap_ability(lightning_storm)
	swap_label.text = "Summon a storm of lightning damaging zombies at random"
	swap_title.text = "BLOOD RAIN"

func _on_lucretia_grasp_button_pressed() -> void:
	undo_swap_opacity()
	swap_ability_display.texture = lucretia_grasp_button.texture_normal
	Global.register_swap_ability(lucretia_grasp)
	swap_label.text = "Summon forth hands that cross the screen and flip zombie allegiances"
	swap_title.text = "GRASP OF LUCRETIA"
	
func _on_baal_gaze_button_pressed() -> void:
	undo_swap_opacity()
	swap_ability_display.texture = baal_gaze_button.texture_normal
	Global.register_swap_ability(baal_gaze)

	swap_label.text = "Summon a [REDACTED] for assitance"
	swap_title.text = "GAZE OF BAAL"


func _on_lightning_strike_button_pressed() -> void:
	undo_syn_opacity()
	syn_ability_display.texture = lightning_strike_button.texture_normal
	Global.register_syn_ability(lightning_strike)

	syn_label.text = "Summon a bolt of lightning in a location"
	syn_ability_title.text = "Lightning Strike"

func _on_shield_button_pressed() -> void:
	syn_ability_display.texture = shield_button.texture_normal
	Global.register_syn_ability(syn_shield)
	syn_label.text = "Conjure powerful shields to protect your demons "
	syn_ability_title.text = "Syn Shields"
	
func _on_blood_ice_button_pressed() -> void:
	syn_ability_display.texture = blood_ice_button.texture_normal
	Global.register_syn_ability(blood_ice)
	syn_label.text = "Summon ice spikes from the ground that trigger bleed"
	syn_ability_title.text = "Blood Ice"

func _on_death_mark_button_pressed() -> void:
	syn_ability_display.texture = death_mark_button.texture_normal
	Global.register_syn_ability(death_mark)
	syn_label.text = "Curse zombies, causing them to take more damage from all sources"
	syn_ability_title.text = "Death Mark"
	
func _on_shroomie_button_pressed() -> void:
	syn_ability_display.texture = shroomie_button.texture_normal
	Global.register_syn_ability(shroomie)
	syn_label.text = "Summon a fungal friend that sets demon projectiles on fire, buffing them"
	syn_ability_title.text = "SHROOMIE"

func _on_back_plain_button_pressed() -> void:
	Global.game_controller.change_scene(map_screen)
	
