extends RefCounted

class_name ZombieSpeedRefCountedComponent

#@onready var zombie := get_parent()
var parent_zombie : Zombie
var speed: float
var originalSpeed: float
var is_slow : bool = false 
var is_blood_slow : bool = false
var slow_duration : float = 4.0
var original_slow_duration : float = 4.0
var min_base_speed_modulate : float = 0.0
var max_base_speed_modulate : float = 2.0
var min_slow_adjust_modulate : float = 0.0
var max_slow_adjust_modulate : float = 0.03
var current_slow_walking_speed_percent : float = 0.0
var blood_slow_percent : float = 1.0
var default_slow_walking_speed_percent : float = 0.6

#Could Pass Slow duration here or get it from the parent zombie when being slowed
func _init(new_parent_zombie:Area2D) -> void:
	parent_zombie = new_parent_zombie
	speed = parent_zombie.speed #+ randf_range(-max_base_speed_modulate, max_base_speed_modulate)
	slow_duration = parent_zombie.debuff_duration
	originalSpeed = speed
	#set_process(false)

func tick(delta: float) -> void:
	parent_zombie.position.x -= speed * delta
	if speed > 0:
		if is_blood_slow:
			# Holds the rain's slow even if something reset the speed meanwhile
			# (e.g. a Buffer unfreezing the zombie).
			speed = minf(speed, originalSpeed * blood_slow_percent)
		elif !is_slow:
			speed = originalSpeed
	#if is_slow:
		#slow_duration -= delta 
		#if slow_duration <= 0:
			#slow_duration = original_slow_duration
			#speed = originalSpeed
			#is_slow = false
		
func increase_speed(increase_speed_percentage : float)->void:
	speed = speed + (speed * increase_speed_percentage)
	originalSpeed = originalSpeed + (originalSpeed * increase_speed_percentage)
	

func setSpeed(newSpeed: float) -> void:
	speed = newSpeed


func freeze() -> void:
	speed = 0


func getOriginalSpeed() -> float:
	return originalSpeed



func slow(slow_percent : float = default_slow_walking_speed_percent,is_blood_slowed : bool = false) -> void:
	if originalSpeed * slow_percent < speed:
		speed = originalSpeed * slow_percent
	# The blood flag belongs to Blood Rain only. Setting it on ordinary slows kept
	# tick() from ever restoring full speed after the slow wore off.
	if is_blood_slowed:
		is_blood_slow = true
		blood_slow_percent = slow_percent
	else:
		is_slow = true 
		current_slow_walking_speed_percent = slow_percent

func undo_blood_slow()->void:
	is_blood_slow = false
	if is_slow:
		speed = originalSpeed * current_slow_walking_speed_percent
		
	


func _on_endSpeedDebuff_timeout() -> void:
	speed = originalSpeed
