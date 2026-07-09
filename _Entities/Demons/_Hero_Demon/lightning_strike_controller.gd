extends HeroAbilityComponent


@export var damage := 100


@onready var lightning_strike_anim_1 := $"../LightningStrikeAnim"
@onready var lightning_strike_anim_2 := $"../LightningStrikeAnim2"
@onready var lightning_strike_anim_3 := $"../LightningStrikeAnim3"
@onready var all_lightning_strikes : Array[AnimatedSprite2D] = [lightning_strike_anim_1,lightning_strike_anim_2,lightning_strike_anim_3]

@onready var lightning_strike_detection := $"../Lightning_Detection_Close"


var lightning_strike_projectile_scene := load("res://_Entities/Demons/_Crawler/DemonProjectile.tscn")
var lightning_strike_instance : Area2D 


func _ready() -> void:
	super()
	lightning_strike_detection.area_entered.connect(trigger) 
	for lightning_strike in all_lightning_strikes:
		lightning_strike.visible = false 
		lightning_strike.stop()

func get_detection_area()->Area2D:
	return lightning_strike_detection
	
func reset_cooldown() -> void:
	is_on_cooldown = false


func trigger(_new_zombie:Area2D)->void:
	begin()
	#beat_of_death_lure_timer.start()


func begin() -> void:
	super()
	

func apply_ability()->void:
	shoot_lightning_strike()
	
		
func shoot_lightning_strike() -> void:
	for lightning_strike in all_lightning_strikes:
		lightning_strike.visible = true 
		lightning_strike.play()
		lightning_strike_instance = lightning_strike_projectile_scene.instantiate()
		
		lightning_strike_instance.global_position = lightning_strike.global_position
		add_child(lightning_strike_instance)
		lightning_strike_instance.make_hero_lightning_strike()
	ability_end()
		
		
func ability_end() -> void:
	for lightning_strike in all_lightning_strikes:
		lightning_strike.visible = false 
		lightning_strike.stop()
	super()





	
	
