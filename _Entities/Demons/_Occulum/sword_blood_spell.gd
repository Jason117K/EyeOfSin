extends Area2D

@export var blood_damage := 25
var is_maw_parent := false 
@onready var spell_anim := $BloodSpellSprite
var zombies_to_damage = []
var temp_zombie_container = []
signal blood_spell_finished

func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if is_maw_parent:
		pass
	else:
		damage_zombies()

			
func damage_zombies():
	print("Blood Sword Damage Zombies Called at position global : ", global_position , " and position local ", position )
	spell_anim.animation_finished.connect(_on_blood_spell_sprite_animation_finished)
	print("Sword world2d: ", get_world_2d(), " rid: ", get_world_2d().get_rid())
	temp_zombie_container = get_overlapping_areas()
	print("Zombie Temp Container is ", temp_zombie_container)
	for zombie in temp_zombie_container:
		if zombie.is_in_group("Zombie"):
			zombies_to_damage.append(zombie)
	print("Zombies to damage is ", zombies_to_damage)
	for zombie in zombies_to_damage:
		print("Zombie is ", zombie)
		zombie.take_damage(blood_damage)
		if is_maw_parent:
			#TODO Add Armor Stripping 
			pass 		


func _on_blood_spell_sprite_animation_finished() -> void:
	print("Blood Sword Anim Finished")
	if is_maw_parent:
		print("Blood Sword Parent Is MAW ")
		blood_spell_finished.emit()
	else:
		print("Blood Sword Parent Is NOT MAW ")
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		if zombies_to_damage.has(area): 
			pass
		else:
			pass
			#area.take_damage(blood_damage)
