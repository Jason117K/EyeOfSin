extends Zombie
# BucketHeadZombie.gd

# Handles Any BucketHeadZombie Specific Logic 

func _ready() -> void:
	print("MawPREY Area2D: ", name)
	print("MawPREY Collision Layer: ", collision_layer)
	print("MawPREY Collision Mask: ", collision_mask)
	print("MawPREY Monitoring: ", monitoring)
	print("MawPREY Monitorable: ", monitorable)
