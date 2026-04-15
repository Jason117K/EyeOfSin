extends Demon
#HeartDemon.gd

# Adjustbale health, cost, attack speed 
@export var health = 1000
@export var cost = 0

var projectile_scene = preload("res://_Entities/Demons/_Crawler/PeaProjectile.tscn")  # Load the projectile scene
var PlantManager
var canAttack = false   # Whether or not the peashooter can attack 
var canAttackSetTrueOnce = false
var spawnAnimDone = false
var isBuffed := false 
var duration : float 
var has_shot := false 

# Raycast to detect zombies in front
@onready var attack_ray = $DMG_RayCast2D
@onready var attack_ray_2 = $DMG_RayCast2D2
@onready var attack_ray_3 = $DMG_RayCast2D3

# Buff Nodes Comp 
@onready var buffNodes = $BuffNodesComponent
#Shoot Location References 
@onready var shootPosition1 = $ShootSpawn1
@onready var shootPosition2 = $ShootSpawn2
@onready var shootPosition3 = $ShootSpawn3
#Circle Sprite for Special Move
@onready var beatOfDeathCirle = $BeatOfDeathCircle

const EXPAND_SCALE: Vector2 = Vector2(0.35, 0.35)  # How large the sprite grows
const START_SCALE: Vector2 = Vector2(0.1, 0.1)

#Grab plantmanager, start default anim and connect/start relevant timers 
func _ready():
	set_attack_ray()
	animSpriteComp = $AnimatedSprite2D
	animSpriteComp.animation = "spawn"

	PlantManager = get_parent().get_parent().get_node("PlantManager")


	# Calculate duration from the current animation's frame count and speed
	var frame_count: int = animSpriteComp.sprite_frames.get_frame_count(animSpriteComp.currentAttackAnim)
	var fps: float = animSpriteComp.sprite_frames.get_animation_speed(animSpriteComp.currentAttackAnim)
	duration = frame_count / fps	
	


#Handles Collision In Relation To Attacking
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
							print("Is Green")
							if self.is_in_group("Green"):
								#print("Is Green, Can Attack")
								canAttack = true
						if collider.is_in_group("Purple"):
							print("Is Purple")
							if self.is_in_group("Purple"):
								print("Can Attack")
								canAttack = true
						if collider.is_in_group("Green"):
							if self.is_in_group("Purple"):
								continue
						elif collider.is_in_group("Purple"):
							if self.is_in_group("Green"):
								continue
					else:
						continue


			if attack_ray_2.is_colliding():
				var this_collision_count = attack_ray_2.get_collision_count()
				for i in range(this_collision_count):
					var this_collider = attack_ray_2.get_collider(i)
					if this_collider and this_collider.is_in_group("Zombie"):
						if this_collider.is_in_group("Green"):
							if self.is_in_group("Green"):
								#print("Is Green, Can Attack")
								canAttack = true
						if this_collider.is_in_group("Purple"):
						#	print("Is Purple")
							if self.is_in_group("Purple"):
							#	print("Can Attack")
								canAttack = true
						if this_collider.is_in_group("Green"):
							if self.is_in_group("Purple"):
								continue
						elif this_collider.is_in_group("Purple"):
							if self.is_in_group("Green"):
								continue
					else:
						continue

			if attack_ray_3.is_colliding():
				var this_collision_count_2 = attack_ray_3.get_collision_count()
				for i in range(this_collision_count_2):
					var this_collider_2 = attack_ray_3.get_collider(i)
					if this_collider_2 and this_collider_2.is_in_group("Zombie"):
						if this_collider_2.is_in_group("Green"):
							if self.is_in_group("Green"):
								#print("Is Green, Can Attack")
								canAttack = true
						if this_collider_2.is_in_group("Purple"):
						#	print("Is Purple")
							if self.is_in_group("Purple"):
							#	print("Can Attack")
								canAttack = true
						if this_collider_2.is_in_group("Green"):
							if self.is_in_group("Purple"):
								continue
						elif this_collider_2.is_in_group("Purple"):
							if self.is_in_group("Green"):
								continue
					else:
						continue
						
						
#Cost getter 
func get_cost():
	return cost
	
					
# Doubles attack speed when receiving a buff 
func receiveBuff(newPlant):
	pass


# Function to create and shoot a new projectile
func shoot_projectile():
	print("Heart Demon Shoot Projectile")
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
		

	
# Handles the peashooter taking damage 
func take_damage(damage):
	#print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		die()

func spawn_done():
	if spawnAnimDone:
		#print("Spyder Self Spawn Adjust 1")
		animSpriteComp.animation = animSpriteComp.currentAnim
		animSpriteComp.play()
	else:
		#print("Spyder Self Spawn Adjust 2")
		animSpriteComp.position = Vector2(animSpriteComp.position.x, animSpriteComp.position.y -8.5)
		animSpriteComp.animation = animSpriteComp.currentAnim
		animSpriteComp.play()
		spawnAnimDone = true 
		
# Handles either looping attack animation or returning to default 
func _on_AnimatedSprite_animation_finished():
	has_shot = false
	if animSpriteComp.animation == "attack":
		beatOfDeathCirle.scale = EXPAND_SCALE
		beatOfDeathCirle.modulate.a = 0.0
	
	if animSpriteComp.animation == "spawn":
		$LightningSpawn.play()
		animSpriteComp.visible = false
		spawn_done()
		return
	if canAttack:
		animSpriteComp.animation = animSpriteComp.currentAttackAnim
		animSpriteComp.play()
		beat_of_death()
	else:
			animSpriteComp.animation = animSpriteComp.currentAnim
			animSpriteComp.play()
			$BuffZone/CollisionShape2D.disabled = true
		


#Shoots based on animation 
func _on_AnimatedSprite_frame_changed():
	if animSpriteComp != null:
		if( animSpriteComp.animation.contains("ttack") ):
			if(animSpriteComp.frame == 3) && not has_shot:
				has_shot = true
				shoot_projectile()
			
func die():
	PlantManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
	
func die_fromClearSpace():
	#print("DD YYYING ---------------------------------")
	buffNodes.clearBuffs()
	queue_free()		
	
	

func _on_mouse_entered() -> void:
	$PreviewNodes/Spider.visible = false
	$PreviewNodes.visible = true 


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 


func finish_spawn():
	animSpriteComp.visible = true		
	animSpriteComp.animation = "idle"
		
	animSpriteComp.play()
	
	
func beat_of_death():
	# Reset sprite to starting state
	beatOfDeathCirle.scale = START_SCALE
	beatOfDeathCirle.modulate.a = 1.0
	beatOfDeathCirle.visible = true

	var tween: Tween = create_tween()
	tween.set_parallel(true)  # Run scale and fade simultaneously

	# Scale up
	tween.tween_property(beatOfDeathCirle, "scale", EXPAND_SCALE, duration)

	# Fade out
	tween.tween_property(beatOfDeathCirle, "modulate:a", 0.0, duration)
	$BuffZone/CollisionShape2D.disabled = false
	
func set_attack_ray():
	if self.is_in_group("Green"):
		#print(" I AM GREEN SPIDER I WILL ATTACK GREEN")
		$DMG_RayCast2D.collision_mask = 3
		$DMG_RayCast2D.set_collision_mask_value(1,false)
		$DMG_RayCast2D.set_collision_mask_value(2,false)
		$DMG_RayCast2D.set_collision_mask_value(3,true)
	else:
		$DMG_RayCast2D.set_collision_mask_value(1,false)
		$DMG_RayCast2D.set_collision_mask_value(2,true)
		$DMG_RayCast2D.set_collision_mask_value(3,false)
	
