extends Area2D



func damage_zombies_in_ultimate_area(ult_damage : int,ult_bleed :int)->void:
	for zombie in get_overlapping_areas():
		if zombie.is_in_group("Zombie"):
			print("zombie shoudl take damage of ", ult_damage)
			zombie.take_damage(false,ult_damage,true)
			zombie.bleed(ult_bleed)
	
