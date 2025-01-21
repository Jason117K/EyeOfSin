extends Node2D


onready var zombie = 	get_parent()
onready var attackComp = $"../AttackComponent"

var originalSpeed 
export var speed = 26 #40 #26 #30 # Movement speed, was 34
var is_attacking


func _ready():
	originalSpeed = speed

func setSpeed(newSpeed):
	speed = newSpeed
	
func getOriginalSpeed():
	return originalSpeed

func _process(delta):
	is_attacking = attackComp.getAttackState()
	if not is_attacking:
		# Only move if not attacking 
		zombie.position.x -= speed * delta  # Move left across the screen

func slow():
#	print("Speed Was : " , speed)
	if speed >= originalSpeed:
		speed = speed / 2
		#print("Speed IS : " , speed)
		var endSpeedDebuff = Timer.new()
		# Configure the timer
		endSpeedDebuff.one_shot = true  # Timer will run only once
		endSpeedDebuff.wait_time = 5.0  # Set timer for 5 seconds
	
		# Add timer as a child of the current node
		add_child(endSpeedDebuff)
	
		# Connect timer's timeout signal to the _on_timer_timeout method
		# The 'assert' ensures the connection was successful
		assert(endSpeedDebuff.connect("timeout", self, "_on_endSpeedDebuff_timeout") == OK)
		# Start the timer
		endSpeedDebuff.start()
		
func _on_endSpeedDebuff_timeout():
	speed = originalSpeed
	
	
	
	
	

