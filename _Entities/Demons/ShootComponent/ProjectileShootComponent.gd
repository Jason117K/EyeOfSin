extends Node2D


@onready var animSpriteComp = get_parent().animSpriteComp
@onready var shootTimer := $"../ShootTimer"
@onready var attack_ray = $DMG_RayCast2D

var projectile_scene = preload("res://_Entities/Demons/_Crawler/PeaProjectile.tscn")  # Load the projectile scene


var canAttack = false   # Whether or not the peashooter can attack 
var second_shot_timer : Timer
var hiveBuffed = false 
var walnutBuffed = false
var sunBuffed = false
var wyrmBuffed = false


func _ready() -> void:
	if self.get_parent().is_in_group("Green"):
		#print(" I AM GREEN SPIDER I WILL ATTACK GREEN")
		$DMG_RayCast2D.collision_mask = 3
		$DMG_RayCast2D.set_collision_mask_value(1,false)
		$DMG_RayCast2D.set_collision_mask_value(2,false)
		$DMG_RayCast2D.set_collision_mask_value(3,true)
	else:
		$DMG_RayCast2D.set_collision_mask_value(1,false)
		$DMG_RayCast2D.set_collision_mask_value(2,true)
		$DMG_RayCast2D.set_collision_mask_value(3,false)
	shootTimer.start()  # Start the shoot timer
	#assert($ShootTimer.connect("timeout", Callable(self, "_on_ShootTimer_timeout")) ==OK)
	shootTimer.connect("timeout", Callable(self, "_on_ShootTimer_timeout"))
	
	
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
	
func _process(_delta):
	if animSpriteComp.animation == "spawn":
		return
	else:
		if canAttack == false:
			
			if attack_ray.is_colliding():
				var collision_count = attack_ray.get_collision_count()
				for i in range(collision_count):
					var collider = attack_ray.get_collider(i)
					if collider and collider.is_in_group("Zombie"):
						i#f self.is_in_group("Green"):
						#print("Collider Name is XXX to be attacked", collider.name)
							
						#print("Collider Name is XXX", collider.name)
						#if collider.get_parent().get_parent() != self.get_parent().get_parent(): #Dimension Check
						#	print(" XXX collider.get_parent().get_parent() is ",  collider.get_parent().get_parent() , " and self.get_parent().get_parent() is ", self.get_parent().get_parent())
						#	return
						if collider.is_in_group("Green"):
							if self.is_in_group("Green"):
								#print("Is Green, Can Attack")
								canAttack = true
						if collider.is_in_group("Purple"):
						#	print("Is Purple")
							if self.is_in_group("Purple"):
							#	print("Can Attack")
								canAttack = true
						if collider.is_in_group("Green"):
							if self.is_in_group("Purple"):
								continue
						elif collider.is_in_group("Purple"):
							if self.is_in_group("Green"):
								continue
					else:
						continue

# Function to create and shoot a new projectile
func shoot_projectile():
	#print("Shoot Proj From Spider ")
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
	if self.is_in_group("Green"):
		pass
		#print("Is Green, Can Attack Is Now False")

	canAttack = false
	
func second_shoot_projectile():
	#print("Shoot 2nd Proj From Spider ")
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	var projectile = projectile_scene.instantiate()
	projectile.position = position + Vector2(32, 0)  # Adjust starting position
	get_parent().add_child(projectile)  # Add the projectile to the game layer
