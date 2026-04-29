extends Node


var all_zombies = []

func _ready() -> void:
	Global.register_blood_rain(self)
	

	
func begin():
	for child in get_children():
		child.show()
	for zombie in Global.get_all_zombies():
		zombie.blood_slow()


func stop():
	for child in get_children():
		child.hide()
