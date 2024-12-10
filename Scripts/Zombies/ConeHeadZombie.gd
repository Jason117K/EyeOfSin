extends Area2D
#ConeHeadZombie.gd

var health = 17 #22 #28 # Health of the zombie
var speed = 29 #30 #38  # Movement speed

var is_attacking = false # Whether or not we attacking
var target_plant = null  # Holds reference to the plant being attacked

var attack_power = 33

onready var animatedSprite = $AnimatedSprite
onready var attack_ray = $DMGRayCast2D

var thisMaterial

func ready():
	add_to_group("Alive-Enemies")

func _process(delta):
	if not is_attacking:
		$AnimatedSprite.play("Walk")
		# Only move if not attacking 
		position.x -= speed * delta  # Move left across the screen
		# Check if there is a plant to attack
		
		if attack_ray.is_colliding():
			var collider = attack_ray.get_collider()
			if collider:
				if collider.is_in_group("Plants"):
					attack_plant(collider)
					
func attack_plant(collider):
	is_attacking = true
	target_plant = collider
	$AnimatedSprite.play("Attack")
	$AttackAudioPlayer.play()
	$AttackTimer.start()
	pass


# Stops the attack and resumes movement
func stop_attack():
	#print("Stopping Attack")
	is_attacking = false
	target_plant = null
	


func _on_AttackTimer_timeout():
	if(is_instance_valid(target_plant)):
		if(target_plant.health >= 0):
			target_plant.take_damage(attack_power)
		else:
			stop_attack()
	else:
		stop_attack()
	

# Function to handle taking damage
func take_damage(damage):
	if(thisMaterial):
		thisMaterial.set_shader_param("target_color", Color.black)
		thisMaterial.set_shader_param("replace_color", Color.white)
		thisMaterial.set_shader_param("tolerance", 1)
		$ResetColor.start()
	health -= damage
	$HitAudioPlayer.play()
	if health <= 0:
		queue_free()  # Remove zombie when health is zero


func _on_JustSpawned_timeout():
	# Create a unique material instance for this zombie
	thisMaterial = animatedSprite.material.duplicate()
	animatedSprite.material = thisMaterial
	# Set initial shader parameters
	if thisMaterial:
		thisMaterial.set_shader_param("target_color", Color.black)
		thisMaterial.set_shader_param("replace_color", Color.black)
		thisMaterial.set_shader_param("tolerance", 0.1)
	add_to_group("Alive-Enemies")
	var _group_size = get_tree().get_nodes_in_group("Alive-Enemies").size()
	#print("Group Size is : " , group_size)


func _on_AnimatedSprite_animation_finished():
	if("Attack" in $AnimatedSprite.animation):
		$AttackAudioPlayer.play()



func _on_ResetColor_timeout():
	thisMaterial.set_shader_param("target_color", Color.black)
	thisMaterial.set_shader_param("replace_color", Color.black)
	thisMaterial.set_shader_param("tolerance", 0.1)

