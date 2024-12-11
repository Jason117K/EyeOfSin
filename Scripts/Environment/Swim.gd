extends AnimatedSprite

export(float) var minSpeed = 1.0
export(float) var maxSpeed = 2.0
export(float) var minAmount = 10.0
export(float) var maxAmount = 50.0

var moveAmount: float
var distanceMoved: float = 0.0
var startPosition: Vector2

func _ready():
	# Create random number generator
	randomize()
	
	# 50% chance to flip horizontally
	flip_h = randf() > 0.5
	
	# Set random movement amount and store start position
	moveAmount = rand_range(minAmount, maxAmount)
	startPosition = position
	
	# Only play if minSpeed is greater than 0
	if minSpeed > 0:
		# Set random speed between min and max
		speed_scale = rand_range(minSpeed, maxSpeed)
		playing = true
	else:
		playing = false

func _process(delta):
	# Calculate movement for this frame
	var movement = moveAmount * delta
	
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
