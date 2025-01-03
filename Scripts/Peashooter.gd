extends Area2D

var health = 100
var attack_speed = 5 #1.5  # Seconds between shots
var projectile_scene = preload("res://Scenes/PlantScenes/PeaProjectile.tscn")  # Load the projectile scene
var PlantManager
var canAttack = false

export var cost = 50

# Raycast to detect zombies in front of the spider
onready var attack_ray = $DMG_RayCast2D
onready var animatedSpriteComponent = $AnimatedSprite

func _ready():
	animatedSpriteComponent.animation = "redSpiderDefault"
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	$ShootTimer.start()  # Start the shoot timer
	assert($ShootTimer.connect("timeout", self, "_on_ShootTimer_timeout") ==OK)

#Handles Collision In Relation To Attacking
func _process(_delta):
	if attack_ray.is_colliding():
		var collider = attack_ray.get_collider()
		if collider:
			#print(collider.name)
			if collider.is_in_group("Zombie"):
				canAttack = true
			else:
				canAttack = false
				
func receiveBuff(bufferName):
	#attack_speed = 10
	animatedSpriteComponent.speed_scale = 2

	

# Called every time the shoot timer reaches timeout
func _on_ShootTimer_timeout():
	if canAttack:
		pass
		#shoot_projectile()

# Function to create and shoot a new projectile
func shoot_projectile():
	$AttackAudioPlayer.play()
	var projectile = projectile_scene.instance()
	projectile.position = position + Vector2(32, 0)  # Adjust starting position
	get_parent().add_child(projectile)  # Add the projectile to the game layer

func take_damage(damage):
	#print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		PlantManager.clear_space(self.global_position)
		queue_free()

func get_cost():
	return cost


func _on_AnimatedSprite_animation_finished():
	if canAttack:
		animatedSpriteComponent.animation = "redSpiderAttack"
	else:
		animatedSpriteComponent.animation = "redSpiderDefault"



func _on_AnimatedSprite_frame_changed():
	if(animatedSpriteComponent.animation == "redSpiderAttack"):
		#print(animatedSpriteComponent.frame)
		if(animatedSpriteComponent.frame == 3):
			shoot_projectile()







