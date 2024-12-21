# BasicZombie.gd
extends Area2D


onready var animatedSprite = $AnimatedSprite
onready var attackComp = $AttackComponent
onready var speedComp = $SpeedComponent

var isSlow = 0
var thisMaterial
var is_attacking
var health = 6 #7 #10 # Health of the zombie

func getSlow():
	return isSlow 
	
func slow():
	print("SLOWING")
	isSlow = isSlow + 100 
	speedComp.slow()

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


func _on_DegradeDebuff_timeout():
	if((isSlow - 20) >= 0):
		isSlow = isSlow - 20
