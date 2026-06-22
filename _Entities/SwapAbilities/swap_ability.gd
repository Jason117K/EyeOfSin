class_name SwapAbility extends Node

var stop_ability_timer: Timer
@export var ability_duration := 3.0
var cooldown_timer: Timer
@export var cooldown_duration := 6.0
var is_active := false
var is_on_cooldown := false
var cooldown_elapsed := 0.0
var cooldown_fill_amount := 0.0
var on_purple := true 
var affected_zombies : Array = []
var is_locked := false 

#Reduced Cooldown If Full Ability Transpires 
@onready var cooldown_length_special := cooldown_duration - 2.5
@onready var cooldown_length_normal := cooldown_duration
@onready var cooldown_controller := $Control
@onready var cooldown_visual := $Control/SwapAbilityCooldownPanel
@onready var swap_cooldown_visual_bar := $Control/SwapAbilityCooldownPanel/MarginContainer/SwapAbilityProgressBar
const STEP := 0.1


func _ready() -> void:
	print("Swap Ability Ready")
	#cooldown_visual.material.set_shader_parameter("fill_amount", 0.0)
	Global.register_swap_ability_instance(self)
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.autostart = false
	cooldown_timer.wait_time = cooldown_duration
	cooldown_timer.timeout.connect(reset_cooldown)
	add_child(cooldown_timer)
	#cooldown_timer.start()

func game_start()->void:
	print("Game Start For Swap Ability Called")
	cooldown_timer.start()
	
func _input(event:InputEvent) -> void:
	if event.is_action_pressed("LockSwapAbility"):
		cooldown_controller.lock_unlock_swap_ability()
		#lock_unlock_swap_ability()
		
func lock_unlock_swap_ability()->void:
	if is_locked:
		is_locked = false
	else:
		is_locked = true
	
		
func get_panel_container()->PanelContainer:
	return cooldown_controller.get_panel_container()

func reset_cooldown() -> void:
	print("Set Is On Cooldown to Faklse")
	is_on_cooldown = false

func reset_on_game_start() -> void:
	print("Set Is On Cooldown to True")
	cooldown_fill_amount = 0
	is_on_cooldown = true
	#cooldown_timer.start()

func begin() -> void:
	#if is_locked:
		#return 
	#Stopped too soon, longer cooldown
	if is_active:
		cooldown_duration = cooldown_length_normal
		undo_swap_ability()
		return
	
	if is_on_cooldown:
		return

	is_active = true
	cooldown_fill_amount = 0.0
	for child in get_children():
		if child.has_method("show") && !(child is Control): 
			child.show()
	

	apply_swap_ability()
		
	stop_ability_timer = Timer.new()
	stop_ability_timer.one_shot = true
	stop_ability_timer.autostart = false
	stop_ability_timer.wait_time = ability_duration
	stop_ability_timer.timeout.connect(ability_full_duration_end)
	add_child(stop_ability_timer)
	stop_ability_timer.start()
	
func apply_swap_ability()->void:
	pass

func ability_full_duration_end() -> void:
	cooldown_duration = cooldown_length_special
	undo_swap_ability()

func undo_swap_ability() -> void:
	pass
		
func stop() -> void:
	for child in get_children():
		if child.has_method("hide") && !(child is Control): 
			child.hide()
	is_active = false
	cooldown_timer.wait_time = cooldown_duration
	print("Game Start for swap aaa here")
	cooldown_timer.start()
	print("Set Is On Cooldown to Trueee")
	is_on_cooldown = true
	cooldown_elapsed = 0.0


func append_new_zombie(new_zombie : Zombie) -> void:
	pass
		


func _physics_process(delta: float) -> void:
	if Global.gameIsStarted:
		if is_active == false && is_on_cooldown:
			cooldown_elapsed += delta
			#cooldown_fill_amount = clampf(cooldown_elapsed / cooldown_duration, 0.0, 1.0)
			#cooldown_visual.material.set_shader_parameter("fill_amount", cooldown_fill_amount)
			
			cooldown_fill_amount = clampf((cooldown_elapsed / cooldown_duration)*100, 0.0, 100.0)
			#print(cooldown_fill_amount , "Cooldown Duyration Is ", cooldown_duration)
		elif is_active == true:
			cooldown_fill_amount = 0.0
			#cooldown_visual.material.set_shader_parameter("fill_amount", cooldown_fill_amount)
			#print("Is Active ", is_active, "Is On Cooldown ", is_on_cooldown, "Fill Amount ", cooldown_fill_amount)
				#
		swap_cooldown_visual_bar.value = cooldown_fill_amount
	
	
func set_current_visibility_layer(flag : int)->void:
	cooldown_visual = $Control/SwapAbilityCooldownPanel
	print("CoolDown VIsual is ", cooldown_visual)
	if flag == 1:
		cooldown_visual.visibility_layer = 2
	#	cooldown_visual.set_visibility_layer_bit(2, true)  
		for child in get_children(): 
			if child.has_method("hide"):
				child.visibility_layer = 0
				child.set_visibility_layer_bit(1, true)  
				on_purple = true 
	elif flag == 2:
		cooldown_visual.visibility_layer = 3
	#	cooldown_visual.set_visibility_layer_bit(2, true)  
		for child in get_children(): 
			if child.has_method("hide"):
				child.visibility_layer = 0
				child.set_visibility_layer_bit(2, true) 
				on_purple = false


func hide()->void:
	cooldown_controller.hide()
	
func show()->void:
	cooldown_controller.show()



func set_collision()->void:
	pass
	
	
	
	
	
	
	
	
