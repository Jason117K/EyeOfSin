extends Area2D

# Signals
signal drone_died(drone)

# Export variables for easy tweaking in editor
export var health = 50
export var attack_damage = 1
export var attack_speed = 1.0  # Attacks per second
export var move_speed = 150    # Pixels per second
export var rotation_speed = 5.0 # How fast the drone rotates to face target
export var attack_range = 50   # How close the drone needs to be to attack
export var return_threshold = 5 # How close to rest position is considered "arrived"

# Internal state tracking
var current_target = null
var can_attack = true
var velocity = Vector2.ZERO
var rest_position = null
var is_returning = false
var explodeBuff = false

onready var animatedSpriteComp = $AnimatedSprite

func doubleDamage():
	attack_damage = attack_damage * 5
	animatedSpriteComp.buff()

func makeExplode():
	explodeBuff = true

func _ready():
	animatedSpriteComp.animation = "idle"
	
	# Create attack timer
	var timer = Timer.new()
	add_child(timer)
	var attack_length = animatedSpriteComp.get_animation_length("attack")
	#print("Attack animation is ", attack_length, " seconds long")
	timer.wait_time = attack_length
	timer.connect("timeout", self, "_on_attack_timer_timeout")
	timer.start()

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func setAnimation(newAnimation):
	animatedSpriteComp.animation = newAnimation

func die():
	emit_signal("drone_died", self)
	if current_target and is_instance_valid(current_target):
		current_target.stopFightingDrone()
	queue_free()

func attack_target(enemy):
	#print("Drone Strike")
	current_target = enemy
	if explodeBuff:
		enemy.fightDroneExplode()
	enemy.fightDrone()
	
	is_returning = false

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

func _on_attack_timer_timeout():
	if current_target and can_attack and is_instance_valid(current_target):
		animatedSpriteComp.animation = "attack"
		#Check if in range before attacking
		var distance = global_position.distance_to(current_target.global_position)
		if distance <= attack_range:
			current_target.getCompManager().take_damage(attack_damage)
