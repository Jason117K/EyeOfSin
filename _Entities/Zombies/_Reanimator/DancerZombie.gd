extends Zombie
# DancerZombie.gd

# Handles Any DancerZombie Specific Logic 
@onready var summon_comp := $SummonComponent

func silence():
	super()
	summon_comp.silence()
	silence_field.position = silence_field_position


func get_zombie_name():
	return " REANIMATOR "
