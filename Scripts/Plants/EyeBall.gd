extends Sprite

export(bool) var Continuous = true
export(float) var Turn_Radius = 10.0
export(float) var Turn_Speed = 100.0

var current_angle = 0.0
var rotating_right = true
var initial_rotation = 0.0

func _ready():
	initial_rotation = rotation_degrees
	
func _process(delta):
	if Continuous:
		# Simple continuous rotation
		rotation_degrees += Turn_Speed * delta
		
		# Keep rotation between 0 and 360 degrees
		if rotation_degrees >= 360:
			rotation_degrees -= 360
	else:
		# Back and forth rotation
		if rotating_right:
			current_angle += Turn_Speed * delta
			if current_angle >= Turn_Radius:
				rotating_right = false
				current_angle = Turn_Radius
		else:
			current_angle -= Turn_Speed * delta
			if current_angle <= -Turn_Radius:
				rotating_right = true
				current_angle = -Turn_Radius
		
		# Apply the rotation relative to the initial rotation
		rotation_degrees = initial_rotation + current_angle
