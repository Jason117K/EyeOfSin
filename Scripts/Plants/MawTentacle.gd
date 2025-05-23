extends Node2D
#MawTentacle.gd 

# Handles individual maw tentacle behavior, controlling things like wrigggling and 
# squirming 

signal retraction_complete

# Basic configuration parameters
@export var ropeLength: float = 30.0       # Total length of the tentacle
@export var constrain: float = 1.0         # Distance between each point
@export var gravity: Vector2 = Vector2(0, 9.8)  # Gravity influence
@export var dampening: float = 0.9       # Movement dampening (0-1)
@export var grab_speed: float = 400.0    # Speed of grabbing attack
@export var retract_speed: float = 200.0 # Speed of retraction
@export var visibility_shrink_rate: float = 30.0  # How fast tentacle shrinks when retracting

# Wriggle motion parameters
@export var wriggle_amplitude: float = 3.0  # How far points can move from rest position
@export var wriggle_speed: float = 2.0       # Base speed of wriggle motion
@export var phase_offset: float = 0.5        # Offset between horizontal and vertical motion
@export var wriggle_dampening: float = 0.7   # How much movement decreases along length
@export var direction_bias: float = 0.0      # Tendency to move in a direction (-1 to 1)
@export var secondary_frequency: float = 1.5  # Frequency of secondary motion
@export var speed_variation: float = 0.2     # Random speed variation per tentacle

# Color parameters
@export var start_color: Color = Color(1.0, 0.0, 0.0, 1.0)  # Start color (default red)
@export var end_color: Color = Color(0.5, 0.0, 0.0, 1.0)    # End color (default dark red)
@export var use_gradient: bool = false    # Whether to use gradient or solid color
@export var pulse_speed: float = 1.0     # Speed of color pulsing
@export var enable_pulse: bool = false   # Whether to enable color pulsing
@export var pulse_intensity: float = 0.2 # Intensity of color pulse (0-1)

# Node references
@onready var line2D := $Line2D
var enemy = null  # RefCounted to current target

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
var pos: PackedVector2Array         # Current positions of points
var posPrev: PackedVector2Array     # Previous positions of points
var pointCount: int              # Total number of points

func _ready() -> void:
	# Initialize random elements
	randomize()
	unique_offset = randf_range(0, PI * 2)
	speed_modifier = 1.0 + randf_range(-speed_variation, speed_variation)
	
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

# Gets the amount of points for a given tentancle
func get_pointCount(distance: float) -> int:
	return int(ceil(distance / constrain))

# Resizes a tentacle 
func resize_arrays() -> void:
	pos.resize(pointCount)
	posPrev.resize(pointCount)

# Initalize tentacle positions
func init_position() -> void:
	var start_pos = to_global(anchor_position)
	for i in range(pointCount):
		pos[i] = start_pos + Vector2(constrain * i, 0)
		posPrev[i] = start_pos + Vector2(constrain * i, 0)

# Setup tentacle colors 
func setup_line_color() -> void:
	if use_gradient:
		var gradient = Gradient.new()
		gradient.add_point(0.0, start_color)
		gradient.add_point(1.0, end_color)
		line2D.gradient = gradient
	else:
		line2D.default_color = start_color
		
# Update the color for a given tentacle 
func update_color(delta: float) -> void:
	if not enable_pulse:
		return
		
	time_elapsed += delta
	var pulse = (sin(time_elapsed * pulse_speed) * 0.5 + 0.5) * pulse_intensity
	
	if use_gradient:
		var gradient = line2D.gradient
		var pulsed_start = start_color.lightened(pulse)
		var pulsed_end = end_color.lightened(pulse)
		gradient.set_color(0, pulsed_start)
		gradient.set_color(1, pulsed_end)
	else:
		line2D.default_color = start_color.lightened(pulse)

# Update the wrriggle motion for a given tentacle 
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
		
		var base_pos = pos[i-1] + Vector2(constrain, 0)
		var target = base_pos + Vector2(x_offset, y_offset)
		
		# Smooth movement
		pos[i] = pos[i].lerp(target, 0.2)
		posPrev[i] = pos[i] - (target - pos[i]) * 0.1

# Starts to grab an enemy 
func start_grab_sequence() -> void:
	#Make sure the enemy is valid 
	if not enemy or not is_instance_valid(enemy):
		return
		
	visible = true  # Ensure visibility during grab
	current_state = State.EXTENDING # Change the state 
	target_position = enemy.global_position # Assign the target pos to the enemy pos 
	
	#Make the tentacle grab the enemy 
	var start_pos = to_global(anchor_position) 
	pos[0] = start_pos
	posPrev[0] = start_pos
	for i in range(1, pointCount):
		var dir = (target_position - start_pos).normalized()
		pos[i] = start_pos + dir * (constrain * i)
		posPrev[i] = pos[i]
	visible_points = pointCount


# Handle the tentacle depending on what state it's in 
func _process(delta) -> void:
	if not visible:
		return

	update_color(delta)
	
	match current_state:
		
		# Continue wriggling and check for enemies to grab 
		State.IDLE_WRIGGLE:
			update_wriggle(delta)
			if enemy and is_instance_valid(enemy):
				var distance = pos[pointCount-1].distance_to(enemy.global_position)
				if distance < 200:  # Detection range
					start_grab_sequence()
					
		# Continuously extend tentacle to enemy 
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
		
		# Attach to enemy 
		State.ATTACHED:
			if is_instance_valid(enemy):
				enemy.global_position = pos[pointCount-1]
		
		# Retract tentacle back into maw mouth along with enemy 
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
				
				
			# Re-Initialize tentacle
				pointCount = get_pointCount(ropeLength)
				initial_position = position
				anchor_position = position
				resize_arrays()
				init_position()
				visible_points = pointCount
	
				#init_position()
				
	# Update all points and contraints 
	update_points(delta)
	update_constrain()
	
	# Update visual representation
	var visible_positions = PackedVector2Array()
	for i in range(min(int(visible_points), pointCount)):
		visible_positions.push_back(to_local(pos[i]))
	line2D.points = visible_positions

# Start a timer for the brief "attaching" period of a tentacle 
func _start_attach_timer() -> void:
	var timer = Timer.new()
	timer.name = "AttachTimer"
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_attach_timeout"))
	timer.start()

# Starts to retract tentacle 
func _on_attach_timeout() -> void:
	current_state = State.RETRACTING
	visible_points = pointCount
	$AttachTimer.queue_free()

# Updates tentacle points
func update_points(delta) -> void:
	for i in range(1, pointCount-1):
		if current_state != State.IDLE_WRIGGLE:
			var velocity = (pos[i] - posPrev[i]) * dampening
			posPrev[i] = pos[i]
			pos[i] += velocity + (gravity * delta)

# Updates tentacle constraints 
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


# Sets color for a given tentacle 
func set_colors(new_start_color: Color, new_end_color: Color = Color()) -> void:
	start_color = new_start_color
	if new_end_color.a > 0:
		end_color = new_end_color
		#print("new end color")
	else:
		end_color = start_color.darkened(0.5)
		#print("darkened")
	setup_line_color()

# Configures the color pulse for a given tentacle
func set_pulse(enabled: bool, new_speed: float = 1.0, new_intensity: float = 0.2) -> void:
	enable_pulse = enabled
	pulse_speed = new_speed
	pulse_intensity = new_intensity
