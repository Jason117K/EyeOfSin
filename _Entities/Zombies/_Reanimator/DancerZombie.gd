extends Zombie
# DancerZombie.gd

# Handles Any DancerZombie Specific Logic 
@onready var summon_comp := $SummonComponent

func ready():
	print("Dancer Self Pos Is :", self.position)

func silence():
	$SilenceFX.show()
	$SilenceFX.play()

func _on_area_entered(area: Area2D) -> void:
	summon_comp.silence()


func get_zombie_name():
	return " REANIMATOR "
