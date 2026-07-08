extends SwapAbility

#9
#25

func append_new_zombie(new_zombie : Zombie) -> void:
	
	if is_active == true:
		#print("Should Blood Slow ", new_zombie)
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		#print("Will Now Blood Slow ", new_zombie)
		new_zombie.blood_slow()
		affected_zombies.append(new_zombie)
		

func apply_swap_ability()->void:
	for zombie : Zombie in Global.get_all_zombies():
		if zombie != null:
			if Global.is_on_purple_dimension():
				if !zombie.is_in_group("Purple"):
					zombie.blood_slow()
					affected_zombies.append(zombie)
					
			else:
				if !zombie.is_in_group("Green"):
					zombie.blood_slow()
					affected_zombies.append(zombie)
					
				


func undo_swap_ability() -> void:
	if is_active:
		for zombie in affected_zombies: #Global.get_all_zombies():
			if zombie != null && is_instance_valid(zombie):
				zombie.undoBloodSlow()
		stop()	
	affected_zombies.clear()
	
func get_icon()->Texture:
	return Global.blood_rain_icon
	
	
	
	
	
	
	
	
