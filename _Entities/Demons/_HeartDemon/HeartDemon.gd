extends Demon
#HeartDemon.gd

# Adjustbale health, cost, attack speed 
#@export var health = 1000
@export var cost = 0

var projectile_scene = preload("res://_Entities/Demons/_Crawler/PeaProjectile.tscn")  # Load the projectile scene
var PlantManager
var canAttack = false   # Whether or not the peashooter can attack 
var canAttackSetTrueOnce = false
#var spawnAnimDone = false
var duration : float 
#var has_shot := false 

# Raycast to detect zombies in front
@onready var attack_ray = $DMG_RayCast2D
@onready var attack_ray_2 = $DMG_RayCast2D2
@onready var attack_ray_3 = $DMG_RayCast2D3
@onready var damage_zone := $DMGZone
# Buff Nodes Comp 
@onready var buffNodes = $BuffNodesComponent
#Shoot Location References 
@onready var shootPosition1 = $ShootSpawn1
@onready var shootPosition2 = $ShootSpawn2
@onready var shootPosition3 = $ShootSpawn3

#Circle Sprite for Special Move
#@onready var beatOfDeathCirle = $BeatOfDeathCircle

const EXPAND_SCALE: Vector2 = Vector2(0.35, 0.35)  # How large the sprite grows
const START_SCALE: Vector2 = Vector2(0.1, 0.1)

#Grab plantmanager, start default anim and connect/start relevant timers 
func _ready():
	print("Hero DEMON Ready")
	Global.register_hero_demon(self)
	$PreviewNodes/AnimatedSprite2D.hide()
	set_attack_collision()


	PlantManager = get_parent().get_parent().get_node("PlantManager")


	# Calculate duration from the current animation's frame count and speed
	var frame_count: int = animSpriteComp.sprite_frames.get_frame_count(animSpriteComp.currentAttackAnim)
	var fps: float = animSpriteComp.sprite_frames.get_animation_speed(animSpriteComp.currentAttackAnim)
	duration = frame_count / fps	
	


#Handles Collision In Relation To Attacking
func _process(_delta):
	if animSpriteComp.animation == "spawn":
		return
		
	if canAttack == false:
		check_attack_rays()

# Re-check rays immediately on animation finish
func check_attack_rays():
	canAttack = false
	for ray in [attack_ray, attack_ray_2, attack_ray_3]:
		if ray.is_colliding():
			for i in range(ray.get_collision_count()):
				var collider = ray.get_collider(i)
				if collider and collider.is_in_group("Zombie"):
					if collider.is_in_group("Green") and self.is_in_group("Green"):
						canAttack = true
					elif collider.is_in_group("Purple") and self.is_in_group("Purple"):
						canAttack = true
						
						
#Cost getter 
func get_cost():
	#print("Return , ", cost )
	return cost
	
					
# Doubles attack speed when receiving a buff 
func receiveBuff(newPlant):
	pass


# Function to create and shoot a new projectile
func shoot_projectile():
	#print("Heart Demon Shoot Projectile")
	var runtime_seconds = Time.get_ticks_msec() / 1000.0
	
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	
	var shoot_positions = [shootPosition1, shootPosition2,shootPosition3]
	for shoot_pos in shoot_positions:
		var projectile = projectile_scene.instantiate()
		projectile.position = shoot_pos.global_position
		get_parent().call_deferred("add_child", projectile)
		
	canAttack = false
	
	if self.is_in_group("Green"):
		pass


	canAttack = false
	
	
func set_attack_false():
	canAttack = false 
		

	


		
	


					
func die():
	PlantManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
	
func die_fromClearSpace():
	#print("DD YYYING ---------------------------------")
	buffNodes.clearBuffs()
	queue_free()		
	
	

func _on_mouse_entered() -> void:
	$PreviewNodes.visible = true 


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 

	
	
#func beat_of_death():
	## Reset sprite to starting state
	#beatOfDeathCirle.scale = START_SCALE
	#beatOfDeathCirle.modulate.a = 1.0
	#beatOfDeathCirle.visible = true
#
	#var tween: Tween = create_tween()
	#tween.set_parallel(true)  # Run scale and fade simultaneously
#
	## Scale up
	#tween.tween_property(beatOfDeathCirle, "scale", EXPAND_SCALE, duration)
#
	## Fade out
	#tween.tween_property(beatOfDeathCirle, "modulate:a", 0.0, duration)
	#$BuffZone/CollisionShape2D.disabled = false
	
func set_attack_collision():
	var attack_rays = [attack_ray,attack_ray_2,attack_ray_3]
	if self.is_in_group("Green"):
		damage_zone.set_collision_mask_value(1,false)
		damage_zone.set_collision_mask_value(2,false)
		damage_zone.set_collision_mask_value(3,true)
		for attacking_ray in attack_rays:
			attacking_ray.set_collision_mask_value(1,false)
			attacking_ray.set_collision_mask_value(2,false)
			attacking_ray.set_collision_mask_value(3,true)
	else:
		damage_zone.set_collision_mask_value(1,false)
		damage_zone.set_collision_mask_value(2,true)
		damage_zone.set_collision_mask_value(3,false)
		for attacking_ray in attack_rays:
			attacking_ray.set_collision_mask_value(1,false)
			attacking_ray.set_collision_mask_value(2,true)
			attacking_ray.set_collision_mask_value(3,false)
	
	
	
	
	
	
	
	
	
	
	#for attacking_ray in attack_rays:
		#if self.is_in_group("Green"):
			#attacking_ray.collision_mask = 3
			#attacking_ray.set_collision_mask_value(1,false)
			#attacking_ray.set_collision_mask_value(2,false)
			#attacking_ray.set_collision_mask_value(3,true)
		#else:
			#attacking_ray.set_collision_mask_value(1,false)
			#attacking_ray.set_collision_mask_value(2,true)
			#attacking_ray.set_collision_mask_value(3,false)
	
	
