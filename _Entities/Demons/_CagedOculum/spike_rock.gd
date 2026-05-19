extends Area2D
var spike_damage := 20
var spike_wait_time := 5
var spike_timer : Timer
@onready var spike_rock_sprite := $AnimatedSprite2D
	
func activate():
	spike_damage = get_parent().spike_damage
	show()
	monitoring = true
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,false)
		self.set_collision_mask_value(5,true)
	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,true)
		
	spike_rock_sprite.play()
	for area in get_overlapping_areas():
		if area.is_in_group("Zombie"):
			area.take_damage(spike_damage)
	
	spike_timer = Timer.new()
	spike_timer.autostart = false
	spike_timer.one_shot = false 
	spike_timer.wait_time = spike_wait_time
	spike_timer.timeout.connect(spike_attack)
	add_child(spike_timer)
	spike_timer.start()

func spike_attack():
	spike_rock_sprite.play()
	for area in get_overlapping_areas():
		if area.is_in_group("Zombie"):
			area.take_damage(spike_damage)
	
