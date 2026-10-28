extends Area2D
#Drone.gd

# Handles Hive Drone Behavior 


# Signals
signal drone_died(drone:Node)
var current_zombie : Zombie = null

# Export variables 
@export var health := 75          # Drone Health
@export var max_health := 75
# Gaze of Baal: triple damage, double health (taken as half damage, so other
# buffs that set health/max_health stay untouched).
@export var baal_damage_multiplier := 3.0
@export var baal_health_multiplier := 2.0
@export var attack_damage := 7    # Attack Damage
@export var attack_speed := 1.0   # Attacks per second
@export var move_speed := 200     # Pixels per second
@export var rotation_speed := 5.0 # How fast the drone rotates to face target
@export var attack_range := 50    # How close the drone needs to be to attack
@export var return_threshold := 5 # How close to rest position is considered "arrived"
@export var spinal_occulum_buffed_health := 200
@export var spinal_occulum_buffed_max_health := 200


enum State { IDLE, PURSUING, ATTACKING, RETURNING }

var state: State = State.IDLE
var current_target : Node
var velocity := Vector2.ZERO
var rest_position : Vector2
var explodeBuff := false
var isCrawlerBuffed := false
var base_attack_damage: int
var is_in_combat := false
var current_zombie_to_fight : Area2D
var blood_on_death := false
var is_maw_buffed := false
var is_crawler_buffed := false
var is_baal_buffed := false
var is_demo := false
# Hive ultimate: double health and damage, "_ultimate" animations. Permanent.
var is_leveled_up := false

@onready var animatedSpriteComp := $AnimatedSprite2D  # RefCounted to Sprite2D Comp



func _ready() -> void:
	base_attack_damage = attack_damage
	animatedSpriteComp.animation = "idle"
	
	
	# Create & configure attack timer
	var timer := Timer.new()
	add_child(timer)
	var attack_length : float = animatedSpriteComp.get_animation_length("attack")
	##print("Attack animation is ", attack_length, " seconds long")
	timer.wait_time = attack_length
	timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	timer.start()
	if self.is_in_group("Green"):
		#print(self, "THIS DEMON MINION IS GREEN")
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_mask_value(4,false)
		set_collision_mask_value(5,true)
		
		set_collision_layer_value(1,false)
		set_collision_layer_value(2,false)
		set_collision_layer_value(3,true)
	else:
		#print(self, "THIS DEMON MINION IS PURPLE")
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_mask_value(4,true)
		
		set_collision_layer_value(1,false)
		set_collision_layer_value(2,true)
		set_collision_layer_value(3,false)

func current_zombie_dead() -> void:
	##print(self, " received 77 zombie dead signal")
	_release_claim()

# Let go of the zombie holding this wasp (it died, or the swarm sent the wasp
# after a different zombie) so the next zombie that reaches it can stop.
func _release_claim() -> void:
	if is_instance_valid(current_zombie) and current_zombie.zombie_death.is_connected(current_zombie_dead):
		current_zombie.zombie_death.disconnect(current_zombie_dead)
	current_zombie = null
	exit_combat()

func is_holding(zombie: Node) -> bool:
	return current_zombie == zombie

func demon_minion_busy(questioning_zombie: Zombie) -> bool:
	# Never busy to the zombie already holding it: it re-checks after an
	# interrupted attack (e.g. knockback).
	if current_zombie == questioning_zombie:
		return false
	if is_instance_valid(current_zombie) and not current_zombie.is_dead:
		return true
	_release_claim()
	current_zombie = questioning_zombie
	##print(self, " Setting Can 77 Move to false because of ", questioning_zombie)
	current_zombie.zombie_death.connect(current_zombie_dead)
	return false
				
func spinal_occulum_buff() -> void:
	self.health = spinal_occulum_buffed_health
	self.max_health = spinal_occulum_buffed_max_health
		
	
func occulum_buff() -> void:
	blood_on_death = true

func crawler_buff() -> void:
	is_crawler_buffed = true

func maw_buff() -> void:
	#print("Maw Buff Drone so Drone Go Boom")
	is_maw_buffed = true

func baal_buff() -> void:
	is_baal_buffed = true

func undo_baal_buff() -> void:
	is_baal_buffed = false

# Called after add_child, so base_attack_damage is already set and doubling it
# keeps doubleDamage()/regularDamage() relative to the leveled damage.
func level_up() -> void:
	if is_leveled_up:
		return
	is_leveled_up = true
	health *= 2
	max_health *= 2
	attack_damage *= 2
	base_attack_damage *= 2
	if animatedSpriteComp != null:
		setAnimation(String(animatedSpriteComp.animation).trim_suffix("_ultimate"))

func make_drone_glow() -> void:
	animatedSpriteComp.make_glow()


func doubleDamage() -> void:
	attack_damage = base_attack_damage * 2
	animatedSpriteComp.buff()

func regularDamage() -> void:
	attack_damage = base_attack_damage
	animatedSpriteComp.debuff()

# Activates the drone explosion buff
func makeExplode() -> void:
	explodeBuff = true

func makeNotExplode() -> void:
	explodeBuff = false


func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	#print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		pass
		#print_scene_tree(child, indent + 1)
		
		


