extends Zombie
# ConeHeadZombie.gd

func _ready()->void:
	super()
	if Global.gameIsStarted && self.is_demo == false:
		Global.unlock_zombie("Severed")

func get_zombie_name() -> String:
	return " SEVERED "


func silence() -> void:
	super()
	attackComp.silence()

func get_special_description() -> String:
	return severed_special_description

func get_zombie_icon() -> CompressedTexture2D:
	return Global.severed_icon
