extends Control

@onready var blood_label := $HUD_Panel/MarginContainer/HUD_HBox/Blood_VBox/BloodAmountLabel
@onready var health_label := $HUD_Panel/MarginContainer/HUD_HBox/Health_VBox/HealthAmountLabel
@export var make_green := false
@onready var health_icon :TextureRect = $HUD_Panel/MarginContainer/HUD_HBox/Health_VBox/Health_Icon

var blood_amount: float = 50
var rect_region : Rect2 

func _ready() -> void:
	Global.register_ui_layer(self)
	if blood_label != null:
		blood_label.text = str(blood_amount)
	
	if make_green:
		rect_region = Rect2(0,0,32,32)
		health_icon.texture.region = rect_region

func get_blood_panel()->Control:
	return $HUD_Panel/MarginContainer/HUD_HBox/Blood_VBox/Blood_Icon

func get_health_panel()->Control:
	return $HUD_Panel/MarginContainer/HUD_HBox/Health_VBox/Health_Icon

func get_the_health() -> Node:
	return health_label

func set_blood(new_blood_amount: float) -> void:
	#print("SETTING NEW BLOOD ", new_blood_amount)
	blood_label.text = str(new_blood_amount)
	
func set_initial_blood(new_blood_amount: float) -> void:
	#print("SETTING NEW BLOOD ", new_blood_amount)
	blood_amount = new_blood_amount
	if blood_label != null:
		blood_label.text = str(blood_amount)
