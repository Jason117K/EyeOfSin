extends Node2D

onready var hitAudioPlayer = $"../HitAudioPlayer"
onready var zombie = get_parent()
export var health = 76 #25 # Health of the zombie
export var healthRegen = 0.0

var injured = false
var halfHealth = health/2

var explode = false

var bomb_scene = preload("res://Scenes/PlantScenes/Bomb.tscn")

# Declare the death signal
signal enemy_died(enemy)

func getInjured():
	return injured
	
func ready():
	#health = zombie.get_health() 
	pass
	
# Function to handle taking damage
func take_damage(damage):
	if damage > 99:
		print("HIT BY DOMB")
	health -= damage
	hitAudioPlayer.play()
	if health <= 0:
		print("EXPLODE IS ", explode)
		if(explode):
			var bomb = bomb_scene.instance()
			bomb.position = zombie.position + Vector2(0, 0)  # Adjust starting position
			print(((get_parent().get_parent()).name), "is parent")
			get_parent().get_parent().add_child(bomb)  
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

func willExplode():
	explode = true
