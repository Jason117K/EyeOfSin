extends Node2D

# Configuration
export var point_count := 100
export var constrain_distance := 1.0
export var gravity := Vector2(0, 98)
export var damping := 0.98

# Movement parameters
export var wriggle_speed := 2.0
export var wriggle_amount := 10.0
export var phase_offset := PI / 4

# Visual parameters
export var line_width := 2.0
export var start_color := Color(1.0, 0.0, 0.0)
export var end_color := Color(0.5, 0.0, 0.0)

var points := []
var old_points := []
var time := 0.0

onready var line :=  self

class Point:
	var current: Vector2
	var old: Vector2
	
	func _init(pos: Vector2):
		current = pos
		old = pos

func _ready() -> void:
	# Initialize points along a horizontal line
	for i in point_count:
		var point = Point.new(Vector2(i * constrain_distance, 0))
		points.append(point)
		
	# Set up line visual properties
	line.width = line_width
	line.gradient = Gradient.new()
	line.gradient.add_point(0.0, start_color)
	line.gradient.add_point(1.0, end_color)

func _physics_process(delta: float) -> void:
	time += delta
	
	# Update physics
	verlet_integrate(delta)
	apply_constraints()
	apply_wriggle(delta)
	
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
	
	# Constrain distances between points
	for i in range(points.size() - 1):
		var point_a = points[i]
		var point_b = points[i + 1]
		
		var dist = point_a.current.distance_to(point_b.current)
		var diff = constrain_distance - dist
		var percent = diff / dist
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
		var offset = Vector2(
			sin(angle) * wriggle_amount * factor,
			cos(angle) * wriggle_amount * factor
		)
		points[i].current += offset * delta

func update_line() -> void:
	var line_points := PoolVector2Array()
	for point in points:
		line_points.append(point.current)
	line.points = line_points
