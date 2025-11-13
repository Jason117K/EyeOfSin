extends Zombie
# DancerZombie.gd

# Handles Any DancerZombie Specific Logic 


func ready():
	print("Dancer Self Pos Is :", self.position)


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
