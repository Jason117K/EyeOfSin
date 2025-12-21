class_name StateMachine extends Node2D

@export var initial_state: State = null

#parent =  owner as AIUnit in unit_state.gd 

#Returns the Initial State, unless null, then returns the first child as a state
@onready var state: State = (func() -> State:
	return initial_state if initial_state != null else get_child(0) as State).call()
	
func _ready() -> void:
	await owner.ready
	#Connect All State Childrenm
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
	state.enter("")

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)
	
func _physics_process(delta: float) -> void:
	state.physics_update(delta)

# Transition to the a given state with a dictionary of necessary data to pass on
func _transition_to_next_state(target_state: String, data: Dictionary = {}) -> void:
	if !has_node(target_state):
		printerr(owner.name + ": Trying to transition to state "
				+ target_state + " that does not exist")
		return
		
	var next_state := get_node(target_state) as State
	if next_state == null:
		printerr(owner.name + ": Trying to transition to state "
				+ target_state + " but is not a state")
		return
	
	if !next_state.can_enter:
		return
		
	var previous_state := state.name
	state.exit()
	state = next_state
	state.enter(previous_state, data)
