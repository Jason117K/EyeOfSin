extends Node2D

# Whether or not we attacking
var is_attacking = false 
# Raycast to detect plants in front of the zombie
onready var attack_ray = $"../DMG_RayCast2D"
onready var zombieSprite = $"../AnimatedSprite"

var target_plant = null  # Holds reference to the plant being attacked
var attack_power = 33


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func getAttackState():
	return is_attacking

func _process(_delta):
	if not is_attacking:
		if attack_ray.is_colliding():

			var collider = attack_ray.get_collider()
			#print("Its collding with ", collider.name )
			if collider:
				if collider.is_in_group("Plants"):
					attack_plant(collider)


func attack_plant(collider):
	is_attacking = true
	target_plant = collider
	zombieSprite.play("Attack")
	$"../AttackAudioPlayer".play()
	$"../AttackTimer".start()

func _on_AttackTimer_timeout():
	#print("Basic Zombie Attack Timer Timeout")
	if(is_instance_valid(target_plant)):
		if(target_plant.health >= 0):
			target_plant.take_damage(attack_power)
		else:
			stop_attack()
	else:
		stop_attack()

# Stops the attack and resumes movement
func stop_attack():
	#print("Stopping Attack")
	is_attacking = false
	target_plant = null