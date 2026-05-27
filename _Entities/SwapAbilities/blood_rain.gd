extends SwapAbility



func append_new_zombie(new_zombie : Zombie) -> void:
	if is_active == true:
		new_zombie.blood_slow()
		

func apply_swap_ability()->void:
	for zombie : Zombie in Global.get_all_zombies():
		if zombie != null:
			if Global.is_on_purple_dimension():
				if !zombie.is_in_group("Purple"):
					zombie.blood_slow()
			else:
				if !zombie.is_in_group("Green"):
					zombie.blood_slow()


func undo_swap_ability() -> void:
	if is_active:
		for zombie : Zombie in Global.get_all_zombies():
			if zombie != null:
				zombie.undoBloodSlow()
		stop()	
	

	
	
	
	
	
	
	
	
