extends Area2D

var silence_field_timer: Timer
@export var silence_field_visual_wait_time := 5
@onready var silence_field_1: AnimatedSprite2D = $SilenceFieldAnim
@onready var silence_field_2: AnimatedSprite2D = $SilenceFieldAnim2
@onready var silence_field_3: AnimatedSprite2D = $SilenceFieldAnim3
@onready var silence_field_4: AnimatedSprite2D = $SilenceFieldAnim4

func activate() -> void:
	silence_field_1.animation_finished.connect(func()->void: silence_field_1.hide())
	silence_field_2.animation_finished.connect(func()->void: silence_field_2.hide())
	silence_field_3.animation_finished.connect(func()->void: silence_field_3.hide())
	silence_field_4.animation_finished.connect(func()->void: silence_field_4.hide())
	
	
	show()
	monitoring = true
	if get_parent().is_in_group("Green"):
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
	area_entered.connect(func(area:Area2D)->void: 
		if area.is_in_group("Zombie"):
			print("Silence ", area)
			area.silence()
			)
	for area in get_overlapping_areas():
		if area.is_in_group("Zombie"):
			area.silence()
	silence_zombies()
	show_silence_fields()
	silence_field_timer = Timer.new()
	silence_field_timer.autostart = false
	silence_field_timer.one_shot = false
	silence_field_timer.wait_time = silence_field_visual_wait_time
	silence_field_timer.timeout.connect(show_silence_fields)
	add_child(silence_field_timer)
	silence_field_timer.start()


func show_silence_fields() -> void:
	var fields := [silence_field_1, silence_field_2, silence_field_3, silence_field_4]
	fields.shuffle()

	for i in fields.size():
		var field :Node= fields[i]
		if i == 0:
			field.show()
			field.play_backwards("default")
		else:
			var delay_timer := Timer.new()
			delay_timer.one_shot = true
			delay_timer.autostart = false
			add_child(delay_timer)
			
			var frames_per_second : float = fields[0].sprite_frames.get_animation_speed("default")
			var frame_duration : float = 1.0 / frames_per_second
			delay_timer.wait_time = frame_duration * 2 * i
			
			delay_timer.timeout.connect(func()->void:
				field.show()
				field.play_backwards("default")
				delay_timer.queue_free()
			)
			delay_timer.start()




func silence_zombies() -> void:
	print("SILENCE ZOMBIES CALLED",  get_overlapping_areas())
	for area in get_overlapping_areas():
		if area.is_in_group("Zombie"):
			print(area, " Is Silenced")
			area.silence()
