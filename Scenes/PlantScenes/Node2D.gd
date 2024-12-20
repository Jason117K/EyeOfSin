extends Node2D

# Configuration
export var point_count := 20  # Number of points of articulation
export var rope_length := 100.0  # Total desired length in pixels
export var gravity := Vector2(0, 98)
export var damping := 0.98

# Movement parameters
export var wriggle_speed := 2.0
export var wriggle_amount := 10.0
export var phase_offset := PI / 2

export var direction_bias := 0.0  # -1 to 1, biases movement direction

# Visual parameters
export var line_width := 2.0
export var start_color := Color(1.0, 0.0, 0.0)
export var end_color := Color(0.5, 0.0, 0.0)
export var use_gradient := true
export var enable_pulse := false
export var pulse_speed := 1.0
export var pulse_intensity := 0.2

var points := []
var constrain_distance: float  # Calculated based on length and points
var time := 0.0

onready var line := $Line2D

class Point:
	var current: Vector2
	var old: Vector2
	var base_offset: Vector2  # Base position for wriggle calculation
	
	func _init(pos: Vector2):
		current = pos
		old = pos
		base_offset = pos

func _ready() -> void:
	# Calculate distance between points based on desired length
	constrain_distance = rope_length / (point_count - 1)
	
	# Initialize points along the rope length
	for i in point_count:
		var point = Point.new(Vector2(i * constrain_distance, 0))
		points.append(point)
	
	# Set up line visual properties
	setup_line_visuals()

func setup_line_visuals() -> void:
	line.width = line_width
	
	if use_gradient:
		var gradient = Gradient.new()
		gradient.add_point(0.0, start_color)
		gradient.add_point(1.0, end_color)
		line.gradient = gradient
	else:
		line.default_color = start_color

func _physics_process(delta: float) -> void:
	time += delta
	
	# Update physics
	verlet_integrate(delta)
	apply_constraints()
	apply_wriggle(delta)
	
	# Update visual effects
	if enable_pulse:
		update_pulse(delta)
	
	# Update line visualization
	update_line()

func verlet_integrate(delta: float) -> void:
	for i in range(1, points.size()):
		var point = points[i]
		var velocity = (point.current - point.old) * damping
		point.old = point.current
		point.current += velocity + gravity * delta * delta

func apply_constraints() -> void:
	# Pin first point
	points[0].current = Vector2.ZERO
	points[0].old = Vector2.ZERO
	
	# Apply distance constraints between points
	for iteration in 2:  # Multiple iterations for stability
		for i in range(points.size() - 1):
			var point_a = points[i]
			var point_b = points[i + 1]
			
			var dist = point_a.current.distance_to(point_b.current)
			var diff = constrain_distance - dist
			var percent = diff / dist if dist > 0 else 0
			var offset = (point_b.current - point_a.current) * percent
			
			if i > 0:
				point_a.current -= offset * 0.5
				point_b.current += offset * 0.5
			else:
				point_b.current += offset

func apply_wriggle(delta: float) -> void:
	for i in range(1, points.size()):
		var factor = float(i) / points.size()
		var angle = time * wriggle_speed + factor * phase_offset
		
		# Add directional bias to the wriggle
		var horizontal_bias = direction_bias * wriggle_amount * factor
		
		# Reduced vertical movement and added dampening along length
		var vertical_scale = 0.3  # Reduces vertical movement
		var length_dampening = 1.0 - (factor * 0.5)  # Reduces movement toward tip
		
		var offset = Vector2(
			sin(angle) * wriggle_amount * factor + horizontal_bias,
			cos(angle) * wriggle_amount * factor * vertical_scale
		) * length_dampening
		
		# Add constraint to limit extreme movements
		offset = offset.clamped(wriggle_amount * factor)
		points[i].current += offset * delta

func update_pulse(delta: float) -> void:
	if not use_gradient:
		return
		
	var pulse = (sin(time * pulse_speed) * 0.5 + 0.5) * pulse_intensity
	var gradient = line.gradient
	
	var pulsed_start = start_color.lightened(pulse)
	var pulsed_end = end_color.lightened(pulse)
	
	gradient.set_color(0, pulsed_start)
	gradient.set_color(1, pulsed_end)

func update_line() -> void:
	var line_points := PoolVector2Array()
	for point in points:
		line_points.append(point.current)
	line.points = line_points

# Public methods for controlling the tentacle
func set_colors(new_start_color: Color, new_end_color: Color = Color()) -> void:
	start_color = new_start_color
	if new_end_color.a > 0:
		end_color = new_end_color
	else:
		end_color = start_color.darkened(0.5)
	setup_line_visuals()

func set_pulse(enabled: bool, new_speed: float = 1.0, new_intensity: float = 0.2) -> void:
	enable_pulse = enabled
	pulse_speed = new_speed
	pulse_intensity = new_intensity
