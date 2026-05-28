extends Node

@export var damage := 8.0 
@export var beats := 0
@export var max_beats := 12
#@export var ability_duration := 8.5
@export var beat_of_death_interval := 0.4
@export var cooldown_duration := 25.0

#@onready var cooldown_visual := $Control/CooldownVisual
@onready var beatOfDeathCirle := $"../BeatOfDeathCircle"
@onready var anim_sprite := $"../AnimatedSpriteComponent"
@onready var beat_lightning_dmg_anim := $"../BeatDMGAnim"
@onready var beat_of_death_damage_aoe := $"../BeatOfDeathDamage"

@onready var beat_of_death_lure_timer := $"../LureTimer"
var stop_ability_timer: Timer
var beat_of_death_timer: Timer
var cooldown_timer: Timer
var is_active := false
var is_on_cooldown := false
var cooldown_elapsed := 0.0
#var _beat_tween: Tween


const STEP := 0.1
const EXPAND_SCALE: Vector2 = Vector2(0.35, 0.35)  
const START_SCALE: Vector2 = Vector2(0.1, 0.1)


func _ready() -> void:
	print("Hero Ability Ready")
	beat_of_death_damage_aoe.area_entered.connect(trigger) 
	
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true 
	cooldown_timer.autostart = false
	cooldown_timer.wait_time = cooldown_duration
	cooldown_timer.timeout.connect(reset_cooldown)
	add_child(cooldown_timer)
	
	is_on_cooldown = false

	
	
func reset_cooldown() -> void:
	is_on_cooldown = false

func trigger(new_zombie:Area2D)->void:
	beat_of_death_lure_timer.start()

func begin() -> void:
	await get_tree().physics_frame
	if is_on_cooldown:
		return 
	else:
		is_on_cooldown = true 
	await get_tree().physics_frame
	print("Hero Ability Begin")
	
	anim_sprite.animation = "beat_of_death"

	
	is_active = true 
	
	
	#Start Timer to increment beating dmaage, throw in times 2
	beat_of_death_timer = Timer.new()
	beat_of_death_timer.one_shot = false
	beat_of_death_timer.autostart = false
	beat_of_death_timer.wait_time = beat_of_death_interval
	beat_of_death_timer.timeout.connect(damage_all_zombies_in_range)
	add_child(beat_of_death_timer)
	beat_of_death_timer.start()
	
	
			
		#
	#stop_ability_timer = Timer.new()
	#stop_ability_timer.one_shot = true 
	#stop_ability_timer.autostart = false
	#stop_ability_timer.wait_time = ability_duration
	#stop_ability_timer.timeout.connect(ability_end)
	#add_child(stop_ability_timer)
	#stop_ability_timer.start()
	#
	
func damage_all_zombies_in_range() -> void:
	if beats < max_beats:
		beat_of_death()
		beats += 1
		for new_area:Area2D in beat_of_death_damage_aoe.get_overlapping_areas():
			if new_area.is_in_group("Zombie"):
				new_area.take_damage(damage)
	else:
		beat_of_death_timer.stop()
		beats = 0
		ability_end()
				
	
	
func ability_end() -> void:
	is_active = false
	cooldown_timer.wait_time = cooldown_duration
	cooldown_timer.start()
	is_on_cooldown = true 
	cooldown_elapsed = 0.0
	beat_of_death_timer.stop()
	anim_sprite.speed_scale = 1
	beat_lightning_dmg_anim.hide()
	beat_lightning_dmg_anim.stop()
	cooldown_timer.start()
	anim_sprite.animation = "idle"



func beat_of_death() -> void:
	beat_lightning_dmg_anim.show()
	beat_lightning_dmg_anim.play("new_animation")


	
	
	
