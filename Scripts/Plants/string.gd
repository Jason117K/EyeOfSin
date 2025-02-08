extends Node2D
#String.gd


signal retraction_complete

# Basic configuration parameters
export (float) var ropeLength = 30.0       # Total length of the tentacle
export (float) var constrain = 1        # Distance between each point
export (Vector2) var gravity = Vector2(0, 9.8)  # Gravity influence
export (float) var dampening = 0.9       # Movement dampening (0-1)
export (float) var grab_speed = 400.0    # Speed of grabbing attack
export (float) var retract_speed = 200.0 # Speed of retraction
export (float) var visibility_shrink_rate = 30.0  # How fast tentacle shrinks when retracting

# Thickness parameters
export (float) var base_width = 4.0      # Base thickness of the tentacle
export (float) var tip_width = 2.0       # Thickness at the tip
export (bool) var use_width_gradient = true  # Whether to gradually reduce width
export (float) var width_pulse_speed = 1.0   # Speed of width pulsing
export (float) var width_pulse_amount = 0.2  # Amount of width pulsing (0-1)
export (bool) var enable_width_pulse = false # Whether to enable width pulsing

# Wriggle motion parameters
export (float) var wriggle_amplitude = 3.0  # How far points can move from rest position
export (float) var wriggle_speed = 2.0       # Base speed of wriggle motion
export (float) var phase_offset = 0.5        # Offset between horizontal and vertical motion
export (float) var wriggle_dampening = 0.7   # How much movement decreases along length
export (float) var direction_bias = 0.0      # Tendency to move in a direction (-1 to 1)
export (float) var secondary_frequency = 1.5  # Frequency of secondary motion
export (float) var speed_variation = 0.2     # Random speed variation per tentacle

# Color parameters
export (Color) var start_color = Color(1.0, 0.0, 0.0, 1.0)  # Start color (default red)
export (Color) var end_color = Color(0.5, 0.0, 0.0, 1.0)    # End color (default dark red)
export (bool) var use_gradient = false    # Whether to use gradient or solid color
export (float) var pulse_speed = 1.0     # Speed of color pulsing
export (bool) var enable_pulse = false   # Whether to enable color pulsing
export (float) var pulse_intensity = 0.2 # Intensity of color pulse (0-1)

# Node references
onready var line2D := $Line2D
var enemy = null  # Reference to current target

# State management
enum State {IDLE_WRIGGLE, EXTENDING, ATTACHED, RETRACTING}
var current_state = State.IDLE_WRIGGLE
var initial_position: Vector2    # Starting position
var anchor_position: Vector2     # Fixed point where tentacle connects
var target_position: Vector2     # Target position for grabbing
var visible_points = 0           # Number of visible points
var time_elapsed = 0.0          # Time tracker for animations
var unique_offset: float        # Unique offset for this tentacle's motion
var speed_modifier: float       # Unique speed modifier for this tentacle

# Core tentacle data
var pos: PoolVector2Array         # Current positions of points
var posPrev: PoolVector2Array     # Previous positions of points
var pointCount: int              # Total number of points

func _ready() -> void:
	# Initialize random elements
	randomize()
	unique_offset = rand_range(0, PI * 2)
	speed_modifier = 1.0 + rand_range(-speed_variation, speed_variation)
	
	# Initialize tentacle
	pointCount = get_pointCount(ropeLength)
	initial_position = position
	anchor_position = position
	resize_arrays()
	init_position()
	visible_points = pointCount
	
	# Set up initial color
	setup_line_color()
	
	# Add to tentacle group for easy reference
	add_to_group("tentacles")
	
	# Initialize line width
	update_width_profile()

func get_pointCount(distance: float) -> int:
	return int(ceil(distance / constrain))

func resize_arrays() -> void:
	pos.resize(pointCount)
	posPrev.resize(pointCount)

func init_position() -> void:
	var start_pos = to_global(anchor_position)
	for i in range(pointCount):
		pos[i] = start_pos + Vector2(constrain * i , 0)     #constrain
		posPrev[i] = start_pos + Vector2(constrain * i , 0 ) #constrain

