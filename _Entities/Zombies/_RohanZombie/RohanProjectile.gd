extends Area2D
#PeaProjectile.gd


@export var speed := 300  # Speed of the projectile
@export var damage := 500 #2   # Damage dealt to demon


func _process(delta: float) -> void:
	position.x -= speed * delta  # Move the projectile to the right

	# Remove the projectile if it goes off-screen
	if global_position.x < get_viewport_rect().position.x:
		queue_free()


# Handles projectile collison and damage application
func _on_PeaProjectile_area_entered(area) -> void:
	var demon := area

	if demon.is_in_group("Demons"):
		if demon.get_parent().get_parent() != self.get_parent().get_parent():
			return
		if(demon.get_health() >= 0):
			demon.take_damage(damage)
			queue_free()  # Remove the projectile # Replace with function body.
