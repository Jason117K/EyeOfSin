class_name AIUnit extends CharacterBody2D
## Uses a NavigationAgent2D to move towards set targets


#Tier of Unit, Might Depreceate
@export var unit_tier: int
#Whether Unit Is Flying, Might Depreceate
@export var is_flying : bool = false
## The max speed for this unit
@export var max_speed : float = 200.0 #300.0
## The distance at which the unit will finish pathfinding.
@export var min_distance : float = 50
## The attack range of this unit
@export var attack_range :float = 500


#@export var debug :bool= false
@export  var debug :bool= true

#The navigiation agent for the AI Unit
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
#@onready var animation_player :AnimationPlayer = $AnimationPlayer
#Unit's default pathfinding target
var default_target: Node2D
#Speed component reference 
@onready var speed_comp := $SpeedComp

# NEW: Avoidance configuration exports
@export_group("Avoidance Settings")
@export var enable_avoidance: bool = true
@export var avoidance_radius: float = 25.0  # Adjust to enemy size
@export var avoidance_neighbor_distance: float = 100.0
@export var avoidance_max_neighbors: int = 10
@export var avoidance_time_horizon: float = 1.5

#Setup the unit's max speed and pathfinding distance, and debug
func _ready() -> void:
	nav_agent.max_speed = max_speed
	nav_agent.target_desired_distance = min_distance
	nav_agent.debug_enabled = debug
	
	# Configure avoidance
	if enable_avoidance:
		# CRITICAL: Must set avoidance_enabled FIRST
		nav_agent.avoidance_enabled = true
		
		# Then configure all properties
		nav_agent.radius = avoidance_radius
		nav_agent.neighbor_distance = avoidance_neighbor_distance
		nav_agent.max_neighbors = avoidance_max_neighbors
		nav_agent.time_horizon_agents = avoidance_time_horizon
		nav_agent.max_speed = max_speed
		
		# ✅ CRITICAL: Set layers AFTER enabling avoidance
		# Clear all layers first
		for i in range(1, 33):
			nav_agent.set_avoidance_layer_value(i, false)
			nav_agent.set_avoidance_mask_value(i, false)
		
		# Set only layer 1
		nav_agent.set_avoidance_layer_value(1, true)  # I am on layer 1
		nav_agent.set_avoidance_mask_value(1, true)   # I see layer 1
		
		# Connect signal
		if not nav_agent.velocity_computed.is_connected(_on_navigation_agent_2d_velocity_computed):
			nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
		
		# Path settings
		nav_agent.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED
		nav_agent.path_desired_distance = 10.0
		
		# ✅ DEBUG: Verify configuration
		if debug:
			print("[%s] === AVOIDANCE CONFIG ===" % name)
			print("  Enabled: %s" % nav_agent.avoidance_enabled)
			print("  Radius: %.1f" % nav_agent.radius)
			print("  Layer 1: %s" % nav_agent.get_avoidance_layer_value(1))
			print("  Mask 1: %s" % nav_agent.get_avoidance_mask_value(1))
			print("  Neighbor Dist: %.1f" % nav_agent.neighbor_distance)
			print("  Signal Connected: %s" % nav_agent.velocity_computed.is_connected(_on_navigation_agent_2d_velocity_computed))
	else:
		nav_agent.avoidance_enabled = false
	
#Set the Pathfinding Movement Target for an AI Unit
func set_movement_target(movement_target: Vector2) -> void:
	nav_agent.target_position = movement_target

#Apply KnockBack to the Speed Component 
func handle_knockback(_delta: float) -> void:
	velocity = speed_comp.calc_velocity(Vector2.ZERO)
	move_and_slide()
	
	
	
#The Code that Actually Moves NPCS 
func move_towards_target(_delta: float) -> void:
	# Check actual distance to target
	var distance_to_target = global_position.distance_to(nav_agent.target_position)
	
	#Target Position Is Reached, Only Recalc Velocity for KnockBack
	if nav_agent.is_navigation_finished() and distance_to_target <= min_distance:
		# Stop moving when reached target
		if enable_avoidance:
			# With avoidance, request zero velocity
			nav_agent.set_velocity(Vector2.ZERO)
		else:
			# Without avoidance, move directly
			velocity = speed_comp.calc_velocity(Vector2.ZERO)
			move_and_slide()
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var desired_velocity: Vector2 = direction * max_speed
	
	# Handle movement based on avoidance setting
	if enable_avoidance:
		# ✅ CRITICAL FIX: Use set_velocity() not direct assignment
		# This tells the avoidance system what velocity we WANT
		# The actual movement happens in _on_navigation_agent_2d_velocity_computed
		nav_agent.set_velocity(desired_velocity)
		# DON'T call move_and_slide() here when avoidance is enabled!
	else:
		# Without avoidance, move directly
		velocity = desired_velocity
		velocity = speed_comp.calc_velocity(velocity)
		move_and_slide()

#Recompute Velocity Before Moving Agent (Called by NavigationAgent2D when avoidance is enabled)
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	# This is the velocity AFTER avoidance calculations
	# It's already been adjusted to avoid other agents
	
	# Apply speed modifications (knockback, slowdown, etc.)
	velocity = speed_comp.calc_velocity(safe_velocity)
	
	# Now actually move the character
	move_and_slide()
	
	if debug and velocity.length() > 0:
		# Optional: Visualize the difference between desired and safe velocity
		var speed_reduction = (safe_velocity.length() / max_speed) * 100.0
		if speed_reduction < 80:  # Only print if significantly slowed
			print("[%s] Avoidance active - speed at %.0f%%" % [name, speed_reduction])

#Cap the Unit Speed
func set_max_speed(new_speed: float) -> void:
	max_speed = new_speed
	nav_agent.max_speed = max_speed
