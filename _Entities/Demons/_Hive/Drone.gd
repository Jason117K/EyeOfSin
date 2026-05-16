extends Area2D
#Drone.gd

# Handles Hive Drone Behavior 


# Signals
signal drone_died(drone)

# Export variables 
@export var health = 75          # Drone Health
@export var max_health = 75
@export var attack_damage = 7    # Attack Damage
@export var attack_speed = 1.0   # Attacks per second
@export var move_speed = 200     # Pixels per second
@export var rotation_speed = 5.0 # How fast the drone rotates to face target
@export var attack_range = 50    # How close the drone needs to be to attack
@export var return_threshold = 5 # How close to rest position is considered "arrived"

enum State { IDLE, PURSUING, ATTACKING, RETURNING }

var state: State = State.IDLE
var current_target = null
var velocity = Vector2.ZERO
var rest_position = null
var explodeBuff = false
var isCrawlerBuffed = false
var base_attack_damage: int
var is_in_combat = false 
var current_zombie_to_fight

@onready var animatedSpriteComp = $AnimatedSprite2D  # RefCounted to Sprite2D Comp 



func _ready():
	base_attack_damage = attack_damage
	animatedSpriteComp.animation = "idle"
	
	
	# Create & configure attack timer
	var timer = Timer.new()
	add_child(timer)
	var attack_length = animatedSpriteComp.get_animation_length("attack")
	#print("Attack animation is ", attack_length, " seconds long")
	timer.wait_time = attack_length
	timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	timer.start()
	#print_scene_tree()
	
	
func make_drone_glow():
	animatedSpriteComp.make_glow()
	
	
func doubleDamage():
	attack_damage = base_attack_damage * 2
	animatedSpriteComp.buff()

func regularDamage():
	attack_damage = base_attack_damage
	animatedSpriteComp.debuff()
	
# Activates the drone explosion buff
func makeExplode():
	explodeBuff = true

func makeNotExplode():
	explodeBuff = false


func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)
		
		


# Handles the drone taking damage
func take_damage(amount):
	health -= amount
	if health <= 0:
		print("Die Cos Health too Low")
		die()

func get_health():
	return health

func increase_health(added_health_amount):
	if max_health != null:
		health = clamp(health + added_health_amount, 0, max_health)
		
# Changes the drone's current animation 
func setAnimation(newAnimation):
	animatedSpriteComp.animation = newAnimation

func set_damage(new_damage):
	attack_damage = new_damage



func die():
	emit_signal("drone_died", self)
	queue_free()

func enable_hurtbox():
	$HurtBox.disabled = false
# Attacks a given enemy without buffs 
func attack_target(enemy):
	$HurtBox.disabled = false
	current_target = enemy
	if explodeBuff:
		enemy.fightDroneExplode()
	if isCrawlerBuffed:
		enemy.make_spawn_slow_on_death()
	state = State.PURSUING

# Sends the drone back to it's original resting position 
func return_to_position(pos):
	rest_position = pos
	current_target = null
	state = State.RETURNING
	exit_combat()


func _physics_process(delta):
	match state:
		State.PURSUING:
			
			if not current_target or not is_instance_valid(current_target):
				state = State.RETURNING
				velocity = Vector2.ZERO
				return
			var direction = current_target.global_position - global_position
			
			var distance = direction.length()
			if distance > attack_range:
				velocity = direction.normalized() * move_speed
				position += velocity * delta
			else:
				if direction.x < 0:
					print(self.get_name(), " Drone is behind enemy , ", current_target)
					state = State.PURSUING
					self.global_position = self.global_position + Vector2(-32,0)
				else:
					velocity = Vector2.ZERO
					state = State.ATTACKING

		State.ATTACKING:
			if not current_target or not is_instance_valid(current_target):
				state = State.RETURNING
				velocity = Vector2.ZERO
				return
			var distance = global_position.distance_to(current_target.global_position)
			if distance > attack_range:
				state = State.PURSUING

		State.RETURNING:
			#if not rest_position:
				#state = State.IDLE
				#return
			var direction = rest_position - position
			var distance = direction.length()
			if distance > return_threshold:
				velocity = direction.normalized() * move_speed
				position += velocity * delta
			else:
				position = rest_position
				velocity = Vector2.ZERO
				state = State.IDLE

		State.IDLE:
			velocity = Vector2.ZERO

# Handles the drone dealing attack damage 
func _on_attack_timer_timeout():
	if state == State.ATTACKING and current_target and is_instance_valid(current_target):
		animatedSpriteComp.animation = "attack"
		var distance = global_position.distance_to(current_target.global_position)
		if distance <= attack_range:
			current_target.getCompManager().take_damage(attack_damage)


func get_is_in_combat():
	return is_in_combat

func enter_combat(zombie):
	current_zombie_to_fight = zombie
	is_in_combat = true 
		
func exit_combat():
	is_in_combat = false
	current_zombie_to_fight = null
	
func get_enemy_combatant():
	return current_zombie_to_fight
	
	
