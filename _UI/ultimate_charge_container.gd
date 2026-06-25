extends Control

@export var mana_per_charge := 1000
@onready var empty_charge_texture := load("res://_UI/UltCharge_Empty.png")
@onready var full_charge_texture := load("res://_UI/UltCharge_Full.png")
@onready var charge_progress_bar : ProgressBar = $UltimateVboxContainer/UltimateChargeProgressBar
@onready var charges_hbox_container := $UltimateVboxContainer/AllChargeHboxContainer
@onready var all_charges_panel_container := $UltimateVboxContainer/AllChargesPanelContainer
@onready var charge_1 := $UltimateVboxContainer/AllChargesPanelContainer/AllChargeHboxContainer/Charge1
@onready var charge_2 := $UltimateVboxContainer/AllChargesPanelContainer/AllChargeHboxContainer/Charge2
@onready var charge_3 := $UltimateVboxContainer/AllChargesPanelContainer/AllChargeHboxContainer/Charge3
@onready var charge_4 := $UltimateVboxContainer/AllChargesPanelContainer/AllChargeHboxContainer/Charge4

var current_mana := 0 
var charges := 0 
var max_charges := 4


@onready var all_charges :Array[TextureButton]= [charge_1,charge_2,charge_3,charge_4]
@onready var all_charges_backwards :Array[TextureButton]= [charge_4,charge_3,charge_2,charge_1]

func _ready() -> void:
	Global.ultimate_charge_container = self 
	for charge in all_charges:
		charge.pressed.connect(ready_ultimate)
		charge.texture_normal = empty_charge_texture
	set_progress_bar_value(current_mana)

func add_mana(mana_to_add : float)->void:
	current_mana = current_mana + mana_to_add
	if current_mana >= mana_per_charge:
		if charges < max_charges:
			increase_ultimate_charges()
			current_mana = 0
	set_progress_bar_value(current_mana)
	
func increase_ultimate_charges()->void:
	charges = charges + 1
	for charge in all_charges:
		if charge.texture_normal == empty_charge_texture:
			charge.texture_normal = full_charge_texture
			return 
		
func ready_ultimate()->void:
	if charges > 0:
		charges = charges - 1
		Global.ultimate_is_ready = true 
		Global.add_pulsing_button_highlight(all_charges_panel_container)
		
func un_ready_ultimate()->void:
	Global.remove_pulsing_button_highlight(all_charges_panel_container)
	for charge in all_charges_backwards:
		if charge.texture_normal == full_charge_texture:
			charge.texture_normal = empty_charge_texture
			return 
					
func set_progress_bar_value(new_progress_bar_value : float)->void:
	charge_progress_bar.value = (new_progress_bar_value / mana_per_charge) * 100 
	
		
		
		
		
		
##
	
