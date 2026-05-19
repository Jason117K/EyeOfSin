extends Area2D

@export var attack_timer_wait_time := 3
@export var minion_damage := 10
@export var health = 100
var attack_timer : Timer

var speed = 60
var canMove = true 
var zombies = []
var current_zombie : Zombie = null
var is_stationary := false 


func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.one_shot = false
	attack_timer.wait_time = attack_timer_wait_time
	attack_timer.timeout.connect(attack_zombie)
	attack_timer.autostart = false
	add_child(attack_timer)
	
	if self.is_in_group("Green"):
		print(self, "THIS DEMON MINION IS GREEN")
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_mask_value(4,false)
		set_collision_mask_value(5,true)
		
		set_collision_layer_value(1,false)
		set_collision_layer_value(2,false)
		set_collision_layer_value(3,true)
	else:
		print(self, "THIS DEMON MINION IS PURPLE")
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_mask_value(4,true)
		
		set_collision_layer_value(1,false)
		set_collision_layer_value(2,true)
		set_collision_layer_value(3,false)



		
		
func attack_zombie():
	if current_zombie != null:
		current_zombie.take_damage(minion_damage)
	
func _physics_process(delta: float) -> void:
	if is_stationary:
		return 
	if current_zombie == null:
		canMove = true
	if canMove:
		position.x += speed * delta  # Move right across the screen
	
	
func current_zombie_dead():
	print(self, " received zombie dead signal")
	attack_timer.stop()
	current_zombie = null
	canMove = true 
		
func demon_minion_busy(questioning_zombie):
	if current_zombie == null:
		current_zombie = questioning_zombie
		canMove = false
		#print(self, " Setting Can 77 Move to false because of ", questioning_zombie)
		current_zombie.zombie_death.connect(current_zombie_dead)
		attack_timer.start()
		return false 
	else:
		return true
	

func take_damage(amount):
	health -= amount
	if health <= 0:
		#print("Die Cos Health too Low")
		queue_free()

func get_health():
	return health
