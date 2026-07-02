## Player health state. UI listens to health_changed; owner reacts to depleted.
class_name PlayerHealth extends Node

signal health_changed(current : int)
signal depleted

@export var max_health : int = 1000

var current : int


func damage(amount : int = 1) -> void:
	current -= amount
	health_changed.emit(current)
	if current <= 0:
		depleted.emit()


func reset() -> void:
	current = max_health
	health_changed.emit(current)
