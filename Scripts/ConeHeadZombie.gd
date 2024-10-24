extends Area2D

var health = 28 # Health of the zombie
var speed = 38  # Movement speed

func _process(delta):
	position.x -= speed * delta  # Move left across the screen

# Function to handle taking damage
func take_damage(damage):
	health -= damage
	if health <= 0:
		queue_free()  # Remove zombie when health is zero