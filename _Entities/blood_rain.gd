extends Node


var all_zombies = []

func _ready() -> void:
	Global.register_blood_rain(self)
	

	
func begin():
	for child in get_children():
		child.show()
