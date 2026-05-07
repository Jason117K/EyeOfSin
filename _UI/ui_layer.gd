extends Control

@onready var blood_label := $HUD_Panel/HUD_HBox/Blood_VBox/BloodAmountLabel

func _ready() -> void:
	Global.register_ui_layer(self)

func get_the_health():
	return $HBoxContainer2/Health

func set_blood(new_blood_amount):
	print("SETTING NEW BLOOD ", new_blood_amount)
	blood_label.text = new_blood_amount
