extends Zombie
# TickerZombie.gd

# Handles Any Ticker Zombie Specific Logic 
@onready var aoe = $AOEHit/HitBoxComponent

func get_zombie_name():
	return " ERUPTER "


func silence():
	super()
	aoe.attack_power = 0
	silence_field.position = silence_field_position

func _ready() -> void:
	if self.is_in_group("Green"):
		aoe.set_collision_mask_value(1,false)
		aoe.set_collision_mask_value(2,false)
		aoe.set_collision_mask_value(3,true)
	else:
		aoe.set_collision_mask_value(1,false)
		aoe.set_collision_mask_value(2,true)
		aoe.set_collision_mask_value(3,false)
