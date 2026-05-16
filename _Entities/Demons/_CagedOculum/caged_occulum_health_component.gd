extends DemonHealthComponent


@export var blood_spawn_time := 5 
@export var occulum_buffed_health := 850
@export var occulum_buffed_max_health := 800
@export var occulum_buffed_health_regen := 0.1

@export var maw_buffed_health := 850
@export var maw_buffed_max_health := 800
@export var maw_buffed_health_regen := 0.1

var blood_spawn_timer : Timer
var can_damage_zombie := false 
var canGenBlood := false
var thisBufferName : String

func take_damage(damage):
	super(damage)
	if canGenBlood:
		generate_blood()


#Move to Generate Blood Component That Gets Added
func generate_blood():
	var blood_instance = demon.bloodScene.instantiate()
	demon.get_parent().add_child(blood_instance)  
	blood_instance.global_position = demon.global_position + Vector2(0,-40)
	canGenBlood = false 
	
func _on_reset_blood_spawn_cooldown() -> void:
	canGenBlood = true 

	
func receive_buff(bufferName):
	healthRegen = occulum_buffed_health_regen
	start_regen()
	match bufferName:
		"Occulum":
			canGenBlood = true
			health = occulum_buffed_health
			maxHealth = occulum_buffed_max_health
			blood_spawn_timer = Timer.new()
			blood_spawn_timer.autostart = false 
			blood_spawn_timer.one_shot = false
			blood_spawn_timer.wait_time = blood_spawn_time
			blood_spawn_timer.timeout.connect(_on_reset_blood_spawn_cooldown)
			blood_spawn_timer.start()
		"Crawler":
			pass

		"SpinalOcculum" :
			pass

		"Wyrm":
			can_damage_zombie = true 

		"Hive":
			pass

		"Maw":
			healthRegen = maw_buffed_health_regen
			health = maw_buffed_health
			maxHealth = maw_buffed_max_health




func debuff():
	super() 

	
