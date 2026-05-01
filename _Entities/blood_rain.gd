extends Node


var all_zombies = []

func _ready() -> void:
	print("Swap Ability Ready")
	Global.register_swap_ability(self)
	

	
func begin():
	for child in get_children():
		child.show()
	for zombie in Global.get_all_zombies():
		zombie.blood_slow()


func stop():
	for child in get_children():
		child.hide()
