extends Area2D

@export var blood_damage := 25

var zombies_to_damage = []
var temp_zombie_container = []

func _ready() -> void:
	await get_tree().physics_frame
	temp_zombie_container = get_overlapping_areas()
	for zombie in temp_zombie_container:
		if zombie.is_in_group("Zombie"):
			zombies_to_damage.append(zombie)
	print("Zombies to damage is ", zombies_to_damage)
	for zombie in zombies_to_damage:
		print("Zombie is ", zombie)
		zombie.getCompManager().take_damage(blood_damage)


func _on_blood_spell_sprite_animation_finished() -> void:
	pass
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		if zombies_to_damage.has(area): 
			pass
		else:
			pass
			#area.getCompManager().take_damage(blood_damage)
