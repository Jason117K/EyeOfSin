extends Node2D

onready var hitAudioPlayer = $"../HitAudioPlayer"
onready var zombie = get_parent()
export var health = 76 #25 # Health of the zombie
export var healthRegen = 0.0

var injured = false
var halfHealth = health/2

# Declare the death signal
signal enemy_died(enemy)

func getInjured():
	return injured
	
func ready():
	#health = zombie.get_health() 
	pass
	
# Function to handle taking damage
func take_damage(damage):
	health -= damage
	hitAudioPlayer.play()
	if health <= 0:
		emit_signal("enemy_died", self)
		zombie.die()
		#zombie.queue_free()  # Remove zombie when health is zero

func _process(_delta):
	health = health + healthRegen
	if health < halfHealth:
		injured = true
	else:
		injured = false

func resetHealth():
	health = (halfHealth * 2)
