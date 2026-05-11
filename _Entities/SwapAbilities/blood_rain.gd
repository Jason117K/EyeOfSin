extends Node

var stop_ability_timer : Timer 
var ability_duration := 3.0
var cooldown_timer : Timer
var cooldown_duration := 6.0
var is_active := false
var is_on_cooldown := false
var cooldown_elapsed = 0.0
var cooldown_fill_amount := 0.0

@onready var cooldown_length_special := cooldown_duration - 2.5
@onready var cooldown_length_normal := cooldown_duration 
@onready var cooldown_visual := $Control/CooldownVisual

const STEP := 0.1

func _ready() -> void:
	print("Swap Ability Ready")
	cooldown_visual.material.set_shader_parameter("fill_amount", 0.0)
	Global.register_swap_ability(self)
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true 
	cooldown_timer.autostart = false
	cooldown_timer.wait_time = cooldown_duration
	cooldown_timer.timeout.connect(reset_cooldown)
	add_child(cooldown_timer)
	#cooldown_timer.start()
	
func reset_cooldown():
	is_on_cooldown = false

func reset_on_game_start():
	
	cooldown_fill_amount = 0
	is_on_cooldown = true 
	cooldown_timer.start()
	
func begin():
	pass
	print("BLOOD BEGUIN")
	#Stopped too soon, longer cooldown
	if is_active:
		cooldown_duration = cooldown_length_normal
		undoBloodSlow()
		return
	
	if is_on_cooldown:
		return 
		
	is_active = true 
	cooldown_fill_amount = 0.0
	for child in get_children():
		if child.has_method("show"):
			child.show()
		
	for zombie in Global.get_all_zombies():
		if zombie != null:
			zombie.blood_slow()
		
	stop_ability_timer = Timer.new()
	stop_ability_timer.one_shot = true 
	stop_ability_timer.autostart = false
	stop_ability_timer.wait_time = ability_duration
	stop_ability_timer.timeout.connect(ability_full_duration_end)
	add_child(stop_ability_timer)
	stop_ability_timer.start()
	
	
	
func ability_full_duration_end():
	cooldown_duration = cooldown_length_special
	undoBloodSlow()
	
func undoBloodSlow():
	
	if is_active:
		for zombie in Global.get_all_zombies():
			if zombie != null:
				zombie.undoBloodSlow()
		stop()
		
func stop():
	#for child in get_children():
		#if child.has_method("hide"):
			#child.hide()
	$Raindrops.hide()
	$RainSplash.hide()
	is_active = false
	cooldown_timer.wait_time = cooldown_duration
	cooldown_timer.start()
	is_on_cooldown = true 
	cooldown_elapsed = 0.0


func append_new_zombie(new_zombie):
	if is_active == true:
		new_zombie.blood_slow()
		


func _physics_process(delta: float) -> void:
	
	if is_active == false && is_on_cooldown:
		cooldown_elapsed += delta
		cooldown_fill_amount = clampf(cooldown_elapsed / cooldown_duration, 0.0, 1.0)
		cooldown_visual.material.set_shader_parameter("fill_amount", cooldown_fill_amount)
		#print(cooldown_fill_amount , "Cooldown Duyration Is ", cooldown_duration)
	elif is_active == true:
		cooldown_fill_amount = 0.0
		cooldown_visual.material.set_shader_parameter("fill_amount", cooldown_fill_amount)
		#print("Is Active ", is_active, "Is On Cooldown ", is_on_cooldown, "Fill Amount ", cooldown_fill_amount)
			#
		#


	
	

	
	
	
	
	
	
	
	
