extends Sprite

# Scene reference
var tentacle_scene = preload("res://Scenes/Verlet.tscn")

# Configuration
export var num_tentacles = 6
export var spawn_radius = 15.0
export var min_length = 50.0
export var max_length = 80.0
export var base_speed = 2.0
export var speed_variation = 0.3

# Visual settings
export var start_color = Color(0.8, 0.2, 0.2, 1.0)  # Blood red
export var end_color = Color(0.4, 0.0, 0.0, 1.0)    # Dark red

# Store spawned tentacles
var tentacles = []
onready var spawnPos = $"../TentacleSpawnPoint"
onready var spawnPos2 = $"../TentacleSpawnPoint2"

func _ready():
	spawn_tentacles()

func spawn_tentacles():
	# Create tentacles evenly distributed around the base of the head
	for i in range(num_tentacles):
		var tentacle = create_tentacle(i)
		tentacles.append(tentacle)
		add_child(tentacle)

func create_tentacle(index: int) -> Node2D:
	var tentacle = tentacle_scene.instance()
	tentacle.z_index = z_index - 1
	
	# Calculate spawn position in a semicircle at the base of the head
	#var angle = (2 * PI * index / num_tentacles)
	var angle = PI + (PI * index / (num_tentacles - 1))  # Distribute across bottom semicircle
	var offset = Vector2(
		cos(angle) * spawn_radius,
		sin(angle) * spawn_radius
	)
	
	# Adjust base position to be closer to head
	tentacle.position = Vector2(0, (texture.get_height() / 3)-30) + offset 
	#tentacle.position = Vector2(-75, texture.get_height() / 2) + offset
	print(tentacle.position)
	
	# Set up the tentacle's transform to point downward
#	var transform = Transform2D()
	#transform = transform.rotated(PI/2)  # Rotate 90 degrees
#	tentacle.transform = transform
	
	# Additional rotation to ensure downward direction
	tentacle.rotation = PI/2  # 90 degrees in radians
	
	# Randomize tentacle properties
	var length = rand_range(min_length, max_length)
	tentacle.ropeLength = length
	tentacle.wriggle_speed = base_speed + rand_range(-speed_variation, speed_variation)
	tentacle.wriggle_amplitude = rand_range(2.0, 4.0)
	tentacle.phase_offset = rand_range(0, PI * 2)
	
	# Configure the tentacle to grow downward
	tentacle.gravity = Vector2(0, 20)  # Add downward gravity
	#tentacle.direction_bias = 1.0      # Maximum downward bias
	tentacle.direction_bias = rand_range(-0.2, 0.2)
	
	# Configure visual properties
	tentacle.start_color = start_color
	tentacle.end_color = end_color
	tentacle.use_gradient = true
	tentacle.enable_pulse = true
	tentacle.pulse_speed = rand_range(0.8, 1.2)
	tentacle.pulse_intensity = rand_range(0.1, 0.3)
	
	# Add some randomization to movement while maintaining downward direction
	tentacle.wriggle_dampening = rand_range(0.6, 0.8)
	tentacle.secondary_frequency = rand_range(1.3, 1.7)
	tentacle.dampening = 0.95  # Increase dampening to reduce horizontal movement
	
	return tentacle

func _process(_delta):
	# Optional: Add any dynamic behavior here
	pass
