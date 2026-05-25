extends Zombie
# FootBallZombie.gd


func get_zombie_name() -> String:
	return " FLESHEATER "

func silence() -> void:
	super()
	attackComp.silence()


func get_special_description() -> String:
	return flesheater_special_description

func get_zombie_icon() -> CompressedTexture2D:
	return Global.flesheater_icon
