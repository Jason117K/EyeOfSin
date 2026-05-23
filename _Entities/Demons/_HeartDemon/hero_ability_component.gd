extends Node

var stop_ability_timer: Timer
var beat_of_death_timer: Timer
var ability_duration := 6.0
var beat_of_death_duration := 1.5
var cooldown_timer: Timer
var cooldown_duration := 5.0
var is_active := false
var is_on_cooldown := false
var cooldown_elapsed := 0.0
var cooldown_fill_amount := 0.0
var _beat_tween: Tween

@onready var cooldown_visual := $Control/CooldownVisual
@onready var damage_zone := $"../DMGZone"
@onready var beatOfDeathCirle := $"../BeatOfDeathCircle"
@onready var activate_ability_button := $Control/ActivateAbilityButton
@onready var anim_sprite := $"../AnimatedSprite2D"

@export var damage := 8.0 

const STEP := 0.1
const EXPAND_SCALE: Vector2 = Vector2(0.35, 0.35)  
const START_SCALE: Vector2 = Vector2(0.1, 0.1)


func _ready() -> void:
	print("Hero Ability Ready")
	activate_ability_button.pressed.connect(begin)
	cooldown_visual.material.set_shader_parameter("fill_amount", 0.0)
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true 
	cooldown_timer.autostart = false
	cooldown_timer.wait_time = cooldown_duration
	cooldown_timer.timeout.connect(reset_cooldown)
	add_child(cooldown_timer)
	cooldown_timer.start()
	is_on_cooldown = true 

	
func reset_cooldown() -> void:
	is_on_cooldown = false



func begin() -> void:
	pass
	print("Hero Ability Trying")
	if is_on_cooldown:
		return 
	anim_sprite.speed_scale = 4
	print("Hero Ability Begin")
	
	is_active = true 
	cooldown_fill_amount = 0.0
	
	damage_zone.monitoring = true 
	#await get_tree().physics_frame
	damage_all_zombies_in_range()
	
	#Start Timer to increment beating dmaage, throw in times 2
	beat_of_death_timer = Timer.new()
	beat_of_death_timer.one_shot = false
	beat_of_death_timer.autostart = false
	beat_of_death_timer.wait_time = beat_of_death_duration
	beat_of_death_timer.timeout.connect(damage_all_zombies_in_range)
	add_child(beat_of_death_timer)
	beat_of_death_timer.start()
	
	
			
		
	stop_ability_timer = Timer.new()
	stop_ability_timer.one_shot = true 
	stop_ability_timer.autostart = false
	stop_ability_timer.wait_time = ability_duration
	stop_ability_timer.timeout.connect(ability_end)
	add_child(stop_ability_timer)
	stop_ability_timer.start()
	
func damage_all_zombies_in_range() -> void:
	beat_of_death()
	for new_area in damage_zone.get_overlapping_areas():
		if new_area.is_in_group("Zombie"):
			new_area.take_damage(damage)
				
	
	
func ability_end() -> void:
	is_active = false
	cooldown_timer.wait_time = cooldown_duration
	cooldown_timer.start()
	is_on_cooldown = true 
	cooldown_elapsed = 0.0
	beat_of_death_timer.stop()
	anim_sprite.speed_scale = 1


func _physics_process(delta: float) -> void:
	
	if is_active == false && is_on_cooldown:
		cooldown_elapsed += delta
		cooldown_fill_amount = clampf(cooldown_elapsed / cooldown_duration, 0.0, 1.0)
		cooldown_visual.material.set_shader_parameter("fill_amount", cooldown_fill_amount)
	elif is_active == true:
		cooldown_fill_amount = 0.0
		cooldown_visual.material.set_shader_parameter("fill_amount", cooldown_fill_amount)


func beat_of_death() -> void:
	
	if _beat_tween and _beat_tween.is_running():
		_beat_tween.kill()
	
	# Reset sprite to starting state
	beatOfDeathCirle.scale = START_SCALE
	beatOfDeathCirle.modulate.a = 1.0
	beatOfDeathCirle.visible = true

	_beat_tween = create_tween()
	_beat_tween.set_parallel(true)  # Run scale and fade simultaneously

	# Scale up
	_beat_tween.tween_property(beatOfDeathCirle, "scale", EXPAND_SCALE, beat_of_death_duration)

	# Fade out
	_beat_tween.tween_property(beatOfDeathCirle, "modulate:a", 0.0, beat_of_death_duration)

	
	

	
	
	
