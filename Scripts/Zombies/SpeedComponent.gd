extends Node2D
#SpeedComponent.gd

#Onready variables to store zombie & attack comp
@onready var zombie = 	get_parent()
@onready var attackComp = $"../AttackComponent"

#Adjustable movement speed
@export var speed = 26 #40 #26 #30 # Movement speed, was 34

# Store the original speed and whether or not the zombie is attacking
var originalSpeed 
var is_attacking

# Set the original speed immidiately
func _ready():
	if zombie.get_name() == "DancerZombie":
		print("THE DANCER POS IS ", zombie.position)
	originalSpeed = speed

#Setter for Speed
func setSpeed(newSpeed):
	speed = newSpeed
	
#Getter for speed
func getOriginalSpeed():
	return originalSpeed

#Handles moving the zombie unless it's attacking 
func _process(delta):
	is_attacking = attackComp.getAttackState()
	if not is_attacking:
		# Only move if not attacking 
		zombie.position.x -= speed * delta  # Move left across the screen

#Applies slow debuff to zombie
func slow():
	if speed >= originalSpeed:
		speed = speed / 2
		var endSpeedDebuff = Timer.new()
		# Configure the timer
		endSpeedDebuff.one_shot = true  # Timer will run only once
		endSpeedDebuff.wait_time = 5.0  # Set timer for 5 seconds
	
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
	
	
	
	
	
