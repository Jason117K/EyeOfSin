class_name UnitState extends State
# Unit_State.gd
# Base class for the states of A.I. units
# A.I. is relatively simple, just needs to chase and attack

# Declare states & make sure parent is the correct type 
const STEER := "Steer"
const CHASE := "Chase"
const ATTACK := "Attack"

var parent: AIUnit

# Ensure parent is correct type 
func _ready() -> void:
	await owner.ready
	#parent = owner as AIUnit
	#assert(parent != null, "A UnitState type must be attached to an AIUnit scene,
			#is attached to " + owner.name + " on " + self.name)
			
