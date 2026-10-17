extends Zombie
# MinionZombie.gd


func _ready() -> void:
	super()
	if Global.gameIsStarted && self.is_demo == false:
		Global.unlock_zombie("Minion")


func get_zombie_name() -> String:
	return " URCHIN "

func silence() -> void:
	super()
	attackComp.silence()


func get_special_description() -> String:
	return minion_special_description


func get_zombie_icon() -> CompressedTexture2D:
	return Global.minion_icon