func setup_line_color() -> void:
	if not line2D:
		push_error("line2D not initialized!")
		return
		
	if use_gradient:
		var gradient = Gradient.new()
		#gradient.add_point(0.0, start_color)
		#gradient.add_point(1.0, end_color)
		#line2D.gradient = gradient
		
		gradient.set_offset(0, 0.0)  # First color at start (0.0)
		gradient.set_offset(1, 1.0)  # Second color at end (1.0)
	
		gradient.set_color(0, start_color)
		gradient.set_color(1, end_color)
		line2D.gradient = gradient
	else:
		if is_instance_valid(line2D):
			line2D.default_color = start_color


func update_wriggle(delta: float) -> void:
	time_elapsed += delta
	var start_pos = to_global(anchor_position)
	
	# Keep base point fixed
	pos[0] = start_pos
	posPrev[0] = start_pos
	
	# Update each point with complex wriggling motion
	for i in range(1, pointCount):
		var t = time_elapsed * wriggle_speed * speed_modifier
		var segment_factor = float(i) / pointCount
		var dampen = pow(segment_factor, wriggle_dampening)
		
		# Primary motion
		var x_offset = sin(t + segment_factor * PI + unique_offset) * wriggle_amplitude * dampen
		var y_offset = cos(t * secondary_frequency + segment_factor * PI + phase_offset + unique_offset) * wriggle_amplitude * dampen
		
		# Add directional bias
		x_offset += direction_bias * wriggle_amplitude * dampen
		
		# Add secondary motion
		x_offset += sin(t * secondary_frequency + unique_offset) * wriggle_amplitude * 0.3 * dampen
		y_offset += cos(t * 1.3 + unique_offset) * wriggle_amplitude * 0.3 * dampen
		
		var base_pos = pos[i-1] + Vector2(constrain, 3)
		var target = base_pos + Vector2(x_offset, y_offset)
		
		# Smooth movement
		pos[i] = pos[i].linear_interpolate(target, 0.2)
		posPrev[i] = pos[i] - (target - pos[i]) * 0.1

func start_grab_sequence() -> void:
	if not enemy or not is_instance_valid(enemy):
		return
		
	current_state = State.EXTENDING
	target_position = enemy.global_position
	
	# Reset positions while keeping base fixed
	var start_pos = to_global(anchor_position)
	pos[0] = start_pos
	posPrev[0] = start_pos
	for i in range(1, pointCount):
		var dir = (target_position - start_pos).normalized()
		pos[i] = start_pos + dir * (constrain * i)
		posPrev[i] = pos[i]
	visible_points = pointCount

func _process(delta) -> void:
	if not visible:
		return

	update_color(delta)
	
	match current_state:
		State.IDLE_WRIGGLE:
			update_wriggle(delta)
			if enemy and is_instance_valid(enemy):
				var distance = pos[pointCount-1].distance_to(enemy.global_position)
				if distance < 200:  # Detection range
					start_grab_sequence()
		
		State.EXTENDING:
			var tip_pos = pos[pointCount-1]
			var dir = (target_position - tip_pos).normalized()
			pos[pointCount-1] += dir * grab_speed * delta
			posPrev[pointCount-1] = pos[pointCount-1] - dir * grab_speed * delta
			if enemy and is_instance_valid(enemy):
				if tip_pos.distance_to(target_position) < 10:
					current_state = State.ATTACHED
					enemy.global_position = pos[pointCount-1]
					_start_attach_timer()
		
		State.ATTACHED:
			if is_instance_valid(enemy):
				enemy.global_position = pos[pointCount-1]
		
		State.RETRACTING:
			var start_pos = to_global(anchor_position)
			var dir = (start_pos - pos[pointCount-1]).normalized()
			pos[pointCount-1] += dir * retract_speed * delta
			if is_instance_valid(enemy):
				enemy.global_position = pos[pointCount-1]
			
			visible_points = max(2, visible_points - visibility_shrink_rate * delta)
			
			if pos[pointCount-1].distance_to(start_pos) < 10:
				current_state = State.IDLE_WRIGGLE
				emit_signal("retraction_complete")
				time_elapsed = 0.0
				init_position()

	update_points(delta)
	update_constrain()
	
	# Update visual representation
	var visible_positions = PoolVector2Array()
	for i in range(min(int(visible_points), pointCount)):
		visible_positions.push_back(to_local(pos[i]))
	line2D.points = visible_positions

