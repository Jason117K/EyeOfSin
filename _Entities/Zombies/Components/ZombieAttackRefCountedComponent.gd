extends RefCounted

class_name ZombieAttackRefCountedComponent 


var attack_power: float
var is_attacking := false  # Whether or not we attacking
var target_demon :Node = null  # Holds reference to the demon being attacked
var canSpecial := true # Determines whether or not a special move can be performed
var _frame_counter: int = 0
var base_anim_duration: float
var attack_starting_pos: Vector2
var attack_time_wait_time : float
var attack_timer_started := false 
var attack_time_elapsed : float = 0 
var attack_ray : RayCast2D #= $"../DMGRayCast2D" # Raycast to detect demons in front of the zombie
var zombieSprite: AnimatedSprite2D #= $"../AnimatedSprite2D" # RefCounted to sprite comp
#var attack_timer :Timer #= $"../AttackTimer" # Adjustable timer to control attack speed
#@onready var attack_audio_player = $"../AttackAudioPlayer" # RefCounted to attack audio
var parent_zombie : Zombie
var my_level: Node
var target_group : String = "Demons"

func _init(new_parent_zombie:Zombie) -> void:
	parent_zombie = new_parent_zombie
	attack_power = new_parent_zombie.attack_power
	my_level = new_parent_zombie.get_parent().get_parent()
	attack_ray = parent_zombie.attack_ray
	zombieSprite = parent_zombie.animatedSprite
	#attack_timer = parent_zombie.attack_timer
	_frame_counter = randi() % 3
	if new_parent_zombie.is_in_group("Green"):
		##print(parent," DOING GREEN SET FOOOOOR ", attack_ray)
		attack_ray.set_collision_mask_value(1,false)
		attack_ray.set_collision_mask_value(2,false)
		attack_ray.set_collision_mask_value(3,true)
	else:
		if attack_ray == null:
			pass
			#print(new_parent_zombie," DOING PURPLE SET FOOOOOR ", attack_ray)
		attack_ray.set_collision_mask_value(1,false)
		attack_ray.set_collision_mask_value(2,true)
		attack_ray.set_collision_mask_value(3,false)
	# Compute base animation duration and set timer for first hit
	if zombieSprite.sprite_frames.has_animation("Attack"):
		base_anim_duration = zombieSprite.sprite_frames.get_frame_count("Attack") / zombieSprite.sprite_frames.get_animation_speed("Attack")
	#attack_timer.one_shot = true
	var safe_speed : float = max(new_parent_zombie.attack_speed, 0.01)
	attack_time_wait_time = new_parent_zombie.attack_damage_point / safe_speed

func increase_damage(damage_increase_percentage:float)->void:
	attack_power = attack_power + (attack_power * damage_increase_percentage)


func silence() -> void:
	attack_power = attack_power/2


# Attack State Getter
func getAttackState() -> bool:
	return is_attacking

# Sets is_attacking to true and plays the audio will also starting the attack cooldown timer
func attack_demon(collider:Node) -> void:
	if collider.is_in_group("Drone"):
		if collider.get_is_in_combat() == true:
			if collider.get_enemy_combatant() != self:
				return
			else:
				pass 
		else:
			pass
			collider.enter_combat(parent_zombie)
			
	is_attacking = true
	target_demon = collider
	##print("TName is ", target_demon.name)
	##print("I am " , self.name)
	zombieSprite.speed_scale = base_anim_duration * parent_zombie.attack_speed
	#print("Now Attack Demon")
	zombieSprite.play("Attack")
	#attack_audio_player.play()
	#TODO Make Attacking Sounds More Efficient
	if "Bucket" in parent_zombie.name:
		AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUCKET_DEAL_DAMAGE)
	elif "Dancer" in parent_zombie.name:
		AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUMMONER_ATTACK)
	elif "Screen" in parent_zombie.name:
		AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.SCREEN_DOOR_ATTACK)
	else:
		##print("Playing ZOMBIE DEAL DAMAGE in attack_demon for parent ", parent.name)
		AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)
	attack_timer_started = true 

	#if "Ticker" in parent.get_name():
		##print("Ticker Should Die ")
		#parent.queue_free()

