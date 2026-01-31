extends AttackComponent

@onready var attack_rays = [$"../DMGRayCast2D_1", $"../DMGRayCast2D_2", $"../DMGRayCast2D_3"]
@onready var target_plants = []
@onready var teleport_timer = $"../TeleportTimer"
var rng = RandomNumberGenerator.new()
var laneYPositions = [77.0, 109.0, 141.0, 173.0, 205.0, 239.15, 272.0]

func attack_plant(collider):
	#I apologize that I have to do this
	print()
	
func _on_TeleportTimer_timeout():
	teleport_timer.stop()
	teleport_timer.wait_time = rng.randf_range(2, 7)
	is_attacking = true
	zombieSprite.play("Teleport_Start")
	await zombieSprite.animation_finished
	if self.parent.is_in_group("Purple"):
		var alternate_scene = get_tree().get_first_node_in_group("Green")
		parent.reparent(alternate_scene)
		parent.position = Vector2(650, laneYPositions[rng.randi_range(0, laneYPositions.size() - 1)])
		parent.remove_from_group("Purple")
		parent.add_to_group("Green")
	elif self.parent.is_in_group("Green"):
		var alternate_scene = get_tree().get_first_node_in_group("Purple")
		parent.reparent(alternate_scene)
		parent.position = Vector2(650, laneYPositions[rng.randi_range(0, laneYPositions.size() - 1)])
		parent.remove_from_group("Green")
		parent.add_to_group("Purple")
	zombieSprite.play("Teleport_End")
	await zombieSprite.animation_finished
	is_attacking = false
	
func _on_AttackTimer_timeout():
	teleport_timer.start()
	#print("Basic Zombie Attack Timer Timeout")
		#TODO Make Attacking Sounds More Efficient
	if "Bucket" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUCKET_DEAL_DAMAGE)
	elif "Dancer" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUMMONER_ATTACK)
	elif "Screen" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SCREEN_DOOR_ATTACK)
	else:
		print("Playing ZOMBIE DEAL DAMAGE in _on_AttackTimer_timeout for parent ", parent.name)
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)
		
	for plant in target_plants:
		if(is_instance_valid(plant)):
			print("target plant name is ", plant.name)
			if(plant.health >= 0):
				if plant.has_method("mawBuffed"):
					if plant.can_eat_zombie == true :
						print("Demon Can Eat Me Time to Die")
						plant.eat_zombie()
						get_parent().die()
				if plant.has_method("walnutWyrmBuffed"):
					if plant.can_damage_zombie == true :
						print("Demon Hive Can Damage Me While I Eat")
						zombie.getCompManager().take_damage(10)
						
				plant.take_damage(attack_power)
			else:
				stop_attack()
			if "Ticker" in parent.get_name():
				get_parent().die()
		else:
			stop_attack()
			
# Stops the attack and resumes movement
func stop_attack():
	#print("Stopping Attack")
	is_attacking = false
	target_plants = null
	attack_timer.stop()

func _process(_delta):
	if not is_attacking:
		var colliders = []
		for ray in attack_rays:
			if ray.is_colliding():
				var collider = ray.get_collider()
				#print(parent.name , " Its collding with ", collider.name )
				if collider:
					if collider.is_in_group("Plants"):
						#print("Collider In Right Group")
						if collider.get_parent().get_parent() != self.get_parent().get_parent().get_parent():
							if collider.get_parent().get_parent().get_parent() != self.get_parent().get_parent().get_parent():
								#print("Collider Early Return")
								return
					#	print(collider.name , " is in group plants")
						if("PoleVaultZombie" in parent.name):
							print(parent.name, " - canSpecialPP: ", canSpecial)
							print("PP Parent Is Pole Vault")
							if canSpecial:
								print("PP Pole Vault Special Mo")
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
			target_plants = colliders
			zombieSprite.play("Stomp")
			if "Bucket" in parent.name:
				AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUCKET_DEAL_DAMAGE)
			elif "Dancer" in parent.name:
				AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUMMONER_ATTACK)
			elif "Screen" in parent.name:
				AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SCREEN_DOOR_ATTACK)
			else:
				print("Playing ZOMBIE DEAL DAMAGE in attack_plant for parent ", parent.name)
				AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)
			attack_timer.start()
