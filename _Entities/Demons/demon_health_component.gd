class_name DemonHealthComponent extends Node

var regen_wait_time := 1

@export var health: float = 800

var rib_health : float
var ogHealth: float

var healthRegen: float = 0.0
var ogHealthRegen: float

var maxHealth: float = 800
var ogMaxHealth: float

@onready var demon: Demon = get_parent()

var regen_timer: Timer

func _ready() -> void:
	health = demon.health
	healthRegen = demon.healthRegen
	maxHealth = demon.maxHealth
	regen_wait_time = demon.regen_wait_time
	ogHealth = health
	ogMaxHealth = maxHealth
	ogHealthRegen = healthRegen
	rib_health = demon.rib_health

var isWyrmBuffed := false
var isMawBuffed := false
var isOcculumBuffed := false
var isHiveBuffed := false
var isCrawlerBuffed := false
var isSpinalOcculumBuffed := false
var isHeartBuffed := false

func get_health() -> float:
	##print(demon, " is getting health from comp, returning ", health)
	return health

func get_max_health() -> float:
	return maxHealth


func take_damage(damage: float) -> void:
	if demon.is_rib_shield:
		rib_health = rib_health - damage
		if rib_health <= 0:
			demon.is_rib_shield = false 
			demon.destroy_rib()
		return 
	if demon.reduced_damage_percent > 0:
		damage = damage * demon.reduced_damage_percent
	health = health - damage
	##print(demon, " is taking DAMAGE health is now ", health)
	if(health <= 0):
		demon.die()

func increase_health(added_health_amount: float) -> void:
	if maxHealth != null:
		health = clamp(health + added_health_amount, 0, maxHealth)
		if added_health_amount > 4.0:
			demon.play_healing_anim()
	pass

func increase_max_health(added_max_health_amount: float) -> void:
	maxHealth = maxHealth + added_max_health_amount


func start_regen() -> void:
	regen_timer = Timer.new()
	regen_timer.autostart = false
	regen_timer.one_shot = false
	regen_timer.wait_time = regen_wait_time
	regen_timer.timeout.connect(increase_health.bind(healthRegen))
	add_child(regen_timer)
	regen_timer.start()


func debuff() -> void:
	health = ogHealth
	maxHealth = ogMaxHealth
	healthRegen = ogHealthRegen

	isWyrmBuffed = false
	isOcculumBuffed = false
	isMawBuffed = false
	isHiveBuffed = false
	isCrawlerBuffed = false
	isSpinalOcculumBuffed = false
	isHeartBuffed = false
	
	
	
