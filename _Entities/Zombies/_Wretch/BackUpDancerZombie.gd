extends Zombie
# BackUpDancerZombie.gd

# Handles Any BackUpDancerZombie Specific Logic 


func get_zombie_name():
	return " WRETCH "

func silence():
	super()
	attackComp.silence()

func get_special_description():
	return wretch_special_description
