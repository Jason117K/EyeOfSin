extends Node2D
#SpeedComponent.gd

#Onready variables to store zombie & attack comp
@onready var zombie = 	get_parent()
@onready var attackComp = $"../AttackComponent"
@export var movement_speed: float = 20.0
@onready var navigation_agent: NavigationAgent2D = $"../NavigationAgent2D"
var movement_delta: float

#Adjustable movement speed
@export var speed = 20 #40 #26 #30 # Movement speed, was 34  #37

# Store the original speed and whether or not the zombie is attacking
var originalSpeed 
var is_attacking

# Set the original speed immidiately
func _ready():
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	#yspeed = randf_range(19,24)
	if zombie.get_name() == "DancerZombie":
		print("THE DANCER POS IS ", zombie.position)
	originalSpeed = speed
	#set_movement_target(Vector2(361.0,142))
	
func set_movement_target(movement_target: Vector2):
	#print("My Position is " , global_position, " is now set to ", movement_target)
	navigation_agent.set_target_position(movement_target)
	
#Setter for Speed
func setSpeed(newSpeed):
	speed = newSpeed
	
#Getter for speed
func getOriginalSpeed():
	return originalSpeed

#Handles moving the zombie unless it's attacking 
func _process(delta):
	if attackComp != null:
		is_attacking = attackComp.getAttackState()
		if not is_attacking:
			# Only move if not attacking 
			#TODO AIFINAL
			#zombie.position.x -= speed * delta  # Move left across the screen
			#navigation_agent
			pass
			
#func _physics_process(delta):
	## Do not query when the map has never synchronized and is empty.
	#if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		#print("Early Nav Return here")
		#return
	#if navigation_agent.is_navigation_finished():
		#print("Early Nav Return heeeeeeeeere")
		##return
	#
	#movement_delta = movement_speed * delta
	#var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	#print("Next Path Pos is ", next_path_position, "Global Pos is ", zombie.global_position)
	#var new_velocity: Vector2 = get_parent().global_position.direction_to(next_path_position) * movement_delta
	#if navigation_agent.avoidance_enabled:
		#navigation_agent.set_velocity(new_velocity)
	#else:
		#_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	#print(safe_velocity,"Global Pos WAS ", get_parent().global_position)
	pass
	if not is_attacking:
		get_parent().global_position = get_parent().global_position.move_toward(get_parent().global_position + safe_velocity, movement_delta)
		print(safe_velocity,"Global Pos IS ", get_parent().global_position)
			
#Applies slow debuff to zombie
func slow():
	if speed >= originalSpeed:
		#speed = speed / 2
		speed = speed * 0.75
		var endSpeedDebuff = Timer.new()
		# Configure the timer
		endSpeedDebuff.one_shot = true  # Timer will run only once
		endSpeedDebuff.wait_time = 4.0  # Set timer for 5 seconds
	
		# Add timer as a child of the current node
		add_child(endSpeedDebuff)
	
		# Connect timer's timeout signal to the _on_timer_timeout method
		# The 'assert' ensures the connection was successful
		assert(endSpeedDebuff.connect("timeout", Callable(self, "_on_endSpeedDebuff_timeout")) == OK)
		# Start the timer
		endSpeedDebuff.start()

#Reset speed to original when debuff expires		
func _on_endSpeedDebuff_timeout():
	speed = originalSpeed
	
	
	
	
	
