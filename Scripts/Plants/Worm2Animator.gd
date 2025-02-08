extends Node2D
#Worm2Animator.gd

# Animation parameters
export var bob_speed = 2.0  # Speed of the up/down motion
export var bob_height = 30.0  # How far the worm moves up/down
export var squash_amount = 0.3  # How much the worm squashes (0-1)
export var stretch_amount = 0.3  # How much the worm stretches (0-1)
export var bounce_elasticity = 0.3  # How "bouncy" the squash/stretch is (0-1)
export var animation_exaggeration = 1.0  # Overall multiplier for animation effects

# Node references
export(NodePath) var sprite_path  
onready var sprite = get_node(sprite_path) if sprite_path else null

# Internal animation state
var time = 0.0
var current_squash = 0.0
var current_stretch = 0.0
var target_squash = 0.0
var target_stretch = 0.0
var velocity = 0.0
var prev_y = 0.0
var initial_sprite_scale: Vector2
var initial_sprite_position: Vector2  # Store the initial position

#Stores initial sprite values 
func _ready():
	if sprite:
		initial_sprite_scale = sprite.scale
		initial_sprite_position = sprite.position  
	else:
		push_warning("No sprite assigned to animate!")

#Handles worm sprite bobbing 
func _process(delta):
	if not sprite:
		return
		
	time += delta * bob_speed
	
	# Calculate smooth up/down motion with slight ease-in/out
	var raw_bob = sin(time)
	var smoothed_bob = sign(raw_bob) * pow(abs(raw_bob), 0.7)
	var y_offset = smoothed_bob * bob_height * animation_exaggeration
	
	# Calculate velocity for squash/stretch
	var new_velocity = (y_offset - prev_y) / delta
	velocity = lerp(velocity, new_velocity, 0.5)
	prev_y = y_offset
	
	# Determine target squash/stretch based on motion
	var normalized_velocity = clamp(velocity / (bob_height * 2), -1, 1)
	
	if abs(normalized_velocity) > 0.1:
		target_stretch = normalized_velocity * stretch_amount * animation_exaggeration
		target_squash = -target_stretch * 0.5
	else:
		target_squash = abs(smoothed_bob) * squash_amount * animation_exaggeration
		target_stretch = -target_squash * 0.5
	
	# Apply bounce elasticity to squash/stretch
	current_squash = lerp(current_squash, target_squash, bounce_elasticity)
	current_stretch = lerp(current_stretch, target_stretch, bounce_elasticity)
	
	# Apply transformations to the sprite
	var scale_y = initial_sprite_scale.y * (1.0 + current_squash)
	var scale_x = initial_sprite_scale.x * (1.0 + current_stretch)
	
	# Update sprite's transform relative to its initial position
	sprite.position.x = initial_sprite_position.x
	sprite.position.y = initial_sprite_position.y + y_offset
	sprite.scale = Vector2(scale_x, scale_y)
