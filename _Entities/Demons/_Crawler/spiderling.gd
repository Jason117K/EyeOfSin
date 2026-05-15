extends Area2D

@export var attack_timer_wait_time := 4
@export var spiderling_damage := 10
var attack_timer : Timer

var speed = 60
var canMove = true 
var zombies = []
var current_zombie : Zombie = null
var health = 100


func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.one_shot = false
	attack_timer.wait_time = attack_timer_wait_time
	attack_timer.timeout.connect(attack_zombie)
	attack_timer.autostart = false
	add_child(attack_timer)
	
	if self.is_in_group("Green"):
		print("THIS SPIDERLING IS GREEN")
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_mask_value(4,false)
		set_collision_mask_value(5,true)
		
		set_collision_layer_value(1,false)
		set_collision_layer_value(2,false)
		set_collision_layer_value(3,true)
	else:
		print("THIS SPIDERLING IS PURPLE")
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_mask_value(4,true)
		
		set_collision_layer_value(1,false)
		set_collision_layer_value(2,true)
		set_collision_layer_value(3,false)



		
		
func attack_zombie():
	if current_zombie != null:
		current_zombie.getCompManager().take_damage(spiderling_damage)
	
func _physics_process(delta: float) -> void:
	if current_zombie == null:
		canMove = true
	if canMove:
		position.x += speed * delta  # Move right across the screen
	
	
func _on_area_entered(area: Area2D) -> void:
	pass
	#if area.is_in_group("Zombie"):
		#canMove = false
		#if current_zombie == null:
			#current_zombie = area
			#current_zombie.zombie_death.connect(current_zombie_dead)
			#attack_timer.start()
			#print("Current Zombie is now ", current_zombie)
			#
func current_zombie_dead():
	print(self, " received zombie dead signal")
	attack_timer.stop()
	current_zombie = null
	canMove = true 
		
func spiderling_busy(questioning_zombie):
	if current_zombie == null:
		current_zombie = questioning_zombie
		canMove = false
		print(self, " Settiing Can Move to false because of ", questioning_zombie)
		current_zombie.zombie_death.connect(current_zombie_dead)
		attack_timer.start()
		return false 
	else:
		return true
	
	
	#if current_zombie != null:
		#if current_zombie != questioning_zombie:
			#return true
		#else:
			#return false
	#else:
		#return false
	
func _on_area_exited(area: Area2D) -> void:
	pass
	#if area.is_in_group("Zombie"):
		#if area == current_zombie:
			#current_zombie = null
			#print("Current Zombie WAS " , area, " and is now ", current_zombie)


func take_damage(amount):
	health -= amount
	if health <= 0:
		#print("Die Cos Health too Low")
		queue_free()

func get_health():
	return health
