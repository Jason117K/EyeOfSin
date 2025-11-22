extends Area2D

var speed = 60
var canMove = true 
var zombies = []
var health = 100


func _physics_process(delta: float) -> void:
	if zombies.is_empty():
		canMove = true 
	if canMove:
		position.x += speed * delta  # Move right across the screen
	
	
func _on_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("Zombie"):
		canMove = false
		
		zombies.append(area)
		print("Added Zombie, array now ", zombies)
		


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		zombies.erase(area)


func take_damage(amount):
	health -= amount
	if health <= 0:
		print("Die Cos Health too Low")
		queue_free()
