extends Zombie
# BackUpDancerZombie.gd

# Handles Any BackUpDancerZombie Specific Logic

func _ready() -> void:
	super()
	attackComp = WretchAttackRefCounted.new(self)
	Global.unlock_zombie("Wretch")

func get_zombie_name() -> String:
	return " WRETCH "

func silence() -> void:
	super()
	attackComp.silence()

func get_special_description() -> String:
	return wretch_special_description
