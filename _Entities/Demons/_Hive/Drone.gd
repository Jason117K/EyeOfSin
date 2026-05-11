extends Area2D
#Drone.gd

# Handles Hive Drone Behavior 


# Signals
signal drone_died(drone)

# Export variables 
@export var health = 75          # Drone Health
@export var attack_damage = 7    # Attack Damage
@export var attack_speed = 1.0   # Attacks per second
@export var move_speed = 150     # Pixels per second
@export var rotation_speed = 5.0 # How fast the drone rotates to face target
@export var attack_range = 50    # How close the drone needs to be to attack
@export var return_threshold = 5 # How close to rest position is considered "arrived"

# Internal state tracking
var current_target = null       # Holds the current drone target
var can_attack = true           # Whether or not the drone can attack
var velocity = Vector2.ZERO     # Drone Velocity 
var rest_position = null        # The Location of the Drone Resting Position   
var is_returning = false        # Whether or not the drone is returning to rest
var explodeBuff = false         # Whether or not the drone is buffed
var isSpyderBuffed = false
var base_attack_damage: int

@onready var animatedSpriteComp = $AnimatedSprite2D  # RefCounted to Sprite2D Comp 

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
	print_scene_tree()

# Handles the drone taking damage
func take_damage(amount):
	health -= amount
	if health <= 0:
		print("Die Cos Health too Low")
		die()

func get_health():
	return health

# Changes the drone's current animation 
func setAnimation(newAnimation):
	animatedSpriteComp.animation = newAnimation

# Kills drone
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
	if isSpyderBuffed:
		enemy.make_spawn_slow_on_death()
	is_returning = false

# Sends the drone back to it's original resting position 
func return_to_position(pos):
	rest_position = pos
	current_target = null
	is_returning = true


func _physics_process(delta):
	if current_target and is_instance_valid(current_target):
		# Handle combat movement
		var direction = (current_target.global_position - global_position)
		var distance = direction.length()
		direction = direction.normalized()
		
		if distance > attack_range:
			velocity = direction * move_speed
			position += velocity * delta
		else:
			velocity = Vector2.ZERO
			
	elif is_returning and rest_position:
		# Handle return movement
		var direction = (rest_position - position)
		var distance = direction.length()
		
		if distance > return_threshold:
			direction = direction.normalized()
			velocity = direction * move_speed
			position += velocity * delta
		else:
			# We've arrived at rest position
			position = rest_position  # Snap to exact position
			velocity = Vector2.ZERO
			is_returning = false
	else:
		# No target and not returning
		current_target = null
		velocity = Vector2.ZERO

# Handles the drone dealing attack damage 
func _on_attack_timer_timeout():
	if current_target and can_attack and is_instance_valid(current_target):
		animatedSpriteComp.animation = "attack"
		#Check if in range before attacking
		var distance = global_position.distance_to(current_target.global_position)
		if distance <= attack_range:
			current_target.getCompManager().take_damage(attack_damage)
