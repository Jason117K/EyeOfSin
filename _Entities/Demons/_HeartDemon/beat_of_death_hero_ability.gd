extends HeroAbilityComponent

@export var damage := 8.0 
@export var beats := 0
@export var max_beats := 12
@export var beat_of_death_interval := 0.4

@onready var beatOfDeathCirle := $"../BeatOfDeathCircle"
@onready var beat_lightning_dmg_anim := $"../BeatDMGAnim"
@onready var beat_of_death_damage_aoe := $"../BeatOfDeathDamage"
@onready var beat_of_death_lure_timer := $"../LureTimer"

var beat_of_death_timer: Timer


func _ready() -> void:
	super()
	beat_of_death_damage_aoe.area_entered.connect(trigger) 

	
func reset_cooldown() -> void:
	is_on_cooldown = false


func trigger(_new_zombie:Area2D)->void:
	beat_of_death_lure_timer.start()


func begin() -> void:
	super()
	

func apply_ability()->void:
	anim_sprite.animation = "beat_of_death"
	#Start Timer to increment beating dmaage, throw in times 2
	beat_of_death_timer = Timer.new()
	beat_of_death_timer.one_shot = false
	beat_of_death_timer.autostart = false
	beat_of_death_timer.wait_time = beat_of_death_interval
	beat_of_death_timer.timeout.connect(damage_all_zombies_in_range)
	add_child(beat_of_death_timer)
	beat_of_death_timer.start()
	
		
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
	super()
	beat_of_death_timer.stop()
	beat_lightning_dmg_anim.hide()
	beat_lightning_dmg_anim.stop()


func beat_of_death() -> void:
	beat_lightning_dmg_anim.show()
	beat_lightning_dmg_anim.play("new_animation")


	
	
	
