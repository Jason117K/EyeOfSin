extends Area2D

# Export variables for easy editing in inspector
export var target_position = Vector2() setget set_target  # Target position to move towards
export(float, 0.1, 10.0) var travel_time = 1.0 setget set_travel_time  # Time to reach target

# Internal variables
var start_position = Vector2()
var time = 0
var velocity = Vector2()
var debug_marker: Node2D

var enemiesToWeb = []

func _ready():
	start_position = position
	
	# If no target position is set, default to 200 pixels in front
	if target_position == Vector2():
		target_position = start_position + Vector2(200, 0)
	
	calculate_trajectory()
	create_debug_marker()

func die():
	var valid_enemies = []
	
	# First, filter out any invalid enemies
	for enemy in enemiesToWeb:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			if enemy.is_in_group("Zombie"):
				valid_enemies.append(enemy)
				
	for enemy in valid_enemies:
		if enemy.is_in_group("Zombie"):
			var compManager = enemy.getCompManager()
			var healthComp = compManager.getHealthComponent()
			compManager.slow()
			
	queue_free()  # Remove the projectile # Replace with function body.
		
		
func _physics_process(delta):
	time += delta
	
	if time >= travel_time:
		die()
		#queue_free()
		return
	
	# Calculate current position using quadratic bezier curve
	var t = time / travel_time
	var mid_point = calculate_mid_point()
	var p0 = start_position
	var p1 = mid_point
	var p2 = target_position
	
	# Quadratic bezier formula: B(t) = (1-t)²p0 + 2(1-t)tp1 + t²p2
	var one_minus_t = 1 - t
	position = one_minus_t * one_minus_t * p0 + \
			   2 * one_minus_t * t * p1 + \
			   t * t * p2

func calculate_trajectory():
	# Reset time when recalculating
	time = 0
	
	# Calculate arc height based on distance
	var distance = start_position.distance_to(target_position)
	var arc_height = distance * 0.3  # Arc height is 30% of distance

	# Store calculated values
	velocity = (target_position - start_position) / travel_time

func calculate_mid_point() -> Vector2:
	var mid_x = (start_position.x + target_position.x) / 2
	var mid_y = min(start_position.y, target_position.y) - \
				start_position.distance_to(target_position) * 0.3
	return Vector2(mid_x, mid_y)

func set_target(new_target: Vector2):
	target_position = new_target
	if is_inside_tree():
		calculate_trajectory()
		if debug_marker:
			debug_marker.position = target_position

func set_travel_time(new_time: float):
	travel_time = new_time
	if is_inside_tree():
		calculate_trajectory()

# Creates a visual debug marker at the target position
func create_debug_marker():
	debug_marker = DebugMarker.new()
	get_parent().add_child(debug_marker)
	debug_marker.position = target_position

# Inner class for debug marker
class DebugMarker extends Node2D:
	func _draw():
		draw_circle(Vector2.ZERO, 5, Color.blue)


func _on_WebBall_area_entered(area):
	print("The Webbed Enemy is ", area.name)
	enemiesToWeb.append(area)
	pass # Replace with function body.