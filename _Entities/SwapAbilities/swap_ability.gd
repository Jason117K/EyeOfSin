class_name SwapAbility extends Node

@export var ability_duration := 3.0
@export var cooldown_duration := 6.0
# is_active / is_on_cooldown ARE the state machine (READY = neither) — they
# stay public, subclasses read them. Timing is accumulator-driven like
# syn_ability.gd: no Timer nodes, _physics_process decrements the counters.
var is_active := false
var is_on_cooldown := false
var cooldown_fill_amount := 0.0
var on_purple := true
var affected_zombies : Array = []
var is_locked := false

# Seconds left in the current ACTIVE / COOLDOWN state. The cooldown only
# counts down once game_start() releases it (the old Timer wasn't started
# until then either).
var _active_left := 0.0
var _cooldown_left := 0.0
var _cooldown_running := false

#Reduced Cooldown If Full Ability Transpires
@onready var cooldown_length_special := cooldown_duration - 2.5
@onready var cooldown_length_normal := cooldown_duration
@onready var cooldown_controller := $Control
@onready var cooldown_visual := $Control/SwapAbilityCooldownPanel
@onready var swap_cooldown_visual_bar := $Control/SwapAbilityCooldownPanel/MarginContainer/SwapAbilityProgressBar

var cooldown_glow := false 

func _ready() -> void:
	print("Swap Ability Ready")
	Global.register_swap_ability_instance(self)

func game_start()->void:
	print("Game Start For Swap Ability Called")
	_cooldown_left = cooldown_duration
	_cooldown_running = true

func hide_swap()->void:
	cooldown_controller.hide()

func hide_swap_alt()->void:
	cooldown_controller.modulate = Color(1,1,1,0)
	
func show_swap()->void:
	cooldown_controller.show()
	
	
func _input(event:InputEvent) -> void:
	if event.is_action_pressed("LockSwapAbility"):
		cooldown_controller.lock_unlock_swap_ability()
		lock_unlock_swap_ability()
		
func lock_unlock_swap_ability()->void:
	if is_locked:
		is_locked = false
		print("Swap Is Not Locked")
	else:
		is_locked = true
		print("Swap Is Locked")
		
func get_panel_container()->PanelContainer:
	return cooldown_controller.get_panel_container()

func reset_cooldown() -> void:
	print("Set Is On Cooldown to Faklse")
	is_on_cooldown = false
	_cooldown_running = false
	cooldown_fill_amount = 100.0

func reset_on_game_start() -> void:
	print("Set Is On Cooldown to True")
	cooldown_fill_amount = 0
	is_on_cooldown = true
	# Parked until game_start() releases the countdown.
	_cooldown_left = cooldown_duration
	_cooldown_running = false

func begin() -> void:
	if is_locked:
		return
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

	_active_left = ability_duration
	
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
	print("Set Is On Cooldown to Trueee")
	is_on_cooldown = true
	# cooldown_duration is normal or special depending on how we got here
	# (early cancel vs full duration) — set by begin()/ability_full_duration_end.
	_cooldown_left = cooldown_duration
	_cooldown_running = true
	cooldown_fill_amount = 0.0


func append_new_zombie(new_zombie : Zombie) -> void:
	pass
		


func _physics_process(delta: float) -> void:
	# Accumulator clock (replaces the old Timer nodes). Runs whenever the tree
	# runs, like the Timers did; only the BAR is gated on gameIsStarted below.
	if is_active:
		_active_left -= delta
		if _active_left <= 0.0:
			ability_full_duration_end()
	elif is_on_cooldown && _cooldown_running:
		_cooldown_left -= delta
		if _cooldown_left <= 0.0:
			reset_cooldown()

	if Global.gameIsStarted:
		if is_active == false && is_on_cooldown:
			cooldown_fill_amount = clampf((1.0 - _cooldown_left / cooldown_duration) * 100, 0.0, 100.0)
		elif is_active == true:
			cooldown_fill_amount = 0.0
		swap_cooldown_visual_bar.value = cooldown_fill_amount
		
		if swap_cooldown_visual_bar.value >= 100:
			if !is_locked:
				cooldown_glow = true 
				UiFx.add_pulsing_button_highlight(swap_cooldown_visual_bar)
			else:
				cooldown_glow = false
				UiFx.remove_pulsing_button_highlight(swap_cooldown_visual_bar)
		else:
			cooldown_glow = false
			UiFx.remove_pulsing_button_highlight(swap_cooldown_visual_bar)
	
	
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
	
	
	
	
	
	
	
	
