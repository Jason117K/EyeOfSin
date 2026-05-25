extends Area2D

@export var makeGreen := false


func _ready() -> void:
	if makeGreen:
		$Swim.make_green = true
		$Swim.updateAnim()
