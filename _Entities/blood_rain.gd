extends Node


var all_zombies = []
var reset_timer : Timer 
var is_active := false

func _ready() -> void:
	print("Swap Ability Ready")
	Global.register_swap_ability(self)
	

	
func begin():
	pass
	is_active = true 
	
	for child in get_children():
		if child.has_method("show"):
			child.show()
	
	all_zombies = Global.get_all_zombies()
	
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
	is_active = false
	

func stop():
	for child in get_children():
		if child.has_method("hide"):
			child.hide()


func append_new_zombie(new_zombie):
	if is_active == true:
		all_zombies.append(new_zombie)
		new_zombie.blood_slow()
		
		
		
		#
	#for zombie in all_zombies:
		#if new_zombie == zombie:
			#return
	#all_zombies.append(new_zombie)
	#new_zombie.blood_slow()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