func _start_attach_timer() -> void:
	var timer = Timer.new()
	timer.name = "AttachTimer"
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", self, "_on_attach_timeout")
	timer.start()

func _on_attach_timeout() -> void:
	current_state = State.RETRACTING
	visible_points = pointCount
	$AttachTimer.queue_free()

func update_points(delta) -> void:
	for i in range(1, pointCount-1):
		if current_state != State.IDLE_WRIGGLE:
			var velocity = (pos[i] - posPrev[i]) * dampening
			posPrev[i] = pos[i]
			pos[i] += velocity + (gravity * delta)

func update_constrain() -> void:
	for i in range(pointCount - 1):
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		
		if i == 0:
			pos[i+1] += vec2 * percent
		else:
			if i+1 == pointCount-1:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)

# Public methods for controlling the tentacle

#Currently, 2nd/tip color fades to white rly fast
func set_colors(new_start_color: Color, new_end_color: Color = Color()) -> void:
	start_color = new_start_color
	if new_end_color.a > 0:
		end_color = new_end_color
		print("new end color")
	else:
		end_color = start_color.darkened(0.5)
		print("darkened")
	setup_line_color()

func set_pulse(enabled: bool, new_speed: float = 1.0, new_intensity: float = 0.2) -> void:
	enable_pulse = enabled
	pulse_speed = new_speed
	pulse_intensity = new_intensity

# Update function to update tentacle width profile
func update_width_profile() -> void:
	if not line2D:
		push_error("line2D not initialized in update_width_profile!")
		return
		
	if not use_width_gradient:
		line2D.width = base_width
		return
		
	# Create width profile
	var width_points = []
	for i in range(pointCount):
		var t = float(i) / (pointCount - 1)
		var current_width = lerp(base_width, tip_width, t)
		width_points.append(current_width)
	
	var curve = create_width_curve(width_points)
	if curve and is_instance_valid(line2D):
		line2D.width_curve = curve


# Helper function to create width curve
func create_width_curve(width_points: Array) -> Curve:
	if width_points.empty():
		return null
		
	var curve = Curve.new()
	for i in range(len(width_points)):
		var t = float(i) / (len(width_points) - 1)
		if base_width > 0:  # Prevent division by zero
			curve.add_point(Vector2(t, width_points[i] / base_width))
	return curve

# Modified update_color to include width pulsing
# Modified update_color to include width pulsing with proper checks
func update_color(delta: float) -> void:
	if not line2D:
		return
		
	if not enable_pulse and not enable_width_pulse:
		return
		
	time_elapsed += delta
	
	# Color pulse code
	if enable_pulse and line2D.gradient:
		var pulse = (sin(time_elapsed * pulse_speed) * 0.5 + 0.5) * pulse_intensity
		var gradient = line2D.gradient
		var pulsed_start = start_color.lightened(pulse)
		var pulsed_end = end_color.lightened(pulse)
		gradient.set_color(0, pulsed_start)
		gradient.set_color(1, pulsed_end)
	
	# Width pulsing with proper checks
	if enable_width_pulse and is_instance_valid(line2D):
		var width_pulse = (sin(time_elapsed * width_pulse_speed) * 0.5 + 0.5) * width_pulse_amount
		if use_width_gradient:
			var width_points = []
			for i in range(pointCount):
				var t = float(i) / (pointCount - 1)
				var base = lerp(base_width, tip_width, t)
				width_points.append(base * (1.0 + width_pulse))
			var curve = create_width_curve(width_points)
			if curve:
				line2D.width_curve = curve
		else:
			line2D.width = base_width * (1.0 + width_pulse)

# Add to your existing public methods
func set_width(new_base_width: float, new_tip_width: float = -1) -> void:
	base_width = new_base_width
	tip_width = new_tip_width if new_tip_width >= 0 else new_base_width * 0.5
	update_width_profile()

func set_width_pulse(enabled: bool, speed: float = 1.0, amount: float = 0.2) -> void:
	enable_width_pulse = enabled
	width_pulse_speed = speed
	width_pulse_amount = amount
