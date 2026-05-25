class_name ZombieHealthComponent extends Node2D

@onready var zombie: Zombie = get_parent()

var health: float
var healthRegen: float
var bloodWorth: float
var time_between_bleed: float
var bleed_tick_damage: float

var bomb_scene := preload("res://_Entities/Demons/Explosion/Bomb.tscn")
var bleed_proc_timer: Timer
var regen_timer: Timer
var injured := false
var halfHealth: float
var maxHealth: float
var should_bleed := false
var explode_from_drone := false

signal enemy_died(enemy)


func _ready() -> void:
	health = zombie.health
	healthRegen = zombie.healthRegen
	bloodWorth = zombie.bloodWorth
	time_between_bleed = zombie.time_between_bleed
	bleed_tick_damage = zombie.bleed_tick_damage
	maxHealth = health
	halfHealth = health / 2.0
	set_process(false)
	if healthRegen > 0.0:
		regen_timer = Timer.new()
		regen_timer.wait_time = 0.5
		regen_timer.one_shot = false
		regen_timer.autostart = true
		regen_timer.timeout.connect(_on_regen_tick)
		add_child(regen_timer)


func receive_buff() -> void:
	pass


func add_blood_worth(blood_worth_to_add: float) -> void:
	print("New Blood Worth")
	bloodWorth = bloodWorth + blood_worth_to_add


func getInjured() -> bool:
	return injured


func take_damage(damage: float, piercing: bool = false) -> void:
	#print(zombie.name, " just took, ", damage)
	health -= damage
	injured = health < halfHealth
	AudioManager.create_2d_audio_at_location(zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_TAKE_DAMAGE)
	if health <= 0:
		if explode_from_drone:
			var bomb := bomb_scene.instantiate()
			bomb.position = zombie.position + Vector2(0, 0)
			get_parent().get_parent().add_child(bomb)
		emit_signal("enemy_died", self)
		var gameLayer := get_parent().get_parent()
		var currentLevel := gameLayer.get_parent()
		var demon_manager := currentLevel.get_node("DemonManager")
		if demon_manager:
			demon_manager.add_blood(bloodWorth)
		zombie.die()


func bleed(bleed_damage: float) -> void:
	if should_bleed == false:
		bleed_tick_damage = bleed_damage
		bleed_proc_timer = Timer.new()
		bleed_proc_timer.autostart = false
		bleed_proc_timer.one_shot = false
		bleed_proc_timer.wait_time = time_between_bleed
		bleed_proc_timer.timeout.connect(bleed_tick)
		add_child(bleed_proc_timer)
		bleed_proc_timer.start()
		should_bleed = true


func bleed_tick() -> void:
	take_damage(bleed_tick_damage)


func _on_regen_tick() -> void:
	if health < maxHealth:
		health = min(health + healthRegen, maxHealth)
		injured = health < halfHealth


func resetHealth() -> void:
	health = maxHealth
	injured = false


func willExplodeFromDrone() -> void:
	explode_from_drone = true
