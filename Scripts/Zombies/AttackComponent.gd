extends Node2D
# AttackComp.gd 
# Handles Zombie attacking Plant Behavior 

export var attack_power = 33 # Adjustable reference to attack damage
var is_attacking = false  # Whether or not we attacking
var target_plant = null  # Holds reference to the plant being attacked
var canSpecial = true # Determines whether or not a special move can be performed

onready var attack_ray = $"../DMGRayCast2D" # Raycast to detect plants in front of the zombie
onready var zombieSprite = $"../AnimatedSprite" # Reference to sprite comp 
onready var attack_timer = $"../AttackTimer" # Adjustable timer to control attack speed
onready var attack_audio_player = $"../AttackAudioPlayer" # Reference to attack audio 
onready var parent = get_parent() # Parent Zombie Attacking 

# Attack State Getter 
func getAttackState():
	return is_attacking

# Sets is_attacking to true and plays the audio will also starting the attack cooldown timer
func attack_plant(collider):
	is_attacking = true
	target_plant = collider
	#print("TName is ", target_plant.name)
	
	zombieSprite.play("Attack")
	attack_audio_player.play()
	
	attack_timer.start()

# Damages the target plant and decides whether or not to keep attacking
func _on_AttackTimer_timeout():
	#print("Basic Zombie Attack Timer Timeout")
	if(is_instance_valid(target_plant)):
		print(target_plant.name)
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

func _process(_delta):
	if not is_attacking:
		if attack_ray.is_colliding():
			var collider = attack_ray.get_collider()
			#print("Its collding with ", collider.name )
			if collider:
				if collider.is_in_group("Plants"):
					#print(collider.name , " is in group plants")
					if(parent.name == "PoleVaultZombie"):
							if canSpecial:
								#print("Pole Vault Special Mo")
								parent.special_move()
								canSpecial = false
								pass
							else:
								if parent.getBusy() == false:
									pass
								else:
									attack_plant(collider)
					else:
						attack_plant(collider)
