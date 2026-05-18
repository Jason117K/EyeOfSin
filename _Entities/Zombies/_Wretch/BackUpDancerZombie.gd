extends Zombie
# BackUpDancerZombie.gd

# Handles Any BackUpDancerZombie Specific Logic 


func get_zombie_name():
	return " WRETCH "

func silence():
	super()
	attackComp.silence()
