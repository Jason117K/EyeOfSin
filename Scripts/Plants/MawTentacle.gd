extends Node2D
#MawTentacle.gd - Fixed version with proper target loss handling

signal retraction_complete

# Basic configuration parameters
@export var ropeLength: float = 30.0
@export var constrain: float = 1.0
@export var gravity: Vector2 = Vector2(0, 9.8)
@export var dampening: float = 0.9
@export var grab_speed: float = 400.0
@export var retract_speed: float = 200.0
@export var visibility_shrink_rate: float = 30.0

# Wriggle motion parameters
@export var wriggle_amplitude: float = 3.0
@export var wriggle_speed: float = 2.0
@export var phase_offset: float = 0.5
@export var wriggle_dampening: float = 0.7
@export var direction_bias: float = 0.0
@export var secondary_frequency: float = 1.5
@export var speed_variation: float = 0.2

# Color parameters
@export var start_color: Color = Color(1.0, 0.0, 0.0, 1.0)
@export var end_color: Color = Color(0.5, 0.0, 0.0, 1.0)
@export var use_gradient: bool = false
@export var pulse_speed: float = 1.0
@export var enable_pulse: bool = false
@export var pulse_intensity: float = 0.2

# DEBUG: Add debug mode
@export var debug_mode: bool = false

# Node references
@onready var line2D := $Line2D
var enemy = null

# State management
enum State {IDLE_WRIGGLE, EXTENDING, ATTACHED, RETRACTING}
var current_state = State.IDLE_WRIGGLE
var initial_position: Vector2
var anchor_position: Vector2
var target_position: Vector2
var visible_points = 0
var time_elapsed = 0.0
var unique_offset: float
var speed_modifier: float

# FIX: Add timeout tracking
var extend_timeout: float = 0.0
var max_extend_time: float = 3.0  # Maximum time to try extending before giving up

# Core tentacle data
var pos: PackedVector2Array
var posPrev: PackedVector2Array
var pointCount: int

func _ready() -> void:
	randomize()
	grab_speed = randf_range(grab_speed-50.0,grab_speed+50.0)
	unique_offset = randf_range(0, PI * 2)
	speed_modifier = 1.0 + randf_range(-speed_variation, speed_variation)
	
	pointCount = get_pointCount(ropeLength)
	initial_position = position
	anchor_position = position
	resize_arrays()
	init_position()
	visible_points = pointCount
	
	setup_line_color()
	add_to_group("tentacles")

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

func setup_line_color() -> void:
	if use_gradient:
		var gradient = Gradient.new()
		gradient.add_point(0.0, start_color)
		gradient.add_point(1.0, end_color)
		line2D.gradient = gradient
	else:
		line2D.default_color = start_color

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

func update_wriggle(delta: float) -> void:
	time_elapsed += delta
	var start_pos = to_global(anchor_position)
	
	pos[0] = start_pos
	posPrev[0] = start_pos
	
	for i in range(1, pointCount):
		var t = time_elapsed * wriggle_speed * speed_modifier
		var segment_factor = float(i) / pointCount
		var dampen = pow(segment_factor, wriggle_dampening)
		
		var x_offset = sin(t + segment_factor * PI + unique_offset) * wriggle_amplitude * dampen
		var y_offset = cos(t * secondary_frequency + segment_factor * PI + phase_offset + unique_offset) * wriggle_amplitude * dampen
		
		x_offset += direction_bias * wriggle_amplitude * dampen
		x_offset += sin(t * secondary_frequency + unique_offset) * wriggle_amplitude * 0.3 * dampen
		y_offset += cos(t * 1.3 + unique_offset) * wriggle_amplitude * 0.3 * dampen
		
		var base_pos = pos[i-1] + Vector2(constrain, 0)
		var target = base_pos + Vector2(x_offset, y_offset)
		
		pos[i] = pos[i].lerp(target, 0.2)
		posPrev[i] = pos[i] - (target - pos[i]) * 0.1

