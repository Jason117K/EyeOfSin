class_name HeroAbilityComponent extends Node

@export var cooldown_duration := 25.0
@onready var anim_sprite := $"../AnimatedSpriteComponent"

var stop_ability_timer: Timer
var cooldown_timer: Timer
var is_active := false
var is_on_cooldown := false
var cooldown_elapsed := 0.0


func _ready() -> void:
	print("Hero Ability Ready")
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true 
	cooldown_timer.autostart = false
	cooldown_timer.wait_time = cooldown_duration
	cooldown_timer.timeout.connect(reset_cooldown)
	add_child(cooldown_timer)
	
	is_on_cooldown = false

	
	
func reset_cooldown() -> void:
	is_on_cooldown = false


func begin() -> void:
	if is_on_cooldown:
		return 
	else:
		is_on_cooldown = true 

	print("Hero Ability Begin")

	is_active = true 
	
	apply_ability()

func apply_ability()->void:
	pass
	
	

	
func ability_end() -> void:
	is_active = false
	cooldown_timer.wait_time = cooldown_duration
	cooldown_timer.start()
	is_on_cooldown = true 
	cooldown_elapsed = 0.0
	anim_sprite.speed_scale = 1
	anim_sprite.animation = "idle"



	
