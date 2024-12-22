extends Area2D
#BucketHeadZombie.gd

var speed = 8 # Movement speed, was 34
var attack_power = 33
var isSlow = 0


# Raycast to detect plants in front of the zombie
onready var attack_ray = $DMGRayCast2D
onready var healthComp = $HealthComponent
onready var speedComp = $SpeedComponent

func getSlow():
	return isSlow 
	
func slow():
	print("SLOWING")
	isSlow = isSlow + 100 
	speedComp.slow()

func getHealthComponent():
	return healthComp

func _on_JustSpawned_timeout():
	add_to_group("Alive-Enemies")
	var _group_size = get_tree().get_nodes_in_group("Alive-Enemies").size()
	#print("Group Size is : " , group_size)


func _on_AnimatedSprite_animation_finished():
	if("Attack" in $AnimatedSprite.animation):
		$AttackAudioPlayer.play()
	pass # Replace with function body.