func start_grab_sequence() -> void:
	# FIX: Add validation and debug
	if debug_mode:
		print("[Tentacle] Starting grab sequence")
	
	if not enemy or not is_instance_valid(enemy):
		if debug_mode:
			print("[Tentacle] ERROR: Invalid enemy at grab start, returning to idle")
		return_to_idle()
		return
		
	visible = true
	current_state = State.EXTENDING
	target_position = enemy.global_position
	extend_timeout = 0.0  # Reset timeout
	
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
	
	# FIX: Add enemy validation at the start of each frame
	if enemy and not is_instance_valid(enemy):
		if debug_mode:
			print("[Tentacle] Enemy became invalid, returning to idle")
		enemy = null
		return_to_idle()
		return
	
	match current_state:
		State.IDLE_WRIGGLE:
			update_wriggle(delta)
			if enemy and is_instance_valid(enemy):
				var distance = pos[pointCount-1].distance_to(enemy.global_position)
				if distance < 200:
					start_grab_sequence()
					
		State.EXTENDING:
			# FIX: Track extension timeout
			extend_timeout += delta
			if extend_timeout > max_extend_time:
				if debug_mode:
					print("[Tentacle] Extension timeout reached, retracting")
				start_retraction()
				return
			
			# FIX: Validate enemy still exists
			if not enemy or not is_instance_valid(enemy):
				if debug_mode:
					print("[Tentacle] Enemy lost during extension, retracting")
				start_retraction()
				return
			
			# Update target position in case enemy moved
			target_position = enemy.global_position
			
			var tip_pos = pos[pointCount-1]
			var dir = (target_position - tip_pos).normalized()
			pos[pointCount-1] += dir * grab_speed * delta
			posPrev[pointCount-1] = pos[pointCount-1] - dir * grab_speed * delta
			
			if tip_pos.distance_to(target_position) < 10:
				current_state = State.ATTACHED
				AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.MAW_GRAB)
				print("QQ MAW GRABBED ENEMY")
				enemy.global_position = pos[pointCount-1]
				_start_attach_timer()
		
		State.ATTACHED:
			if is_instance_valid(enemy):
				enemy.global_position = pos[pointCount-1]
			else:
				# FIX: Enemy died while attached
				if debug_mode:
					print("[Tentacle] Enemy died while attached, retracting")
				start_retraction()
		
		State.RETRACTING:
			var start_pos = to_global(anchor_position)
			var dir = (start_pos - pos[pointCount-1]).normalized()
			pos[pointCount-1] += dir * retract_speed * delta
			
			# Only move enemy if it still exists
			if is_instance_valid(enemy):
				enemy.global_position = pos[pointCount-1]
			
			visible_points = max(2, visible_points - visibility_shrink_rate * delta)
			
			if pos[pointCount-1].distance_to(start_pos) < 3:
				finish_retraction()

	update_points(delta)
	update_constrain()
	
	var visible_positions = PackedVector2Array()
	for i in range(min(int(visible_points), pointCount)):
		visible_positions.push_back(to_local(pos[i]))
	line2D.points = visible_positions

# FIX: Add helper function to cleanly return to idle
func return_to_idle() -> void:
	current_state = State.IDLE_WRIGGLE
	enemy = null
	extend_timeout = 0.0
	time_elapsed = 0.0
	init_position()
	visible_points = pointCount

# FIX: Add helper function to start retraction
func start_retraction() -> void:
	current_state = State.RETRACTING
	visible_points = pointCount

# FIX: Add helper function to finish retraction
func finish_retraction() -> void:
	emit_signal("retraction_complete")
	enemy = null
	return_to_idle()

func _start_attach_timer() -> void:
	var timer = Timer.new()
	timer.name = "AttachTimer"
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_attach_timeout"))
	timer.start()

func _on_attach_timeout() -> void:
	start_retraction()
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

func set_colors(new_start_color: Color, new_end_color: Color = Color()) -> void:
	start_color = new_start_color
	if new_end_color.a > 0:
		end_color = new_end_color
	else:
		end_color = start_color.darkened(0.5)
	setup_line_color()

func set_pulse(enabled: bool, new_speed: float = 1.0, new_intensity: float = 0.2) -> void:
	enable_pulse = enabled
	pulse_speed = new_speed
	pulse_intensity = new_intensity
