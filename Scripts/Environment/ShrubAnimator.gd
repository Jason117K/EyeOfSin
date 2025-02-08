extends AnimatedSprite
# Shrub Animator.gd

# Adjustable Max & Min Speed Values for the Shrub Anim
export(float) var minSpeed = 1.0
export(float) var maxSpeed = 2.0

#Randomizes the speed of the Shrub Bob Animation 
func _ready():
	# Create random number generator
	randomize()
	
	# Only play if minSpeed is greater than 0
	if minSpeed > 0:
		# Set random speed between min and max
		speed_scale = rand_range(minSpeed, maxSpeed)
		playing = true
	else:
		playing = false
