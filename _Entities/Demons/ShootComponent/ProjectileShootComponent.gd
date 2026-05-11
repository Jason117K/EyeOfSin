extends Node2D


@onready var animSpriteComp = $"../AnimatedSpriteComponent"
@onready var shootTimer := $"../ShootTimer"
@onready var attack_ray = $"../DMG_RayCast2D"
@onready var base_shoot_interval = 3.0
@onready var parent_demon : Demon = get_parent()

var projectile_scene = preload("res://_Entities/Demons/_Crawler/PeaProjectile.tscn")  # Load the projectile scene
# Map of animation_name -> which frame triggers the shot
const SHOOT_FRAMES = {"attack": 3, "attack_Wasp": 3, "attack_Maw": 3, "attack_Spider": 3, "attack_Sunflower": 3, "attack_Wyrm": 3 }

var canAttack = false   # Whether or not the peashooter can attack 
var second_shot_timer : Timer
var hiveBuffed = false 
var walnutBuffed = false
var sunBuffed = false
var wyrmBuffed = false


func _ready() -> void:
	
	if parent_demon.is_in_group("Green"):
		print(" I AM GREEN SPIDER I WILL ATTACK GREEN")
		attack_ray.collision_mask = 3
		attack_ray.set_collision_mask_value(1,false)
		attack_ray.set_collision_mask_value(2,false)
		attack_ray.set_collision_mask_value(3,true)
	else:
		print(" I AM PURPLE SPIDER I WILL ATTACK PURPLE")
		attack_ray.set_collision_mask_value(1,false)
		attack_ray.set_collision_mask_value(2,true)
		attack_ray.set_collision_mask_value(3,false)
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
	
	
	animSpriteComp.frame_changed_signal.connect(_on_sprite_frame_changed)
	
func _on_sprite_frame_changed(animation_name: String, frame_index: int):
	if SHOOT_FRAMES.has(animation_name):
		if frame_index == SHOOT_FRAMES[animation_name] and canAttack:
			shoot_projectile()
			
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
						if collider.is_in_group("Green"):
							if parent_demon.is_in_group("Green"):
								print("Is Green, Can Attack")
								canAttack = true
						if collider.is_in_group("Purple"):
							print("Is Purple")
							if parent_demon.is_in_group("Purple"):
								print("Can Attack")
								canAttack = true
						if collider.is_in_group("Green"):
							if parent_demon.is_in_group("Purple"):
								continue
						elif collider.is_in_group("Purple"):
							if parent_demon.is_in_group("Green"):
								continue
					else:
						continue

# Function to create and shoot a new projectile
func shoot_projectile():
	#print("Shoot Proj From Spider ")
	print("Calling Shoooot")
	if hiveBuffed:
		second_shot_timer.start()
	print("Still Neeeeds Shoooot")
	var runtime_seconds = Time.get_ticks_msec() / 1000.0
	#print("Runtime: %.2f seconds" % runtime_seconds)
	#$AttackAudioPlayer.play()
	AudioManager.create_2d_audio_at_location(parent_demon.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	var projectile = projectile_scene.instantiate()
	if walnutBuffed:
		projectile.walnutBuff = true 
	if sunBuffed:
		projectile.sunBuff = true 
	if wyrmBuffed:
		projectile.wyrmBuff = true
		
	projectile.position = parent_demon.position + Vector2(32, 0)  # Adjust starting position
	parent_demon.get_parent().add_child(projectile)  # Add the projectile to the game layer
	if self.is_in_group("Green"):
		pass
		#print("Is Green, Can Attack Is Now False")
	print("Shoot Proj From Spider ")
	canAttack = false
	
func second_shoot_projectile():
	print("Shoot 2nd Proj From Spider ")
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	var projectile = projectile_scene.instantiate()
	projectile.position = parent_demon.position + Vector2(32, 0)  # Adjust starting position
	parent_demon.get_parent().add_child(projectile)  # Add the projectile to the game layer

func set_attack_speed(multiplier: float):
	shootTimer.wait_time = base_shoot_interval / multiplier
	animSpriteComp.speed_scale = multiplier  # only for attack animation
	
	
	
	
	
	
	
