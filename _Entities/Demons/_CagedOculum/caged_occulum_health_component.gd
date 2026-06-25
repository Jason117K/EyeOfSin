extends DemonHealthComponent

var blood_spawn_time := 5
var occulum_buffed_health := 850
var occulum_buffed_max_health := 800
var occulum_buffed_health_regen := 0.1

var maw_buffed_health := 850
var maw_buffed_max_health := 800
var maw_buffed_health_regen := 0.1

var blood_spawn_timer: Timer
var can_damage_zombie := false
var canGenBlood := false
var thisBufferName: String

func _ready() -> void:
	super()
	blood_spawn_time = demon.blood_spawn_time
	occulum_buffed_health = demon.occulum_buffed_health
	occulum_buffed_max_health = demon.occulum_buffed_max_health
	occulum_buffed_health_regen = demon.occulum_buffed_health_regen
	maw_buffed_health = demon.maw_buffed_health
	maw_buffed_max_health = demon.maw_buffed_max_health
	maw_buffed_health_regen = demon.maw_buffed_health_regen

func take_damage(damage: float) -> void:
	super(damage)
	if canGenBlood:
		generate_blood()
	Global.add_mana(demon.mana_add_on_block_damage)


#Move to Generate Blood Component That Gets Added
func generate_blood() -> void:
	var blood_instance :Node = demon.bloodScene.instantiate()
	demon.get_parent().add_child(blood_instance)
	blood_instance.global_position = demon.global_position + Vector2(0,-40)
	canGenBlood = false

func _on_reset_blood_spawn_cooldown() -> void:
	canGenBlood = true

	
func receive_buff(bufferName: String) -> void:
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
			add_child(blood_spawn_timer)
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




func debuff() -> void:
	super()
