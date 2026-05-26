extends RefCounted

class_name ZombieHealthRefCountedComponent

var parent_zombie: Zombie

var health: float
var healthRegen: float
var bloodWorth: float
var time_between_bleed: float
var bleed_tick_damage: float
var bleed_elapsed_time : float = 0
var health_regen_elapsed_time : float = 0 

var bomb_scene := preload("res://_Entities/Demons/Explosion/Bomb.tscn")
var injured := false
var halfHealth: float
var maxHealth: float
var should_bleed := false
var should_health_regen := false 
var time_between_health_regen :float 
var explode_from_drone := false

signal enemy_died(enemy : Node)


func _init(new_parent_zombie : Zombie) -> void:
	parent_zombie = new_parent_zombie
	health = new_parent_zombie.health
	healthRegen = new_parent_zombie.healthRegen
	should_health_regen = new_parent_zombie.should_health_regen
	time_between_health_regen = new_parent_zombie.time_between_health_regen
	bloodWorth = new_parent_zombie.bloodWorth
	time_between_bleed = new_parent_zombie.time_between_bleed
	bleed_tick_damage = new_parent_zombie.bleed_tick_damage
	maxHealth = health
	halfHealth = health / 2.0

	if healthRegen > 0.0:
		should_health_regen = true 
	


func receive_buff() -> void:
	pass


func add_blood_worth(blood_worth_to_add: float) -> void:
	print("New Blood Worth")
	bloodWorth = bloodWorth + blood_worth_to_add


func getInjured() -> bool:
	return injured


func take_damage(damage: float, _piercing: bool = false) -> void:
	#print(zombie.name, " just took, ", damage)
	health -= damage
	injured = health < halfHealth
	AudioManager.create_2d_audio_at_location(parent_zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_TAKE_DAMAGE)
	if health <= 0:
		if explode_from_drone:
			var bomb := bomb_scene.instantiate()
			bomb.position = parent_zombie.position + Vector2(0, 0)
			parent_zombie.get_parent().add_child(bomb)
		emit_signal("enemy_died", self)
		var gameLayer := parent_zombie.get_parent()
		var currentLevel := gameLayer.get_parent()
		var demon_manager := currentLevel.get_node("DemonManager")
		if demon_manager:
			demon_manager.add_blood(bloodWorth)
		parent_zombie.die()

func tick(delta: float) -> void:
	if should_bleed:
		bleed_elapsed_time += delta
		if bleed_elapsed_time >= time_between_bleed:
			bleed_elapsed_time = 0.0
			bleed_tick()
			
	if should_health_regen:
		health_regen_elapsed_time += delta 
		if health_regen_elapsed_time >= time_between_health_regen:
			#print("Health Regen Elapsed Time is ", health_regen_elapsed_time)
			health_regen_elapsed_time = 0.0 
			_on_regen_tick()
			
			
func bleed(bleed_damage: float) -> void:
	if should_bleed == false:
		should_bleed = true
		bleed_tick_damage = bleed_damage

		
		


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
