extends Zombie
# TankZombie.gd

# Seconds between minion summons, read by SummonComponent in its _ready
@export var summon_wait_time := 5

@onready var summon_comp := $SummonComponent

func _ready()->void:
	super()
	summon_comp.attackComp = attackComp
	if Global.gameIsStarted && self.is_demo == false:
		Global.unlock_zombie("Tank")

func get_zombie_name() -> String:
	return " TANK "


func silence() -> void:
	super()
	summon_comp.silence()
	attackComp.silence()

func get_special_description() -> String:
	return tank_special_description

func get_zombie_icon() -> CompressedTexture2D:
	return Global.tank_icon

	
	
