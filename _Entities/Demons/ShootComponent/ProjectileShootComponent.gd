class_name ProjectileShootComponent extends Node2D

#@onready var shootTimer := $"../ShootTimer"
@onready var base_shoot_interval = 3.0
@onready var parent_demon : Demon = get_parent()
var damage := 60
var attack_speed_mult := 1.0
var projectile_spawn_offest :Vector2 = Vector2(32, 0)

var attack_rays = []
var projectile_scene = preload("res://_Entities/Demons/_Crawler/DemonProjectile.tscn")  
var canAttack = false   

var hiveBuffed = false 
var spinalOcculumBuffed = false
var occulumBuffed = false
var wyrmBuffed = false
var crawlerBuffed := false
var mawBuffed := false 

var projectile 
var animSpriteComp
var node_ready = false
var shoot_positions = []

# Map of animation_name -> which frame triggers the shot
# Might Have to Have Heart Specific in Future 
const SHOOT_FRAMES = {"attack": 3, "attack_Hive": 3, "attack_Maw": 3, "attack_Crawler": 3, "attack_Occulum": 3, "attack_Wyrm": 3, "attack_SpinalOcculum": 3 }


func _ready() -> void:
	animSpriteComp = $"../AnimatedSpriteComponent"
	#node_ready = true 
	print(parent_demon.get_name(), " has an AnimSpriteComp of ", animSpriteComp)
	set_attack_speed(attack_speed_mult)
	set_attack_rays_collision()

	#shootTimer.start()  # Start the shoot timer
	#shootTimer.connect("timeout", Callable(self, "_on_ShootTimer_timeout"))
	animSpriteComp.frame_changed_signal.connect(_on_sprite_frame_changed)
	
	
func set_attack_rays_collision():
	if parent_demon.is_in_group("Green"):
		for attacking_ray in attack_rays:
			attacking_ray.max_results = 30
			attacking_ray.set_collision_mask_value(1,false)
			attacking_ray.set_collision_mask_value(2,false)
			attacking_ray.set_collision_mask_value(3,false)
			attacking_ray.set_collision_mask_value(4,false)
			attacking_ray.set_collision_mask_value(5,true)
	else:
		for attacking_ray in attack_rays:
			attacking_ray.max_results = 30
			attacking_ray.set_collision_mask_value(1,false)
			attacking_ray.set_collision_mask_value(2,false)
			attacking_ray.set_collision_mask_value(3,false)
			attacking_ray.set_collision_mask_value(4,true)


		
		
					
				
func _on_sprite_frame_changed(animation_name: String, frame_index: int):
	if SHOOT_FRAMES.has(animation_name):
		if frame_index == SHOOT_FRAMES[animation_name] and canAttack:
			shoot_projectile()
			
			
func _process(_delta):
	if node_ready && animSpriteComp != null:
		if animSpriteComp.animation == "spawn":
			#print("Early")
			return
		else:
			if canAttack == false:
				#print("Check Attack Rays")
				check_attack_rays()
	else:
		pass
		#print("NOOOOOO")


func check_attack_rays():
	canAttack = false
	for ray in attack_rays:
		#print("Checking Ray ", ray)
		if ray.is_colliding():
			#print(" Ray Colling ",self )
			for i in range(ray.get_collision_count()):
				var collider = ray.get_collider(i)
				#print("Collider [", i, "]: ", collider, " | is_null: ", collider == null)
				if collider == null:
					continue  # guard against freed/invalid colliders
				if collider and collider.is_in_group("Zombie"):
					print("Valid Zombie Found, Parent is ", parent_demon, " and collider is ",collider )
					if collider.is_in_group("Green") and parent_demon.is_in_group("Green"):
						#print("Green Can Attack True")
						canAttack = true
						return
					elif collider.is_in_group("Purple") and parent_demon.is_in_group("Purple"):
						canAttack = true
						print("Purple Can Attack True")
						return 
				#	if parent_demon.is_in_group()
						
						
func shoot_projectile():
	AudioManager.create_2d_audio_at_location(parent_demon.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	if shoot_positions.is_empty():
			print("SHOOTING HERE")
			projectile = projectile_scene.instantiate()
			projectile.global_position = parent_demon.position + projectile_spawn_offest 
			projectile.damage = damage
			apply_buffs_to_projectile(projectile)
			if get_parent().is_in_group("Green"):
				projectile.add_to_group("Green")
			else:
				projectile.add_to_group("Purple")
			parent_demon.get_parent().add_child(projectile)  

	else:
		print("NAH SHOOTING HERE")
		for shoot_pos in shoot_positions:
			projectile = projectile_scene.instantiate()
			projectile.damage = damage
			apply_buffs_to_projectile(projectile)
			if get_parent().is_in_group("Green"):
				projectile.add_to_group("Green")
			else:
				projectile.add_to_group("Purple")
			parent_demon.get_parent().call_deferred("add_child", projectile)
			projectile.set_deferred("global_position", shoot_pos.global_position)
				
			
	canAttack = false
	
func apply_buffs_to_projectile(projectile_to_buff):
	pass
	
	
func set_attack_speed(multiplier: float):
	#shootTimer.wait_time = base_shoot_interval / multiplier
	animSpriteComp.speed_scale = multiplier  # only for attack animation
	
func get_damage():
	return damage 
	
	
func receive_buff(newDemon):
	match newDemon:
		"Occulum":
			occulumBuffed = true
		"Crawler":
			crawlerBuffed = true 
		"SpinalOcculum" :
			spinalOcculumBuffed = true
		"Wyrm":
			wyrmBuffed = true
		"Hive":
			hiveBuffed = true
		"Maw":
			mawBuffed = true 
	
	
	
