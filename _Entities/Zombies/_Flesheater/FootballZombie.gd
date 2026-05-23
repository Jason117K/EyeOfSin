extends Zombie
# FootBallZombie.gd



func get_zombie_name():
	return " FLESHEATER "

func silence():
	super()
	attackComp.silence()


func get_special_description():
	return flesheater_special_description

func get_zombie_icon()->CompressedTexture2D:
	return Global.flesheater_icon
