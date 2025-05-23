extends Node2D
#EggWorm.gd

#Adjustable health & cost
@export var health = 100
@export var cost = 150

# Animation parameters
@export var bob_speed = 2.0  
@export var bob_height = 30.0 
@export var squash_amount = 0.3  
@export var stretch_amount = 0.3  
@export var bounce_elasticity = 0.3  
@export var animation_exaggeration = 1.0  

# Node references
@export var sprite_path: NodePath  
@onready var sprite = get_node(sprite_path) if sprite_path else null
@onready var laserShootComp = $Worm2/LaserShootComponent

#onready var animSpriteComp = $AnimatedSprite

# Internal animation state
var time = 0.0
var current_squash = 0.0
var current_stretch = 0.0
var target_squash = 0.0
var target_stretch = 0.0
var velocity = 0.0
var prev_y = 0.0
var initial_sprite_scale: Vector2
var initial_sprite_position: Vector2  

var PlantManager


func _ready():
		# Get reference to plant manager
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	#Verify sprite is set up correctly 
	if sprite:
		initial_sprite_scale = sprite.scale
		initial_sprite_position = sprite.position  # Store the initial position
	else:
		push_warning("No sprite assigned to animate!")
		
	#animSpriteComp.animation = "spawn"
		
		
# Returns the plants cost 
func get_cost():
	return cost


#Handles Eggworm Buffing 
func receiveBuff(plant):
	#Increases Speed and Range From Peashooter Buff
	if(plant.name == "Peashooter"):
		laserShootComp.extension_speed = 80000
		laserShootComp.max_length = 40000
	#Applies a different buff to the laser projectile 
	elif(plant.name == "WalnutTree"):
		if (laserShootComp.isBuffed):
			pass
		else:
			laserShootComp.buff(plant.position)
		
# Handles Receiving Damage for the EggWorm 
func take_damage(damage):
	health = health - damage
	if health <= 0:
		PlantManager.clear_space(self.global_position)
		queue_free()

# Constantly animates the two worms of the EggWorm 
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
	
# Stops Spawn Animation From Playing
#func _on_AnimatedSprite_animation_finished():
	#if animSpriteComp.animation == "spawn":
	#	animSpriteComp.animation = "idle"
