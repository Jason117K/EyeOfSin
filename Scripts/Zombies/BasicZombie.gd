# BasicZombie.gd
extends Area2D

var health = 6 #7 #10 # Health of the zombie
var speed = 26 #30 # Movement speed, was 34
#var attack_power = 33

var is_attacking


onready var attackComp = $AttackComponent

func ready():
	pass

func _process(delta):
	is_attacking = attackComp.getAttackState()
	if not is_attacking:
		# Only move if not attacking 
		position.x -= speed * delta  # Move left across the screen
	
# Function to handle taking damage
func take_damage(damage):
	health -= damage
	$HitAudioPlayer.play()
	if health <= 0:
		queue_free()  # Remove zombie when health is zero


func _on_JustSpawned_timeout():
	add_to_group("Alive-Enemies")
	var _group_size = get_tree().get_nodes_in_group("Alive-Enemies").size()
	#print("Group Size is : " , group_size)




