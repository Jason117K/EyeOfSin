extends Control

@onready var blood_label := $HUD_Panel/HUD_HBox/Blood_VBox/BloodAmountLabel
@onready var health_label := $HUD_Panel/HUD_HBox/Health_VBox/HealthAmountLabel

var blood_amount = 50

func _ready() -> void:
	Global.register_ui_layer(self)
	if blood_label != null:
		blood_label.text = blood_amount

func get_the_health():
	return health_label

func set_blood(new_blood_amount):
	#print("SETTING NEW BLOOD ", new_blood_amount)
	blood_label.text = new_blood_amount
	
func set_initial_blood(new_blood_amount):
	#print("SETTING NEW BLOOD ", new_blood_amount)
	blood_amount = new_blood_amount
