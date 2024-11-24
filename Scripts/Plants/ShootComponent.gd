extends Node2D

# Configuration parameters
export (Color) var laser_color = Color(1.0, 0.0, 0.0, 1.0)  # Default red laser
export (float) var extension_speed = 1000.0  # Pixels per second
export (float) var max_length = 1000.0
export (float) var laser_width = 4.0  # Increased for visibility
export (float) var damage = 10.0
export (float) var duration = 0.5
export (bool) var auto_fire = false
export (float) var cooldown = 1.0

# Node references
onready var line2D := Line2D.new()
var current_length := 0.0
var is_firing := false
var timer := Timer.new()

func _ready() -> void:
	print("LaserShootComponent initialized")
	
	# Configure Line2D with more visible parameters
	add_child(line2D)
	line2D.points = PoolVector2Array([Vector2.ZERO, Vector2(100, 0)])  # Initial size for visibility
	line2D.default_color = laser_color
	line2D.width = laser_width
	line2D.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line2D.end_cap_mode = Line2D.LINE_CAP_ROUND
	line2D.z_index = 1  # Ensure it renders above other elements
	
	# Add a visual debug marker at origin
	var debug_marker = ColorRect.new()
	add_child(debug_marker)
	debug_marker.rect_size = Vector2(5, 5)
	debug_marker.rect_position = Vector2(-2.5, -2.5)
	debug_marker.color = Color.yellow
	
	# Set up timer for duration
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_on_laser_timeout")
	
	# Set up auto-fire if enabled
	if auto_fire:
		print("Auto-fire enabled with cooldown: ", cooldown)
		var cooldown_timer = Timer.new()
		add_child(cooldown_timer)
		cooldown_timer.wait_time = cooldown
		cooldown_timer.connect("timeout", self, "fire")
		cooldown_timer.start()

func _physics_process(delta: float) -> void:
	if is_firing:
		if current_length < max_length:
			# Extend the laser
			current_length += extension_speed * delta
			current_length = min(current_length, max_length)
			_update_laser()
			_check_collisions()

func fire() -> void:
	print("Firing laser!")
	if !is_firing:
		is_firing = true
		current_length = 0.0
		timer.wait_time = duration
		timer.start()
		print("Laser fired with length: ", current_length)

func _update_laser() -> void:
	var end_point = Vector2(current_length, 0)
	line2D.points = PoolVector2Array([Vector2.ZERO, end_point])
	print("Laser updated - length: ", current_length)

func _check_collisions() -> void:
	var space_state = get_world_2d().direct_space_state
	var end_point = to_global(Vector2(current_length, 0))
	
	var result = space_state.intersect_ray(
		global_position,
		end_point,
		[get_parent()],
		2
	)
	
	if result:
		if result.collider.is_in_group("Zombie"):
			if result.collider.has_method("take_damage"):
				result.collider.take_damage(damage)
				print("Hit enemy!")

func _on_laser_timeout() -> void:
	print("Laser timeout - resetting")
	is_firing = false
	current_length = 0.0
	_update_laser()

# Setters for runtime configuration
func set_laser_color(color: Color) -> void:
	laser_color = color
	line2D.default_color = color

func set_laser_width(width: float) -> void:
	laser_width = width
	line2D.width = width

# Debug drawing to visualize component orientation and position
func _draw() -> void:
	pass
	# Draw debug cross at origin
	#draw_line(Vector2(-10, 0), Vector2(10, 0), Color.yellow, 1)
	#draw_line(Vector2(0, -10), Vector2(0, 10), Color.yellow, 1)
