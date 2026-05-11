extends Area2D
#PeaProjectile.gd


@export var speed = 300  # Speed of the projectile
@export var damage = 500 #2   # Damage dealt to plant


func _process(delta):
	position.x -= speed * delta  # Move the projectile to the right

	# Remove the projectile if it goes off-screen
	if global_position.x < get_viewport_rect().position.x:
		print("REMOVE PROJECTILE FOR ZOMBIE")
		queue_free()  # Remove projectile if off-screen


# Handles projectile collison and damage application 
func _on_PeaProjectile_area_entered(area):
	print("PLANT HIT: ", area)
	var plant = area

	if plant.is_in_group("Plants"):
		print("IS IN GROUP")
		if plant.get_parent().get_parent() != self.get_parent().get_parent():
			return
		if(plant.get_health() >= 0):
			plant.take_damage(damage)
			queue_free()  # Remove the projectile # Replace with function body.
