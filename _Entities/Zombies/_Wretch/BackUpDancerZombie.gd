extends Zombie
# BackUpDancerZombie.gd

# Handles Any BackUpDancerZombie Specific Logic


func get_zombie_name() -> String:
	return " WRETCH "

func silence() -> void:
	super()
	attackComp.silence()

func get_special_description() -> String:
	return wretch_special_description
