extends Demon
#Peashooter.gd

# Adjustbale health, cost, attack speed 
@export var health = 100
@export var walnutHealth = 375
#@export var attack_speed = 5 
@export var cost = 75

var projectile_scene = preload("res://Scenes/PlantScenes/PeaProjectile.tscn")  # Load the projectile scene
var spiderling_scene = preload("res://Scenes/PlantScenes/spiderling.tscn")
var PlantManager
var canAttack = false   # Whether or not the peashooter can attack 
var second_shot_timer : Timer
var hiveBuffed = false 
var walnutBuffed = false
var sunBuffed = false
var wyrmBuffed = false
var mawBuffed = false
#f
# Raycast to detect zombies in front of the spider
@onready var attack_ray = $DMG_RayCast2D
# Reference to the animatedSpriteComponent 
#@onready var animSpriteComp = $AnimatedSprite2D
@onready var buffNodes = $BuffNodesComponent
var isBuffed := false 

#Grab plantmanager, start default anim and connect/start relevant timers 
func _ready():
	animSpriteComp = $AnimatedSprite2D
	animSpriteComp.animation = "spawn"
	animSpriteComp.position = Vector2(animSpriteComp.position.x, animSpriteComp.position.y -8.5)
	#animatedSpriteComponent.animation = "redSpiderDefault"
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	$ShootTimer.start()  # Start the shoot timer
	assert($ShootTimer.connect("timeout", Callable(self, "_on_ShootTimer_timeout")) ==OK)
	
	
		# Create a new timer
	second_shot_timer = Timer.new()
	
	# Add it to the scene tree (required for timer to work)
	add_child(second_shot_timer)
	
	# Configure the timer
	second_shot_timer.wait_time = 0.2  # Wait 2 seconds
	second_shot_timer.one_shot = true  # Do not Repeat continuously
	second_shot_timer.autostart = false  # Don't start automatically
	
	# Connect the timeout signal
	second_shot_timer.timeout.connect(second_shoot_projectile)
	

	#animatedSpriteComponent.animation = "spawn"

#Handles Collision In Relation To Attacking
func _process(_delta):
	if animSpriteComp.animation == "spawn":
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
func receiveBuff(newPlant):
	#print("Buff Name is ", newPlant.name)
	super(newPlant)
	var plantName = truncate_string(newPlant.name)
	
	if !isBuffed :
		
		match plantName:
			"Sunflower":
				sunBuffed = true 
			"Peashooter":
				mawBuffed = true 
			"WalnutTree" :
				animSpriteComp.speed_scale = 0.7
				walnutBuffed = true 
				health = walnutHealth
			"EggWorm":
				wyrmBuffed = true 
			"Hive":
				hiveBuffed = true 
				animSpriteComp.speed_scale = 1.3
			"Maw":
				mawBuffed = true


func debuff():
	#print("DDDD DEBUFFFEDDDDSAqw3eg")
	animSpriteComp.speed_scale = 1
	isBuffed = false 


# Function to create and shoot a new projectile
func shoot_projectile():
	print("Shoot Proj From Spider ")
	if hiveBuffed:
		second_shot_timer.start()

	var runtime_seconds = Time.get_ticks_msec() / 1000.0
	#print("Runtime: %.2f seconds" % runtime_seconds)
	#$AttackAudioPlayer.play()
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	var projectile = projectile_scene.instantiate()
	if walnutBuffed:
		projectile.walnutBuff = true 
	if sunBuffed:
		projectile.sunBuff = true 
	if wyrmBuffed:
		projectile.wyrmBuff = true
		
	projectile.position = position + Vector2(32, 0)  # Adjust starting position
	get_parent().add_child(projectile)  # Add the projectile to the game layer
	
func second_shoot_projectile():
	print("Shoot 2nd Proj From Spider ")
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
	if animSpriteComp.animation == "spawn":
		#print("Early Return No AttackZ")
		#animSpriteComp.position = Vector2(animSpriteComp.position.x, animSpriteComp.position.y -8.5)
		animSpriteComp.animation = animSpriteComp.currentAnim
		animSpriteComp.play()
		return
	if canAttack:
		print("Should Be Red Spider AttackZ")
		animSpriteComp.animation = animSpriteComp.currentAttackAnim
		animSpriteComp.play()
	else:
			animSpriteComp.animation = animSpriteComp.currentAnim
			animSpriteComp.play()
		


#Shoots based on animation 
func _on_AnimatedSprite_frame_changed():
	if( animSpriteComp.animation.contains("ttack") ):
		#print("The frame is ", animSpriteComp.frame)
		if(animSpriteComp.frame == 3):
			#print("ABOUT Shoot Proj From Spider ")
			shoot_projectile()
			
func die():
	PlantManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
	
func die_fromClearSpace():
	print("DD YYYING ---------------------------------")
	buffNodes.clearBuffs()
	queue_free()		
	
	
func adjust_position(new_form):
	match new_form:
		"Sunflower":
			pass

			#print("Self pos was ", self.global_position)
			#self.global_position = self.global_position + Vector2(0,-0.75)
			#print("Self pos IS ", self.global_position)

		"Peashooter":
			pass
			
		"Walnut" :
			pass
			
		"Wyrm":
			pass
			
		"Wasp":
			pass
			
		"Maw":
			pass


func _on_spawn_spiderling_timeout() -> void:

	if mawBuffed:
		
		var spiderling = spiderling_scene.instantiate()
		spiderling.position = position + Vector2(8, -4)  # Adjust starting position
		get_parent().add_child(spiderling)  # Add the projectile to the game layer