# Handles the drone taking damage
func take_damage(amount: int) -> void:
	if is_baal_buffed:
		amount = ceili(amount / baal_health_multiplier)
	health -= amount
	if health <= 0:
		##print("Die Cos Health too Low")
		die()

func get_health() -> int:
	return health

func increase_health(added_health_amount: int) -> void:
	if max_health != null:
		health = clamp(health + added_health_amount, 0, max_health)

# Changes the drone's current animation (its "_ultimate" version once leveled up)
func setAnimation(newAnimation: String) -> void:
	var ultimate_animation := newAnimation + "_ultimate"
	if is_leveled_up and animatedSpriteComp.sprite_frames.has_animation(ultimate_animation):
		newAnimation = ultimate_animation
	animatedSpriteComp.animation = newAnimation

func set_damage(new_damage: int) -> void:
	attack_damage = new_damage



func die() -> void:
	emit_signal("drone_died", self)
	if blood_on_death:
		pass
		generate_blood()
	if is_maw_buffed:
		#print("Should Death BOOM BOOM")
		death_explode()
	if is_crawler_buffed:
		death_slow()
	queue_free()

func death_slow() -> void:
	if current_zombie_to_fight != null:
		current_zombie_to_fight.slow()
	
func death_explode() -> void:
	var death_bomb :Area2D= Global.get_bomb_scene().instantiate()
	if is_demo:
		#print("DRONE GO BOOM")
		get_parent().get_parent().add_child(death_bomb)
		death_bomb.global_position = self.global_position
		if self.is_in_group("Green"):
			death_bomb.add_to_group("Green")
		else:
			death_bomb.add_to_group("Purple")
	else:
		
		if self.is_in_group("Green"):
			death_bomb.add_to_group("Green")
		else:
			death_bomb.add_to_group("Purple")
		get_parent().get_parent().add_child(death_bomb)
		death_bomb.global_position = self.global_position
	
func generate_blood() -> void:
	#print("Generating Blood")
	var blood_instance :Area2D= Global.get_blood_scene().instantiate()
	get_parent().add_child(blood_instance)
	blood_instance.set_fast_pickup_time()
	blood_instance.global_position = self.global_position


func enable_hurtbox() -> void:
	$HurtBox.set_deferred("disabled", false)
	
# Attacks a given enemy without buffs 
func attack_target(enemy: Area2D) -> void:
	$HurtBox.set_deferred("disabled", false)
	current_target = enemy
	if current_zombie != null and current_zombie != enemy:
		_release_claim()
	#if explodeBuff:
		#enemy.fightDroneExplode()
	#if isCrawlerBuffed:
		#enemy.make_spawn_slow_on_death()
	state = State.PURSUING

# Sends the drone back to it's original resting position
func return_to_position(pos: Vector2) -> void:
	rest_position = pos
	current_target = null
	state = State.RETURNING
	exit_combat()


func _physics_process(delta: float) -> void:
	match state:
		State.PURSUING:

			if _target_gone():
				_head_home()
				return
			var direction :Vector2= current_target.global_position - global_position

			var distance := direction.length()
			if distance > attack_range:
				velocity = direction.normalized() * move_speed
				position += velocity * delta
			else:
				if direction.x < 0:
					#print(self.get_name(), " Drone is behind enemy , ", current_target)
					state = State.PURSUING
					self.global_position = self.global_position + Vector2(-40,0)
				else:
					velocity = Vector2.ZERO
					state = State.ATTACKING

		State.ATTACKING:
			if _target_gone():
				_head_home()
				return
			var distance := global_position.distance_to(current_target.global_position)
			if distance > attack_range:
				state = State.PURSUING

		State.RETURNING:
			#if not rest_position:
				#state = State.IDLE
				#return
			var direction :Vector2= rest_position - global_position
			var distance := direction.length()
			if distance > return_threshold:
				velocity = direction.normalized() * move_speed
				global_position += velocity * delta
			else:
				global_position = rest_position
				velocity = Vector2.ZERO
				state = State.IDLE
		State.IDLE:
			velocity = Vector2.ZERO

# Dead zombies aren't freed (they stay for the death animation), and a flipped one
# leaves the "Zombie" group: either way the target is gone, even if still valid.
# Before this a wasp the swarm didn't re-task hovered over the corpse forever.
func _target_gone() -> bool:
	return current_target == null or not is_instance_valid(current_target) \
			or current_target.get("is_dead") == true or not current_target.is_in_group("Zombie")

func _head_home() -> void:
	current_target = null
	velocity = Vector2.ZERO
	state = State.RETURNING
	exit_combat()

# Handles the drone dealing attack damage 
func _on_attack_timer_timeout() -> void:
	if state == State.ATTACKING and current_target and is_instance_valid(current_target):
		setAnimation("attack")
		var distance := global_position.distance_to(current_target.global_position)
		if distance <= attack_range:
			var hit := attack_damage * (baal_damage_multiplier if is_baal_buffed else 1.0)
			current_target.take_damage(false,hit,false)


func get_is_in_combat() -> bool:
	return is_in_combat

func enter_combat(zombie: Area2D) -> void:
	current_zombie_to_fight = zombie
	is_in_combat = true

func exit_combat() -> void:
	is_in_combat = false
	current_zombie_to_fight = null

func get_enemy_combatant()->Area2D:
	return current_zombie_to_fight
