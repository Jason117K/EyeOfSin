extends Area2D
#Peashooter.gd

# Adjustbale health, cost, attack speed 
@export var health = 100
@export var attack_speed = 5 
@export var cost = 50

var projectile_scene = preload("res://Scenes/PlantScenes/PeaProjectile.tscn")  # Load the projectile scene
var PlantManager
var canAttack = false   # Whether or not the peashooter can attack 
#f
# Raycast to detect zombies in front of the spider
@onready var attack_ray = $DMG_RayCast2D
# Reference to the animatedSpriteComponent 
@onready var animatedSpriteComponent = $AnimatedSprite2D

#Grab plantmanager, start default anim and connect/start relevant timers 
func _ready():
	animatedSpriteComponent.animation = "redSpiderDefault"
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	$ShootTimer.start()  # Start the shoot timer
	assert($ShootTimer.connect("timeout", Callable(self, "_on_ShootTimer_timeout")) ==OK)
	animatedSpriteComponent.animation = "spawn"

#Handles Collision In Relation To Attacking
func _process(_delta):
	if animatedSpriteComponent.animation == "spawn":
		return
	else:
		if attack_ray.is_colliding():
			var collider = attack_ray.get_collider()
			if collider:
				#print("Collider Name is ", collider.name)
				if collider.is_in_group("Zombie"):
					#print("Can Attack Is True")
					canAttack = true
				else:
					canAttack = false

#Cost getter 
func get_cost():
	return cost
	
					
# Doubles attack speed when receiving a buff 
func receiveBuff(bufferName):
	animatedSpriteComponent.speed_scale = 2


# Function to create and shoot a new projectile
func shoot_projectile():
	$AttackAudioPlayer.play()
	var projectile = projectile_scene.instantiate()
	projectile.position = position + Vector2(32, 0)  # Adjust starting position
	get_parent().add_child(projectile)  # Add the projectile to the game layer

# Handles the peashooter taking damage 
func take_damage(damage):
	#print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		PlantManager.clear_space(self.global_position)
		queue_free()

# Handles either looping attack animation or returning to default 
func _on_AnimatedSprite_animation_finished():
	if animatedSpriteComponent.animation == "spawn":
		
		animatedSpriteComponent.position = Vector2(animatedSpriteComponent.position.x, animatedSpriteComponent.position.y -8.5)
		animatedSpriteComponent.animation = "redSpiderDefault"
		animatedSpriteComponent.play()
		return
	if canAttack:
		print("Should Be Red Spider Attack")
		animatedSpriteComponent.animation = "redSpiderAttack"
	else:
		animatedSpriteComponent.animation = "redSpiderDefault"
	animatedSpriteComponent.play()

#Shoots based on animation 
func _on_AnimatedSprite_frame_changed():
	if(animatedSpriteComponent.animation == "redSpiderAttack"):
		#print(animatedSpriteComponent.frame)
		if(animatedSpriteComponent.frame == 3):
			shoot_projectile()