# Damages the target demon and decides whether or not to keep attacking
func _on_AttackTimer_timeout() -> void:

	##print(parent_zombie.global_position, " Attack Demon Again ",attack_starting_pos)
	if abs(attack_starting_pos.x - parent_zombie.global_position.x) > 2:
		stop_attack()
		return
	##print("Basic Zombie Attack Timer Timeout")
	if target_demon != null:
		if parent_zombie.is_in_group("Green"):
			if target_demon.is_in_group("Purple"):
				stop_attack()
		if parent_zombie.is_in_group("Purple"):
			if target_demon.is_in_group("Green"):
				stop_attack()

		#TODO Make Attacking Sounds More Efficient
	if "Bucket" in parent_zombie.name:
		AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUCKET_DEAL_DAMAGE)
	elif "Dancer" in parent_zombie.name:
		AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUMMONER_ATTACK)
	elif "Screen" in parent_zombie.name:
		AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.SCREEN_DOOR_ATTACK)
	else:
		##print("Playing ZOMBIE DEAL DAMAGE in _on_AttackTimer_timeout for parent ", parent.name)
		AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)
		
	if(is_instance_valid(target_demon) && target_demon.is_in_group("Portal") != true ):
		##print("target demon name is ", target_demon.name)
		if(target_demon.has_method("get_health") && (target_demon.get_health()!=null)): 
			#TODO Give Spiderling Get Health
			if(target_demon.get_health() >= 0):
				if target_demon.has_method("eat_zombie"):
					if target_demon.can_eat_zombie == true :
					#	#print("Demon Can Eat Me Time to Die")
						target_demon.eat_zombie(parent_zombie)
						parent_zombie.die()
				if target_demon.has_method("spinalOcculumWyrmBuffed"):
					if target_demon.can_damage_zombie == true :
						parent_zombie.take_damage(false,10,false)
				if target_demon.has_method("lightning_maw_buff"):
					if target_demon.is_lightning_maw_buff:
						parent_zombie.take_damage(false,target_demon.get_lightning_damage(),false)

				##print(attack_power ," Calling Take Damage on ", target_demon)

				target_demon.take_damage(attack_power)
				# Schedule next hit at same animation fraction in next loop
				var safe_speed : float = max(parent_zombie.attack_speed, 0.01)
				attack_time_wait_time = 1.0 / safe_speed
				attack_timer_started = true 
			else:
				stop_attack()
		if "Ticker" in parent_zombie.get_name():
			parent_zombie.die()
	else:
		stop_attack()

# Stops the attack and resumes movement
func stop_attack() -> void:
	##print("Stopping Attack no damage")
	is_attacking = false
	target_demon = null
	attack_timer_started = false
	zombieSprite.speed_scale = 1.0


func tick(delta: float) -> void:
	if attack_timer_started:
		attack_time_elapsed += delta 
		if attack_time_elapsed >= attack_time_wait_time:
			_on_AttackTimer_timeout()
			attack_time_elapsed = 0
			
	if not is_attacking:
		_frame_counter += 1
		if _frame_counter % 3 != 0:
			return
		if attack_ray.is_colliding():
			var collider : Node = attack_ray.get_collider()
			if collider:
				##print(parent.name , " Its 77 collding with ", collider.name )
				if collider.is_in_group(target_group):
					if collider.has_method("demon_minion_busy"):
						##print("Calling Demon 77 Minion Busy On ", collider)
						if collider.demon_minion_busy(parent_zombie):
							##print(collider, " is busy early return 77")
							return
					#TODO Make Sundered Extend Attack Comp
					if("Sundered" in parent_zombie.name):
						if canSpecial && !collider.is_in_group("Drone") && collider.is_in_group("Demons"):
							#print("Sundered Special Move Pole Vault")
							parent_zombie.special_move()
							canSpecial = false
							is_attacking = true
							pass
						else:
							##print(self, " time to attack demon here ")
							attack_starting_pos = parent_zombie.global_position
							attack_demon(collider)
					else:
						##print(self, " time to attack demon")
						attack_starting_pos = parent_zombie.global_position
						attack_demon(collider)
func switch_sides()->void:
	target_group = "Zombie"
	if parent_zombie != null:
		if parent_zombie.is_in_group("Green"):
			attack_ray.set_collision_mask_value(1,false)
			attack_ray.set_collision_mask_value(2,false)
			attack_ray.set_collision_mask_value(3,false)
			attack_ray.set_collision_mask_value(4,false)
			attack_ray.set_collision_mask_value(5,true)
		else:
			attack_ray.set_collision_mask_value(1,false)
			attack_ray.set_collision_mask_value(2,false)
			attack_ray.set_collision_mask_value(3,false)
			attack_ray.set_collision_mask_value(4,true)










##
