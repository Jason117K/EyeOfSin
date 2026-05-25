extends Zombie
# ConeHeadZombie.gd

func get_zombie_name() -> String:
	return " SEVERED "


func silence() -> void:
	super()
	attackComp.silence()

func get_special_description() -> String:
	return severed_special_description

func get_zombie_icon() -> CompressedTexture2D:
	return Global.severed_icon
