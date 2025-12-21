# Chase.gd - With Line of Sight and active repositioning
extends UnitState

#Onready variables to store zombie & attack comp
@onready var zombie = 	get_parent().get_parent()
@onready var attackState = $"../Attack"
@onready var speedComp = $"../../SpeedComponent"
@export var movement_speed: float = 200.0
@onready var navigation_agent: NavigationAgent2D = $"../../NavigationAgent2D"
var movement_delta: float

#Adjustable movement speed
@export var speed = 20 #40 #26 #30 # Movement speed, was 34  #37

# Store the original speed and whether or not the zombie is attacking
var originalSpeed 
var is_attacking
func _ready() -> void:
	super()


func enter(_previous_state: String, _data := {}) -> void:
	print("ENTERED CHASE")
	pass

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		print("Early Nav Return here")
		return
	if navigation_agent.is_navigation_finished():
		print("Early Nav Return heeeeeeeeere")
		#return

	movement_delta = movement_speed * delta
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	print("Next Path Pos is ", next_path_position, "Global Pos is ", zombie.global_position)
	var new_velocity: Vector2 = zombie.global_position.direction_to(next_path_position) * movement_delta
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		speedComp._on_velocity_computed(new_velocity)
	
