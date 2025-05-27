extends AnimatedSprite2D
# Shrub Animator.gd - Weighted Speed Randomization
# Adjustable Max & Min Speed Values for the Shrub Anim
@export var minSpeed: float = 1.0
@export var maxSpeed: float = 2.0


# Alternative: Manual weight ranges
@export_group("Weight Ranges")
@export var slow_range_min: float = 0.5
@export var slow_range_max: float = 1.0
@export var slow_weight: float = 80.0  # Percentage chance for slow range

@export var fast_range_min: float = 1.0
@export var fast_range_max: float = 1.5
@export var fast_weight: float = 20.0  # Percentage chance for fast range

# Choose randomization method
@export_enum("Power Curve", "Weighted Ranges", "Exponential Decay") var randomization_method: int = 1

func _ready():
	randomize()
	
	if minSpeed > 0:
		var final_speed: float
		
		match randomization_method:
			1: # Weighted Ranges Method
				final_speed = get_weighted_range_speed()

		speed_scale = final_speed
		play()
		print("Final Speed is : " , final_speed)
	else:
		stop()
		
	


#Weighted ranges - explicitly define speed ranges with weights
func get_weighted_range_speed() -> float:
	var total_weight = slow_weight + fast_weight
	var random_weight = randf() * total_weight
	
	if random_weight <= slow_weight:
		# Pick from slow range
		return randf_range(slow_range_min, slow_range_max)
	else:
		# Pick from fast range
		return randf_range(fast_range_min, fast_range_max)


# Debug function to test distribution (call from _ready() to see results)
func test_distribution(sample_size: int = 1000):
	var slow_count = 0
	var fast_count = 0
	
	for i in sample_size:
		var speed = get_weighted_range_speed()  # Change this to test different methods
		if speed <= 1.3:
			slow_count += 1
		else:
			fast_count += 1
	
	print("Distribution test (", sample_size, " samples):")
	print("Slow speeds (1.0-1.3): ", (slow_count * 100.0 / sample_size), "%")
	print("Fast speeds (1.4-2.0): ", (fast_count * 100.0 / sample_size), "%")
