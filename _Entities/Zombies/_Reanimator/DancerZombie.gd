extends Zombie
# DancerZombie.gd

# Handles Any DancerZombie Specific Logic
@onready var summon_comp := $SummonComponent

func silence() -> void:
	super()
	summon_comp.silence()
	silence_field.position = silence_field_position


func get_zombie_name() -> String:
	return " REANIMATOR "

func get_special_description() -> String:
	return reanimator_special_description

func get_zombie_icon() -> CompressedTexture2D:
	return Global.reanimator_icon
