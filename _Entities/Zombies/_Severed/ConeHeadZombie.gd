extends Zombie
# ConeHeadZombie.gd

func get_zombie_name():
	return " SEVERED "


	
func silence():
	super()
	attackComp.silence()

func get_special_description():
	return severed_special_description

func get_zombie_icon()->CompressedTexture2D:
	return Global.severed_icon
