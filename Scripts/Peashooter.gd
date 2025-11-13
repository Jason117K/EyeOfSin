extends Area2D
#Peashooter.gd

# Adjustbale health, cost, attack speed 
@export var health = 100
#@export var attack_speed = 5 
@export var cost = 75

var projectile_scene = preload("res://Scenes/PlantScenes/PeaProjectile.tscn")  # Load the projectile scene
var PlantManager
var canAttack = false   # Whether or not the peashooter can attack 
#f
# Raycast to detect zombies in front of the spider
@onready var attack_ray = $DMG_RayCast2D
# Reference to the animatedSpriteComponent 
@onready var animatedSpriteComponent = $AnimatedSprite2D
@onready var buffNodes = $BuffNodesComponent
var isBuffed := false 

#Grab plantmanager, start default anim and connect/start relevant timers 
func _ready():
	animatedSpriteComponent.animation = "spawn"
	#animatedSpriteComponent.animation = "redSpiderDefault"
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	$ShootTimer.start()  # Start the shoot timer
	assert($ShootTimer.connect("timeout", Callable(self, "_on_ShootTimer_timeout")) ==OK)
	#animatedSpriteComponent.animation = "spawn"

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
					if collider.get_parent().get_parent() != self.get_parent().get_parent():
						return
					canAttack = true
					#print("Can AttackZ Is True",canAttack)
					
				else:
					canAttack = false

#Cost getter 
func get_cost():
	return cost
	
					
# Doubles attack speed when receiving a buff 
func receiveBuff(bufferName):
	animatedSpriteComponent.make_buff_glow()
	if not isBuffed:
		animatedSpriteComponent.speed_scale = 2
		isBuffed = true 

func debuff():
	print("DDDD DEBUFFFEDDDDSAqw3eg")
	animatedSpriteComponent.speed_scale = 1
	isBuffed = false 


# Function to create and shoot a new projectile
func shoot_projectile():
	var runtime_seconds = Time.get_ticks_msec() / 1000.0
	#print("Runtime: %.2f seconds" % runtime_seconds)
	#$AttackAudioPlayer.play()
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	var projectile = projectile_scene.instantiate()
	projectile.position = position + Vector2(32, 0)  # Adjust starting position
	get_parent().add_child(projectile)  # Add the projectile to the game layer

# Handles the peashooter taking damage 
func take_damage(damage):
	#print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		die()

# Handles either looping attack animation or returning to default 
func _on_AnimatedSprite_animation_finished():
	if animatedSpriteComponent.animation == "spawn":
		print("Early Return No AttackZ")
		animatedSpriteComponent.position = Vector2(animatedSpriteComponent.position.x, animatedSpriteComponent.position.y -8.5)
		animatedSpriteComponent.animation = "redSpiderDefault"
		animatedSpriteComponent.play()
		return
	if canAttack:
		print("Should Be Red Spider AttackZ")
		animatedSpriteComponent.animation = "redSpiderAttack"
	else:
		#print("Can AttackZ is ", canAttack)
		animatedSpriteComponent.animation = "redSpiderDefault"
	animatedSpriteComponent.play()

#Shoots based on animation 
func _on_AnimatedSprite_frame_changed():
	if(animatedSpriteComponent.animation == "redSpiderAttack"):
		#print(animatedSpriteComponent.frame)
		if(animatedSpriteComponent.frame == 3):
			
			shoot_projectile()
			
func die():
	PlantManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
	
func die_fromClearSpace():
	print("DD YYYING ---------------------------------")
	buffNodes.clearBuffs()
	queue_free()		
	
