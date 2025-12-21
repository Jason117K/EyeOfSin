class_name State extends Node2D
# Base state class to be extended 

var can_enter :bool= true

# emitted when the signal is finished and wants to transition
signal finished(next_state: String, data: Dictionary)

func enter(_previous_state: String, _data := {}) -> void:
	pass
	
func handle_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
	
func exit() -> void:
	pass
