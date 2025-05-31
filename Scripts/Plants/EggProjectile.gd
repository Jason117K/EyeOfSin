extends Area2D
#EggProjectile.gd


@export var speed = 300  # Speed of the projectile
@export var damage = 20 #2   # Damage dealt to zombies
var canMove := false 

func _process(delta):
	if canMove:
		position.x += speed * delta  # Move the projectile to the right

	# Remove the projectile if it goes off-screen
	if position.x > get_viewport_rect().size.x:
		queue_free()  # Remove projectile if off-screen


# Handles projectile collison and damage application 
func _on_PeaProjectile_area_entered(area):
	if area.is_in_group("Zombie"):
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		compManager.take_damage(damage)  # Call take_damage() on the zombie
		#queue_free()  # Remove the projectile # Replace with function body.


func _on_timer_timeout() -> void:
	canMove = true 
