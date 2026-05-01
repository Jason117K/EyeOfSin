extends Node


var all_zombies = []
var reset_timer : Timer 

func _ready() -> void:
	print("Swap Ability Ready")
	Global.register_swap_ability(self)
	

	
func begin():
	pass
	for child in get_children():
		if child.has_method("show"):
			child.show()
	for zombie in Global.get_all_zombies():
		zombie.blood_slow()
		
	reset_timer = Timer.new()
	reset_timer.one_shot = true 
	reset_timer.autostart = false
	reset_timer.wait_time = 5
	reset_timer.timeout.connect(undoBloodSlow)
	add_child(reset_timer)
	reset_timer.start()
	
	
#TODO Undo The Hue Shift
func undoBloodSlow():
	for zombie in Global.get_all_zombies():
		zombie.undoBloodSlow()
	stop()
	

func stop():
	for child in get_children():
		if child.has_method("hide"):
			child.hide()
