extends Node

@export var syn_ability_instance :PackedScene = preload("res://_Entities/SynAbility/syn_lightning_ability_bolt.tscn")
@export var icon_texture := preload("res://_Entities/SynAbility/SynShieldCard.png")
@export var charge_boost_multipler := 4.0

@onready var syn_ability_cooldown := $SynAbilityCooldown
@onready var syn_ability_crosshair : AnimatedSprite2D = $SynAbilityCrosshair

@onready var syn_ability_purple_cooldown_timer := $SynAbilityCooldownTimerPurple
@onready var syn_ability_green_cooldown_timer := $SynAbilityCooldownTimerGreen

var active_purple_syn_ability : Area2D
var active_green_syn_ability : Area2D

var is_purple_ability_on_cooldown := false 
var is_green_ability_on_cooldown := false 

var timer_speed_modifier := 1.0
var purple_timer_speed_multiplier := 1.0
var green_timer_speed_multiplier := 1.0

var syn_crosshair_active := false 

func _ready() -> void:
	syn_ability_cooldown.get_button().pressed.connect(set_ability_targeting_active)
	syn_ability_crosshair.hide()
	syn_ability_cooldown.set_icon(icon_texture)
	
	syn_ability_purple_cooldown_timer.autostart = false
	syn_ability_purple_cooldown_timer.one_shot = true 
	syn_ability_purple_cooldown_timer.timeout.connect(purple_off_cooldown)

	syn_ability_green_cooldown_timer.autostart = false
	syn_ability_green_cooldown_timer.one_shot = true 
	syn_ability_green_cooldown_timer.timeout.connect(green_off_cooldown)
	
func purple_off_cooldown()->void:
	is_purple_ability_on_cooldown = false 

func green_off_cooldown()->void:
	is_green_ability_on_cooldown = false 
		
func set_syn_ability(new_syn_ability:PackedScene)->void:
	syn_ability_instance = new_syn_ability

func set_syn_ability_icon(new_icon_texture:CompressedTexture2D)->void:
	icon_texture = new_icon_texture
		
	
func set_ability_targeting_active()->void:
	syn_crosshair_active = true 
	syn_ability_crosshair.show()
	
func _process(_delta: float) -> void:
	if syn_crosshair_active:
		syn_ability_crosshair.global_position = get_viewport().get_mouse_position()
	else:
		syn_ability_crosshair.hide()
		
	if Global.is_on_purple_dimension():
		
		if active_purple_syn_ability == null: #Purple Charge Refilling
			if active_green_syn_ability == null: #Both Abilities On Cooldown, Revert to Normal Cooldown Rate
				apply_speed_boost(1.0,syn_ability_purple_cooldown_timer)
				apply_speed_boost(1.0,syn_ability_green_cooldown_timer)
			else:
				apply_speed_boost(charge_boost_multipler,syn_ability_purple_cooldown_timer)
			syn_ability_cooldown.set_progress_bar( (1.0 - (syn_ability_purple_cooldown_timer.time_left / syn_ability_purple_cooldown_timer.wait_time)) * 100)
			if syn_ability_purple_cooldown_timer.time_left == 0:
				syn_ability_cooldown.set_progress_bar(100)
				
		elif active_purple_syn_ability != null: #Purple Charge Going Away , Boost Green Refill Unless Green Also Going Away
			syn_ability_cooldown.set_progress_bar((active_purple_syn_ability.death_timer.time_left / active_purple_syn_ability.death_timer.wait_time) * 100)
			if active_green_syn_ability != null:
				apply_speed_boost(1.0,syn_ability_purple_cooldown_timer)
				apply_speed_boost(1.0,syn_ability_green_cooldown_timer)
			else:
				apply_speed_boost(charge_boost_multipler,syn_ability_green_cooldown_timer)
	else: 
		if active_green_syn_ability == null: #Green Charge Refilling
			if active_purple_syn_ability == null: #Both Abilities On Cooldown, Revert to Normal Cooldown Rate
				apply_speed_boost(1.0,syn_ability_purple_cooldown_timer)
				apply_speed_boost(1.0,syn_ability_green_cooldown_timer)
			else:
				apply_speed_boost(charge_boost_multipler,syn_ability_green_cooldown_timer)
			syn_ability_cooldown.set_progress_bar( (1.0 - (syn_ability_green_cooldown_timer.time_left / syn_ability_green_cooldown_timer.wait_time)) * 100)
			if syn_ability_green_cooldown_timer.time_left == 0:
				syn_ability_cooldown.set_progress_bar(100)
				
				
		elif active_green_syn_ability != null:#Green Charge Going Away , Boost Purple Refill
			syn_ability_cooldown.set_progress_bar((active_green_syn_ability.death_timer.time_left / active_green_syn_ability.death_timer.wait_time) * 100)
			if active_purple_syn_ability != null:
				apply_speed_boost(1.0,syn_ability_purple_cooldown_timer)
				apply_speed_boost(1.0,syn_ability_green_cooldown_timer)
			else:
				apply_speed_boost(charge_boost_multipler,syn_ability_purple_cooldown_timer)
			
				
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if syn_crosshair_active:
			if Global.is_on_purple_dimension():
				if is_purple_ability_on_cooldown == false:
					print("Purple Syn Ability CLICK")
					activate_syn_ability(get_viewport().get_mouse_position())
			else:
				if is_green_ability_on_cooldown == false:
					print("Green Syn Ability CLICK")
					activate_syn_ability(get_viewport().get_mouse_position())
					
			syn_crosshair_active = false



func activate_syn_ability(target_pos:Vector2)->void:
	var new_syn_ability_instance :Node= syn_ability_instance.instantiate()
	new_syn_ability_instance.global_position = target_pos
	new_syn_ability_instance.syn_controller = self 
	if Global.is_on_purple_dimension():
		new_syn_ability_instance.add_to_group("Purple")
		active_purple_syn_ability = new_syn_ability_instance
		syn_ability_purple_cooldown_timer.wait_time = active_purple_syn_ability.get_ability_cooldown_duration()
		is_purple_ability_on_cooldown = true 
		
	else:
		new_syn_ability_instance.add_to_group("Green")
		active_green_syn_ability = new_syn_ability_instance
		syn_ability_green_cooldown_timer.wait_time = active_green_syn_ability.get_ability_cooldown_duration()
		is_green_ability_on_cooldown = true 
		
	get_parent().get_active_dimension().add_child(new_syn_ability_instance)

func apply_speed_boost(multiplier: float, timer : Timer) -> void:
	var ratio : float
	var boost_changed : bool = true 
	if timer == syn_ability_purple_cooldown_timer:
		ratio = purple_timer_speed_multiplier / multiplier
		if multiplier == purple_timer_speed_multiplier:
			boost_changed = false
		purple_timer_speed_multiplier = multiplier
		
	if timer == syn_ability_green_cooldown_timer:
		ratio = green_timer_speed_multiplier / multiplier
		if multiplier == green_timer_speed_multiplier:
			boost_changed = false
		green_timer_speed_multiplier = multiplier
	if boost_changed:		
		timer.start(timer.time_left * ratio)

func remove_speed_boost(timer:Timer)->void:
	apply_speed_boost(1.0,timer)
	
func deregister_ability_instance(old_ability:Area2D)->void:
	if old_ability.is_in_group("Purple"):
		active_purple_syn_ability = null
		syn_ability_purple_cooldown_timer.start()
	else:
		active_green_syn_ability = null
		syn_ability_green_cooldown_timer.start()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	##
	
	
	
	
	
