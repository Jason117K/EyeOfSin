extends Node2D

signal retraction_complete

# Configuration parameters
export (float) var ropeLength = 30
export (float) var constrain = 1
export (Vector2) var gravity = Vector2(0, 9.8)
export (float) var dampening = 0.9
export (float) var grab_speed = 400.0
export (float) var retract_speed = 200.0
export (float) var visibility_shrink_rate = 30.0

# Wriggle parameters
export (float) var wriggle_amplitude = 20.0  # How far the tip moves
export (float) var wriggle_speed = 3.0      # Speed of the wriggle motion
export (float) var phase_offset = 0.5       # Offset between horizontal and vertical motion
export (float) var wriggle_dampening = 0.7  # How much the wriggle reduces along the tentacle

# Node references
onready var line2D := $Line2D
var enemy = null

# State management
enum State {IDLE_WRIGGLE, EXTENDING, ATTACHED, RETRACTING}
var current_state = State.IDLE_WRIGGLE
var initial_position: Vector2
var anchor_position: Vector2  # Fixed point where tentacle connects to mouth
var target_position: Vector2
var visible_points = 0
var time_elapsed = 0.0

# Core tentacle data
var pos: PoolVector2Array
var posPrev: PoolVector2Array
var pointCount: int

func _ready() -> void:
	pointCount = get_pointCount(ropeLength)
	initial_position = position
	anchor_position = position  # Store the fixed point
	resize_arrays()
	init_position()
	visible_points = pointCount

func get_pointCount(distance: float) -> int:
	return int(ceil(distance / constrain))

func resize_arrays() -> void:
	pos.resize(pointCount)
	posPrev.resize(pointCount)

func init_position() -> void:
	var start_pos = to_global(anchor_position)
	for i in range(pointCount):
		pos[i] = start_pos + Vector2(constrain * i, 0)
		posPrev[i] = start_pos + Vector2(constrain * i, 0)

func start_grab_sequence() -> void:
	if not enemy or not is_instance_valid(enemy):
		return
		
	current_state = State.EXTENDING
	target_position = enemy.global_position
	# Keep the base point fixed but reset other points
	var start_pos = to_global(anchor_position)
	pos[0] = start_pos
	posPrev[0] = start_pos
	for i in range(1, pointCount):
		var dir = (target_position - start_pos).normalized()
		pos[i] = start_pos + dir * (constrain * i)
		posPrev[i] = pos[i]
	visible_points = pointCount

func update_wriggle(delta: float) -> void:
	time_elapsed += delta
	var start_pos = to_global(anchor_position)
	
	# Keep the base point fixed
	pos[0] = start_pos
	posPrev[0] = start_pos
	
	# Update each point with a sinusoidal motion
	for i in range(1, pointCount):
		var t = time_elapsed * wriggle_speed
		var segment_factor = float(i) / pointCount
		var dampen = pow(segment_factor, wriggle_dampening)
		
		# Create organic motion by combining multiple sine waves
		var x_offset = sin(t + segment_factor * PI) * wriggle_amplitude * dampen
		var y_offset = cos(t * 0.7 + segment_factor * PI + phase_offset) * wriggle_amplitude * dampen
		
		# Calculate position relative to the previous point
		var base_pos = pos[i-1] + Vector2(constrain, 0)
		var target = base_pos + Vector2(x_offset, y_offset)
		
		# Smoothly move towards the target position
		pos[i] = pos[i].linear_interpolate(target, 0.2)
		posPrev[i] = pos[i] - (target - pos[i]) * 0.1

func _process(delta) -> void:
	if not visible:
		return

	match current_state:
		State.IDLE_WRIGGLE:
			update_wriggle(delta)
			if enemy and is_instance_valid(enemy):
				# Check if enemy is in range before starting grab sequence
				var distance = pos[pointCount-1].distance_to(enemy.global_position)
				if distance < 200:  # Adjust detection range as needed
					start_grab_sequence()
		
		State.EXTENDING:
			var tip_pos = pos[pointCount-1]
			var dir = (target_position - tip_pos).normalized()
			pos[pointCount-1] += dir * grab_speed * delta
			posPrev[pointCount-1] = pos[pointCount-1] - dir * grab_speed * delta
			
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
				time_elapsed = 0.0  # Reset wriggle time
				init_position()  # Reset tentacle position

	update_points(delta)
	update_constrain()
	
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
	# Skip first point since it's fixed
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
			# First point is fixed, only move the next point
			pos[i+1] += vec2 * percent
		else:
			if i+1 == pointCount-1:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
