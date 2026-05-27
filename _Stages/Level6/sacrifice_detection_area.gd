extends Area2D

@onready var cooldown_timer := $CooldownTimer

var zombies_to_give_charge = []
var charge :float = 0
var total_charge_needed := 5.0
var off_cooldown := true

signal lightning_storm


func _ready() -> void:
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,true)
		self.set_collision_mask_value(4,false)
		self.set_collision_mask_value(5,true)
	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,true)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,true)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		zombies_to_give_charge.append(area)
		area.zombie_death.connect(add_charge)
		


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		zombies_to_give_charge.erase(area)
		area.zombie_death.disconnect(add_charge)


func add_charge()->void:
	charge = charge + 1
	print("Add Charge, Charge Is ", charge)
	if charge >= total_charge_needed && off_cooldown:
		print("Emit Lightning Strike")
		lightning_storm.emit()
		charge = 0
		off_cooldown = false
		#cooldown_timer.start()
		
		
	


func _on_cooldown_timer_timeout() -> void:
	off_cooldown = true 
