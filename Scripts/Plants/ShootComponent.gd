extends Node2D

# Configuration parameters
export (Color) var laser_color = Color(1.0, 0.0, 0.0, 1.0)  # Default red laser
export (float) var extension_speed = 1000.0  # Pixels per second
export (float) var max_length = 1000.0
export (float) var laser_width = 4.0  # Increased for visibility
export (float) var damage = 1.0
export (float) var duration = 0.5
export (bool) var auto_fire = false
export (float) var cooldown = 1.0

# Zigzag parameters
export (float) var zigzag_height = 50.0  # Height of the zigzag
export (float) var zigzag_position = 300.0  # Fixed screen position where zigzag occurs
export (float) var zigzag_width = 100.0  # Width of the zigzag section

# Node references
onready var line2D := Line2D.new()
onready var laser_area := Area2D.new()
onready var collision_shape := CollisionShape2D.new()

var current_length := 0.0
var is_firing := false
var timer := Timer.new()
var hit_enemies = {}  # Dictionary to track hit enemies
var isBuffed = false

func _ready() -> void:
	# Set up Line2D
	add_child(line2D)
	line2D.points = PoolVector2Array([Vector2.ZERO, Vector2(100, 0)])
	line2D.default_color = laser_color
	line2D.width = laser_width
	line2D.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line2D.end_cap_mode = Line2D.LINE_CAP_ROUND
	line2D.z_index = 1
	
	# Set up Area2D and CollisionShape2D
	add_child(laser_area)
	laser_area.add_child(collision_shape)
	var shape = RectangleShape2D.new()
	collision_shape.shape = shape
	
	# Set up debug marker
	var debug_marker = ColorRect.new()
	add_child(debug_marker)
	debug_marker.rect_size = Vector2(5, 5)
	debug_marker.rect_position = Vector2(-2.5, -2.5)
	debug_marker.color = Color.yellow
	
	# Set up timer
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_on_laser_timeout")
	
	if auto_fire:
		var cooldown_timer = Timer.new()
		add_child(cooldown_timer)
		cooldown_timer.wait_time = cooldown
		cooldown_timer.connect("timeout", self, "fire")
		cooldown_timer.start()

func _physics_process(delta: float) -> void:
	if is_firing:
		if current_length < max_length:
			current_length += extension_speed * delta
			current_length = min(current_length, max_length)
			_update_laser()
			_update_collision_shape()
			_check_collisions()

func fire() -> void:
	if !is_firing:
		is_firing = true
		current_length = 0.0
		hit_enemies.clear()  # Clear the hit enemies when firing a new laser
		timer.wait_time = duration
		timer.start()

func _update_laser() -> void:
	var points = PoolVector2Array()
	points.append(Vector2.ZERO)  # Starting point
		
	if isBuffed:
		if current_length <= zigzag_position:
			# Before zigzag point, just draw straight line
			points.append(Vector2(current_length, 0))
		else:
			# Add straight line up to zigzag
			points.append(Vector2(zigzag_position, 0))
		
			#Add ZigZag
			points.append(Vector2(zigzag_position + zigzag_width/4, zigzag_height))
			points.append(Vector2(zigzag_position + ((zigzag_width/4)*2), 0))
			points.append(Vector2(zigzag_position + ((zigzag_width/4)*3), zigzag_height))
			points.append(Vector2(zigzag_position + zigzag_width, 0))
		
		
		# If laser extends beyond zigzag, add final straight section
		if current_length > zigzag_position + zigzag_width:
			points.append(Vector2(current_length, 0))
	else:
		# Before zigzag point, just draw straight line
		points.append(Vector2(current_length, 0))
		
	line2D.points = points

func _update_collision_shape() -> void:
	# Update collision shape to follow the laser path
	var rect_shape = collision_shape.shape as RectangleShape2D
	rect_shape.extents = Vector2(current_length / 2, laser_width / 2)
	collision_shape.position = Vector2(current_length / 2, 0)

func _check_collisions() -> void:
	var overlapping_areas = laser_area.get_overlapping_areas()
	
	for area in overlapping_areas:
		if "Zombie" in area.name and not hit_enemies.has(area):
			hit_enemies[area] = true  # Mark this enemy as hit
			var compManager = area.getCompManager()
			compManager.take_damage(damage)

func _on_laser_timeout() -> void:
	is_firing = false
	current_length = 0.0
	hit_enemies.clear()  # Clear the hit enemies when the laser times out
	_update_laser()
	_update_collision_shape()

func set_laser_color(color: Color) -> void:
	laser_color = color
	line2D.default_color = color

func set_laser_width(width: float) -> void:
	laser_width = width
	line2D.width = width
	
func buff(bufferLocation):
	isBuffed = true
	#print(bufferLocation)
	bufferLocation = to_local(bufferLocation)
	#print(bufferLocation)
	#print("OLD ZigZag Position is ", zigzag_position)
	zigzag_position = self.position.x + (bufferLocation.x - 1200)
	#print("New ZigZag Position is ", zigzag_position)
	
	damage = damage * 1.5

func isBuffed():
	return isBuffed
	
	
	
	
	
