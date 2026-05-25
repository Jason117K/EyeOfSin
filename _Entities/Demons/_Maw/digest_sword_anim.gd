extends Node2D

@onready var sword1 := $SwordBloodSpell
@onready var sword2 := $SwordBloodSpell2
@onready var sword3 := $SwordBloodSpell3
@onready var lightning1 := $LightningCrackle
@onready var lightning2 := $LightningCrackle2
@onready var lightning3 := $LightningCrackle3

@onready var all_swords := [sword1,sword2,sword3]

func _ready() -> void:
	pass
	
func set_maw_parent() -> void:
	print("SETTING Blood Sword Parent As MAW")
	for blood_sword:Node in all_swords:
		blood_sword.is_maw_parent = true
		blood_sword.blood_spell_finished.connect(end_spell)

func setup_collision_and_damage_zombies() -> void:
	print("Setting Blood Sword Collision")
	for sword:Node in all_swords:
		if self.is_in_group("Green"):
			sword.set_collision_mask_value(1,false)
			sword.set_collision_mask_value(2,false)
			sword.set_collision_mask_value(3,false)
			sword.set_collision_mask_value(4,false)
			sword.set_collision_mask_value(5,true)
		else:
			sword.set_collision_mask_value(1,false)
			sword.set_collision_mask_value(2,false)
			sword.set_collision_mask_value(3,false)
			sword.set_collision_mask_value(4,true)
	await get_tree().physics_frame
	await get_tree().physics_frame
			
	for blood_sword:Node in all_swords:
		blood_sword.is_maw_parent = true 
		blood_sword.blood_spell_finished.connect(end_spell)
		print("Calling Blood Sword Damage Zombies")
		blood_sword.damage_zombies()
		pass
		
	
func end_spell() -> void:
	print("Should Free BLOOD Spell Sword Digest ")
	queue_free()
