extends Node2D
#SpeedComponent.gd

#Onready variables to store zombie & attack comp
@onready var zombie = 	get_parent()
@onready var attackComp = $"../AttackComponent"
@onready var animatedSprite = $"../AnimatedSprite2D"

#Adjustable movement speed
@export var speed = 20 #40 #26 #30 # Movement speed, was 34  #37

# Store the original speed and whether or not the zombie is attacking
var originalSpeed
var is_attacking
var slow_timer: Timer = null

# Set the original speed immidiately
func _ready():
	originalSpeed = speed

#Setter for Speed
func setSpeed(newSpeed):
	speed = newSpeed
	
#Getter for speed
func getOriginalSpeed():
	return originalSpeed

#Handles moving the zombie unless it's attacking 
func _process(delta):
	if attackComp != null && animatedSprite.isDead == false:
		is_attacking = attackComp.getAttackState()
		if not is_attacking:
			# Only move if not attacking 
			zombie.position.x -= speed * delta  # Move left across the screen

#Applies slow debuff to zombie
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

#Reset speed to original when debuff expires		
func _on_endSpeedDebuff_timeout():
	speed = originalSpeed
	
	
	
	
	
