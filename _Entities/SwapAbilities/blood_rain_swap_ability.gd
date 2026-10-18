extends SwapAbility

#9
#25

# The dimension the rain falls on, set at apply time (begin() runs before the
# flip, so it is the dimension being entered).
var rain_group := ""

# Zombies that spawn while the rain is up (called from Global.register_zombie,
# for both dimensions).
func append_new_zombie(new_zombie : Zombie) -> void:
	if not is_active:
		return
	##print("Should Blood Slow ", new_zombie)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	# The rain may have ended meanwhile (a slow applied now would never be undone),
	# and only the rain's own dimension is slowed.
	if not is_active or not is_instance_valid(new_zombie) or new_zombie.is_flipped:
		return
	if not new_zombie.is_in_group(rain_group) or new_zombie in affected_zombies:
		return
	##print("Will Now Blood Slow ", new_zombie)
	new_zombie.blood_slow()
	affected_zombies.append(new_zombie)
		

func apply_swap_ability()->void:
	rain_group = "Green" if Global.is_on_purple_dimension() else "Purple"
	for zombie in Global.get_all_zombies():
		if is_instance_valid(zombie) and zombie.is_in_group(rain_group) and not zombie.is_flipped:
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
	
	
	
	
	
	
	
	
