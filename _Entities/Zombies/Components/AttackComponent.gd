extends Node2D
# AttackComp.gd 
# Handles Zombie attacking Demon Behavior 

class_name AttackComponent

@export var attack_power = 33 # Adjustable reference to attack damage
var is_attacking = false  # Whether or not we attacking
var target_demon = null  # Holds reference to the demon being attacked
var canSpecial = true # Determines whether or not a special move can be performed
var _frame_counter: int = 0

@onready var attack_ray = $"../DMGRayCast2D" # Raycast to detect demons in front of the zombie
@onready var zombieSprite = $"../AnimatedSprite2D" # RefCounted to sprite comp 
@onready var attack_timer = $"../AttackTimer" # Adjustable timer to control attack speed
#@onready var attack_audio_player = $"../AttackAudioPlayer" # RefCounted to attack audio 
@onready var parent = get_parent() # Parent Zombie Attacking 
@onready var zombie = 	get_parent()
var my_level: Node

func _ready() -> void:
	my_level = parent.get_parent().get_parent()
	_frame_counter = randi() % 3
	if parent.is_in_group("Green"):
		#print(parent," DOING GREEN SET FOOOOOR ", attack_ray)
		attack_ray.set_collision_mask_value(1,false)
		attack_ray.set_collision_mask_value(2,false)
		attack_ray.set_collision_mask_value(3,true)
	else:
		#print(parent," DOING PURPLE SET FOOOOOR ", attack_ray)
		attack_ray.set_collision_mask_value(1,false)
		attack_ray.set_collision_mask_value(2,true)
		attack_ray.set_collision_mask_value(3,false)
	
	
# Attack State Getter 
func getAttackState():
	return is_attacking

# Sets is_attacking to true and plays the audio will also starting the attack cooldown timer
func attack_demon(collider):
	
	if collider.is_in_group("Drone"):
		if collider.get_is_in_combat() == true:
			if collider.get_enemy_combatant() != self:
				return
			else:
				pass 
		else:
			pass
			collider.enter_combat(self)
			
	is_attacking = true
	target_demon = collider
	#print("TName is ", target_demon.name)
	#print("I am " , self.name)
	zombieSprite.play("Attack")
	#attack_audio_player.play()
	#TODO Make Attacking Sounds More Efficient
	if "Bucket" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUCKET_DEAL_DAMAGE)
	elif "Dancer" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUMMONER_ATTACK)
	elif "Screen" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SCREEN_DOOR_ATTACK)
	else:
		#print("Playing ZOMBIE DEAL DAMAGE in attack_demon for parent ", parent.name)
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)
	
	attack_timer.start()
	#if "Ticker" in parent.get_name():
		#print("Ticker Should Die ")
		#parent.queue_free()

# Damages the target demon and decides whether or not to keep attacking
func _on_AttackTimer_timeout():
	#print("Basic Zombie Attack Timer Timeout")
		#TODO Make Attacking Sounds More Efficient
	if "Bucket" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUCKET_DEAL_DAMAGE)
	elif "Dancer" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SUMMONER_ATTACK)
	elif "Screen" in parent.name:
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.SCREEN_DOOR_ATTACK)
	else:
		#print("Playing ZOMBIE DEAL DAMAGE in _on_AttackTimer_timeout for parent ", parent.name)
		AudioManager.create_2d_audio_at_location(parent.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_DEAL_DAMAGE)
		
	if(is_instance_valid(target_demon) && target_demon.is_in_group("Portal") != true ):
		#print("target demon name is ", target_demon.name)
		if(target_demon.has_method("get_health") && (target_demon.get_health()!=null)): 
			#TODO Give Spiderling Get Health
			if(target_demon.get_health() >= 0):
				if target_demon.has_method("eat_zombie"):
					if target_demon.can_eat_zombie == true :
					#	print("Demon Can Eat Me Time to Die")
						target_demon.eat_zombie(self)
						get_parent().die()
				if target_demon.has_method("spinalOcculumWyrmBuffed"):
					if target_demon.can_damage_zombie == true :
						zombie.getCompManager().take_damage(10)
				if target_demon.has_method("lightning_maw_buff"):
					if target_demon.is_lightning_maw_buff:
						zombie.getCompManager().take_damage(target_demon.get_lightning_damage())
				target_demon.take_damage(attack_power)
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
	target_demon = null
	attack_timer.stop()

func _process(_delta):
	if not is_attacking:
		_frame_counter += 1
		if _frame_counter % 3 != 0:
			return
		if attack_ray.is_colliding():
			var collider = attack_ray.get_collider()
			#print(parent.name , " Its collding with ", collider.name )
			if collider:
				if collider.is_in_group("Demons"):
					if collider.has_method("demon_minion_busy"):
						if collider.demon_minion_busy(parent):
							return
					#TODO Make Sundered Extend Attack Comp
					if("Sundered" in parent.name):
						if canSpecial && !collider.is_in_group("Drone"):
							parent.special_move()
							canSpecial = false
							pass
						else:
							attack_demon(collider)
					else:
						attack_demon(collider)
