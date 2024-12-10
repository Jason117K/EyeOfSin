# BasicZombie.gd
extends Area2D

var health = 6 #7 #10 # Health of the zombie
var speed = 26 #30 # Movement speed, was 34
#var attack_power = 33

var is_attacking

onready var animatedSprite = $AnimatedSprite

onready var attackComp = $AttackComponent



var thisMaterial

func ready():
	pass

func _process(delta):
	is_attacking = attackComp.getAttackState()
	if not is_attacking:
		# Only move if not attacking 
		position.x -= speed * delta  # Move left across the screen
	
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
	var group_size = get_tree().get_nodes_in_group("Alive-Enemies").size()






func _on_ResetColor_timeout():
	thisMaterial.set_shader_param("target_color", Color.black)
	thisMaterial.set_shader_param("replace_color", Color.black)
	thisMaterial.set_shader_param("tolerance", 0.1)
