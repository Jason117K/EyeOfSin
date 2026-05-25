extends Node2D

@onready var zombie := get_parent()

var speed: float
var originalSpeed: float
var slow_timer: Timer = null


func _ready() -> void:
	speed = zombie.speed
	originalSpeed = speed
	set_process(false)


func setSpeed(newSpeed: float) -> void:
	speed = newSpeed


func freeze() -> void:
	speed = 0


func getOriginalSpeed() -> float:
	return originalSpeed


func tick(delta: float) -> void:
	zombie.position.x -= speed * delta


func slow() -> void:
	if speed >= originalSpeed:
		speed = speed * 0.75
		if slow_timer == null:
			slow_timer = Timer.new()
			slow_timer.one_shot = true
			slow_timer.wait_time = 4.0
			add_child(slow_timer)
			slow_timer.connect("timeout", Callable(self, "_on_endSpeedDebuff_timeout"))
		slow_timer.start()


func _on_endSpeedDebuff_timeout() -> void:
	speed = originalSpeed
