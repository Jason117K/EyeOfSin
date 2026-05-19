extends Node2D

@onready var zombie = get_parent()
@onready var attackComp = $"../AttackComponent"
@onready var animatedSprite = $"../AnimatedSprite2D"

var speed : float
var originalSpeed : float
var is_attacking
var slow_timer: Timer = null


func _ready():
	speed = zombie.speed
	originalSpeed = speed
	set_process(false)


func setSpeed(newSpeed):
	speed = newSpeed


func freeze():
	speed = 0


func getOriginalSpeed():
	return originalSpeed


func tick(delta):
	if attackComp != null && animatedSprite.isDead == false:
		is_attacking = attackComp.getAttackState()
		if not is_attacking:
			zombie.position.x -= speed * delta


func slow():
	if speed >= originalSpeed:
		speed = speed * 0.75
		if slow_timer == null:
			slow_timer = Timer.new()
			slow_timer.one_shot = true
			slow_timer.wait_time = 4.0
			add_child(slow_timer)
			slow_timer.connect("timeout", Callable(self, "_on_endSpeedDebuff_timeout"))
		slow_timer.start()


func _on_endSpeedDebuff_timeout():
	speed = originalSpeed
