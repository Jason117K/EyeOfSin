extends AnimatedSprite2D
# Swim.gd

# Handles fish movement 

#Adjustblae movement parameters 
@export var minSpeed: float = 9
@export var maxSpeed: float = 20
@export var minSpeedAnim: float = 1
@export var maxSpeedAnim: float = 2
@export var minAmount: float = 7.0
@export var maxAmount: float = 150.0

#variables to store amount moved and initial position 
var moveAmount: float
var distanceMoved: float = 0.0
var startPosition: Vector2
var speed : float

func _ready():
	# Create random number generator
	randomize()
	
	# 50% chance to flip horizontally
	flip_h = randf() > 0.5
	
	# Set random movement amount and store start position
	moveAmount = randf_range(minAmount, maxAmount)
	print("MM Move Amount is ", moveAmount)
	startPosition = position
	
	#Init speed
	speed = randf_range(minSpeed,maxSpeed)
	# Only play if minSpeed is greater than 0
	if minSpeed > 0:
		# Set random speed between min and max
		speed_scale = randf_range(minSpeedAnim, maxSpeedAnim)
		play()
	else:
		stop()

func _process(delta):
	# Calculate movement for this frame
	var movement = speed * delta
	
	# Move sprite based on flip direction
	if flip_h:
		position.x -= movement
		distanceMoved -= movement
	else:
		position.x += movement
		distanceMoved += movement
	
	# Check if we've moved the full moveAmount in either direction
	if abs(distanceMoved) >= moveAmount:
		# Turn around
		flip_h = !flip_h
		# Reset distance tracking
		distanceMoved = 0
