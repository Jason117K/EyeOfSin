class_name ProjectileShootComponent extends Node2D

@onready var shootTimer := $"../ShootTimer"
@onready var base_shoot_interval = 3.0
@onready var parent_demon : Demon = get_parent()

@export var attack_speed_mult := 1.0
@export var projectile_spawn_offest :Vector2 = Vector2(32, 0)

var attack_rays = []
var projectile_scene = preload("res://_Entities/Demons/_Crawler/DemonProjectile.tscn")  
var canAttack = false   
var hiveBuffed = false 
var spinalOcculumBuffed = false
var occulumBuffed = false
var wyrmBuffed = false
var projectile 
var animSpriteComp
var node_ready = false
var shoot_positions = []

# Map of animation_name -> which frame triggers the shot
# Might Have to Have Heart Specific in Future 
const SHOOT_FRAMES = {"attack": 3, "attack_Wasp": 3, "attack_Maw": 3, "attack_Crawler": 3, "attack_Occulum": 3, "attack_Wyrm": 3 }

func _ready() -> void:
	animSpriteComp = $"../AnimatedSpriteComponent"
	#node_ready = true 
	print(parent_demon.get_name(), " has an AnimSpriteComp of ", animSpriteComp)
	set_attack_speed(attack_speed_mult)
	set_attack_rays_collision()

	shootTimer.start()  # Start the shoot timer
	shootTimer.connect("timeout", Callable(self, "_on_ShootTimer_timeout"))
	animSpriteComp.frame_changed_signal.connect(_on_sprite_frame_changed)
	
	
func set_attack_rays_collision():
	if parent_demon.is_in_group("Green"):
		for attacking_ray in attack_rays:
			attacking_ray.set_collision_mask_value(1,false)
			attacking_ray.set_collision_mask_value(2,false)
			attacking_ray.set_collision_mask_value(3,true)
	else:
		for attacking_ray in attack_rays:
			attacking_ray.set_collision_mask_value(1,false)
			attacking_ray.set_collision_mask_value(2,true)
			attacking_ray.set_collision_mask_value(3,false)
			
				
func _on_sprite_frame_changed(animation_name: String, frame_index: int):
	if SHOOT_FRAMES.has(animation_name):
		if frame_index == SHOOT_FRAMES[animation_name] and canAttack:
			shoot_projectile()
			
			
func _process(_delta):
	if node_ready && animSpriteComp != null:
		if animSpriteComp.animation == "spawn":
			return
		else:
			if canAttack == false:
				check_attack_rays()
	else:
		pass
		#print("NOOOOOO")


func check_attack_rays():
	canAttack = false
	for ray in attack_rays:
		if ray.is_colliding():
			#print(" Ray Colling ",self )
			for i in range(ray.get_collision_count()):
				var collider = ray.get_collider(i)
				#print(" and collider is ",collider )
				if collider and collider.is_in_group("Zombie"):
				#	print("Valid Zombie Found, Parent is ", parent_demon, " and collider is ",collider )
					if collider.is_in_group("Green") and parent_demon.is_in_group("Green"):
						canAttack = true
					elif collider.is_in_group("Purple") and parent_demon.is_in_group("Purple"):
						canAttack = true
						
						
func shoot_projectile():
	AudioManager.create_2d_audio_at_location(parent_demon.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	if shoot_positions.is_empty():
			projectile = projectile_scene.instantiate()
			projectile.position = parent_demon.position + projectile_spawn_offest 
			parent_demon.get_parent().add_child(projectile)  
			apply_buffs_to_projectile(projectile)
	else:
		for shoot_pos in shoot_positions:
			projectile = projectile_scene.instantiate()
			projectile.position = shoot_pos.global_position
			parent_demon.get_parent().call_deferred("add_child", projectile)
			apply_buffs_to_projectile(projectile)
			
	canAttack = false
	
func apply_buffs_to_projectile(projectile_to_buff):
	pass
	
	
func set_attack_speed(multiplier: float):
	shootTimer.wait_time = base_shoot_interval / multiplier
	animSpriteComp.speed_scale = multiplier  # only for attack animation
	
	
	
	
func receive_buff(newDemon):
	pass
	
	
	
