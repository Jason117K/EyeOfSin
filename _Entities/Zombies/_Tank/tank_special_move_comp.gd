extends Node2D

@onready var tank_minion_scene 

var is_silenced := false 



func silence() -> void:
	is_silenced = true
	
	
func executeMove()->void:
	pass
