extends RefCounted

class_name ZombieSpeedRefCountedComponent

#@onready var zombie := get_parent()
var parent_zombie : Zombie
var speed: float
var originalSpeed: float
var is_slow : bool = false 
var slow_duration : float = 4.0

#Could Pass Slow duration here or get it from the parent zombie when being slowed
func _init(new_parent_zombie:Area2D) -> void:
	parent_zombie = new_parent_zombie
	speed = parent_zombie.speed
	originalSpeed = speed
	#set_process(false)

func tick(delta: float) -> void:
	parent_zombie.position.x -= speed * delta
	if is_slow:
		slow_duration -= delta 
		if slow_duration <= 0:
			speed = originalSpeed
		
		

func setSpeed(newSpeed: float) -> void:
	speed = newSpeed


func freeze() -> void:
	speed = 0


func getOriginalSpeed() -> float:
	return originalSpeed



func slow() -> void:
	if speed >= originalSpeed:
		is_slow = true 
		speed = speed * 0.75


func _on_endSpeedDebuff_timeout() -> void:
	speed = originalSpeed
