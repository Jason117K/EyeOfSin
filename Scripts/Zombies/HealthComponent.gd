extends Node2D

onready var hitAudioPlayer = $"../HitAudioPlayer"
onready var zombie = get_parent()
export var health = 25 # Health of the zombie



func ready():
	#health = zombie.get_health() 
	pass
	
# Function to handle taking damage
func take_damage(damage):
	health -= damage
	hitAudioPlayer.play()
	if health <= 0:
		zombie.queue_free()  # Remove zombie when health is zero
