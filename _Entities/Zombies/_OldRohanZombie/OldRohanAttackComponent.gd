extends AttackComponent

@export var shootProbability := 20

@onready var attack_rays := [$"../DMGRayCast2D_1", $"../DMGRayCast2D_2", $"../DMGRayCast2D_3"]
@onready var shoot_ray := $"../DMGRayCast2D_Shoot"
@onready var target_demons := []
@onready var teleport_timer := $"../TeleportTimer"
@onready var shoot_timer := $"../ShootTimer"
var projectile_scene := preload("res://_Entities/Zombies/_OldRohanZombie/OldRohanProjectile.tscn")
var rng := RandomNumberGenerator.new()
var laneYPositions := [77.0, 109.0, 141.0, 173.0, 205.0, 239.15, 272.0]

func attack_demon(_collider:Node) -> void:
	pass


func _on_TeleportTimer_timeout() -> void:
	teleport_timer.stop()
	stop_attack()
	teleport_timer.wait_time = rng.randf_range(2, 15)
	is_attacking = true
	zombieSprite.play("Teleport_Start")
	await zombieSprite.animation_finished
	if self.parent.is_in_group("Purple"):
		var alternate_scene := get_tree().get_first_node_in_group("Green")
		parent.reparent(alternate_scene.get_game_layer())
		changeGroup()
	elif self.parent.is_in_group("Green"):
		var alternate_scene := get_tree().get_first_node_in_group("Purple")
		parent.reparent(alternate_scene.get_game_layer())
		changeGroup()
	parent.position = Vector2(650, laneYPositions[rng.randi_range(0, laneYPositions.size() - 1)])
	zombieSprite.play("Teleport_End")
	await zombieSprite.animation_finished
	is_attacking = false
	shoot_timer.start()


#if self.is_in_group("Green"):
		##print(" I AM GREEN CRAWLER I WILL ATTACK GREEN")
		#$DMG_RayCast2D.collision_mask = 3
		#$DMG_RayCast2D.set_collision_mask_value(1,false)
		#$DMG_RayCast2D.set_collision_mask_value(2,false)
		#$DMG_RayCast2D.set_collision_mask_value(3,true)
	#else:
		#$DMG_RayCast2D.set_collision_mask_value(1,false)
		#$DMG_RayCast2D.set_collision_mask_value(2,true)
		#$DMG_RayCast2D.set_collision_mask_value(3,false)


func changeGroup() -> void:
	if(self.parent.is_in_group("Green")):
		parent.remove_from_group("Green")
		parent.add_to_group("Purple")
		#for attack_ray in attack_rays:
			#attack_ray.set_collision_mask_value(1,true)
			#attack_ray.set_collision_mask_value(2,true)
			#attack_ray.set_collision_mask_value(3,true)
		self.parent.set_collision_layer_value(1,false)
		self.parent.set_collision_layer_value(2,true)
		self.parent.set_collision_layer_value(3,false)
	elif(self.parent.is_in_group("Purple")):
		parent.remove_from_group("Purple")
		parent.add_to_group("Green")
		#for attack_ray in attack_rays:
			#attack_ray.set_collision_mask_value(1,true)
			#attack_ray.set_collision_mask_value(2,true)
			#attack_ray.set_collision_mask_value(3,true)
		self.parent.set_collision_layer_value(1,false)
		self.parent.set_collision_layer_value(2,false)
		self.parent.set_collision_layer_value(3,true)

func _on_AttackTimer_timeout() -> void:
	if(teleport_timer.is_stopped()):
		teleport_timer.start()
	##print("Basic Zombie Attack Timer Timeout")
		#TODO Make Attacking Sounds More Efficient
	if "Bucket" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUCKET_DEAL_DAMAGE)
	elif "Dancer" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUMMONER_ATTACK)
	elif "Screen" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SCREEN_DOOR_ATTACK)
	else:
		##print("Playing ZOMBIE DEAL DAMAGE in _on_AttackTimer_timeout for parent ", parent.name)
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)
	if target_demons == null:
		return
	for demon:Demon in target_demons:
		if(is_instance_valid(demon)):
			if(((demon.is_in_group("Green") && self.parent.is_in_group("Green"))
		|| (demon.is_in_group("Purple") && self.parent.is_in_group("Purple")))):
				if(demon.get_health() >= 0):
					if demon.has_method("mawBuffed"):
						if demon.can_eat_zombie == true :
							demon.eat_zombie()
							get_parent().die()
					if demon.has_method("spinalOcculumWyrmBuffed"):
						if demon.can_damage_zombie == true :
							zombie.getCompManager().take_damage(10)
							
					demon.take_damage(attack_power)
				else:
					stop_attack()
					return
				if "Ticker" in parent.get_name():
					get_parent().die()
			else:
				stop_attack()
				return
	if(target_demons.size() > 0):
		zombieSprite.play("Stomp_End")
		await zombieSprite.animation_finished
	target_demons = []
	stop_attack()
# Stops the attack and resumes movement
func stop_attack() -> void:
	##print("Stopping Attack")
	is_attacking = false
	#target_demons = null
	target_demons.clear()
	attack_timer.stop()

func _process(_delta: float) -> void:
	if not is_attacking:
		var colliders := []
		for ray:Node in attack_rays:
			if ray.is_colliding():
				var collider :Node= ray.get_collider()
				##print(parent.name , " Its collding with ", collider.name )
				if collider:
					if collider.is_in_group("Demons"):
						##print("Collider In Right Group")
						if collider.get_parent().get_parent() != self.get_parent().get_parent().get_parent():
							if collider.get_parent().get_parent().get_parent() != self.get_parent().get_parent().get_parent():
								return
						if("PoleVaultZombie" in parent.name):
							if canSpecial:
								parent.special_move()
								canSpecial = false
								pass
							else:
								if parent.getBusy() == false:
									pass
								else:
									colliders.push_back(collider)
						else:
							colliders.push_back(collider)
		#this code block is for attacking multiple enemies at a time
		if colliders.size() > 0:
			is_attacking = true
			target_demons = colliders
			zombieSprite.play("Stomp_Start")
			await zombieSprite.animation_finished
			if "Bucket" in parent.name:
				AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUCKET_DEAL_DAMAGE)
			elif "Dancer" in parent.name:
				AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUMMONER_ATTACK)
			elif "Screen" in parent.name:
				AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SCREEN_DOOR_ATTACK)
			else:
				##print("Playing ZOMBIE DEAL DAMAGE in attack_demon for parent ", parent.name)
				AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)
			attack_timer.start()
		else:
			if shoot_ray.is_colliding() && 1 == rng.randi_range(1, (shootProbability)):
				if shoot_ray.get_collider().is_in_group("Demons"):
					shoot()


func shoot() -> void:
	stop_attack()
	is_attacking = true
	zombieSprite.play("Shoot_Start")
	await zombieSprite.animation_finished

	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.SPYDER_SPIT)
	var projectile := projectile_scene.instantiate()
	projectile.global_position = global_position - Vector2(32, 0)  # Adjust starting position
	get_parent().get_parent().add_child(projectile)  # Add the projectile to the game layer
	
	zombieSprite.play("Shoot_End")
	await zombieSprite.animation_finished
	is_attacking = false
