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

# Thickness settings
export var base_width = 6.0
export var tip_width = 2.0
export var width_pulse_speed = 1.2
export var width_pulse_amount = 0.15

# Store spawned tentacles
var tentacles = []
onready var spawnPos = $"../TentacleSpawnPoint"
onready var spawnPos2 = $"../TentacleSpawnPoint2"

func _ready():
	spawn_tentacles()

func spawn_tentacles():
	for i in range(num_tentacles):
		var tentacle = create_tentacle(i)
		tentacles.append(tentacle)
		add_child(tentacle)

func create_tentacle(index: int) -> Node2D:
	var tentacle = tentacle_scene.instance()
	tentacle.z_index = z_index - 1
	
	# Calculate spawn position in a semicircle at the base of the head
	var angle = PI + (PI * index / (num_tentacles - 1))
	var offset = Vector2(
		cos(angle) * spawn_radius,
		sin(angle) * spawn_radius
	)
	
	# Adjust base position to be closer to head
	tentacle.position = Vector2(0, (texture.get_height() / 3)-30) + offset 
	
	# Additional rotation to ensure downward direction
	tentacle.rotation = PI/2
	
	# Randomize tentacle properties
	var length = rand_range(min_length, max_length)
	tentacle.ropeLength = length
	tentacle.wriggle_speed = base_speed + rand_range(-speed_variation, speed_variation)
	tentacle.wriggle_amplitude = rand_range(5.0, 6.0) #5/6
	tentacle.phase_offset = rand_range(0, PI * 2) #PI
	
	# Configure the tentacle to grow downward
	tentacle.gravity = Vector2(0, 20)
	tentacle.direction_bias = rand_range(-0.2, 0.2)
	
	# Explicitly set up the colors
	tentacle.set_colors(start_color, end_color)
	tentacle.use_gradient = true
	tentacle.enable_pulse = false
	tentacle.pulse_speed = rand_range(0.8, 1.2)
	tentacle.pulse_intensity = rand_range(0.1, 0.3)
	
	# Configure thickness properties
	tentacle.set_width(base_width * rand_range(0.9, 1.1), tip_width * rand_range(0.9, 1.1))
	tentacle.use_width_gradient = false
	tentacle.set_width_pulse(true, width_pulse_speed * rand_range(0.9, 1.1), width_pulse_amount)
	
	# Movement properties
	tentacle.wriggle_dampening = rand_range(0.1, 0.2)
	tentacle.secondary_frequency = rand_range(1.5, 1.9)
	tentacle.dampening = 0.99 #0.95

	
	return tentacle

func _process(_delta):
	pass
