class_name DemonHealthComponent extends Node

var regen_wait_time := 1

var health = 800
var ogHealth

var healthRegen = 0.0
var ogHealthRegen

var maxHealth = 800
var ogMaxHealth

@onready var demon : Demon = get_parent()

var regen_timer : Timer

func _ready():
	health = demon.health
	healthRegen = demon.healthRegen
	maxHealth = demon.maxHealth
	regen_wait_time = demon.regen_wait_time
	ogHealth = health
	ogMaxHealth = maxHealth
	ogHealthRegen = healthRegen

var isWyrmBuffed := false 
var isMawBuffed := false 
var isOcculumBuffed:= false 
var isHiveBuffed:= false
var isCrawlerBuffed:= false
var isSpinalOcculumBuffed := false
var isHeartBuffed:= false  

func get_health():
	#print(demon, " is getting health from comp, returning ", health)
	return health

func get_max_health():
	return maxHealth
	
	
func take_damage(damage):
	
	health = health - damage
	#print(demon, " is taking DAMAGE health is now ", health)
	if(health <= 0):
		demon.die()

func increase_health(added_health_amount):
	if maxHealth != null:
		health = clamp(health + added_health_amount, 0, maxHealth)
	pass
	
func increase_max_health(added_max_health_amount):
	maxHealth = maxHealth + added_max_health_amount
	

func start_regen():
	regen_timer = Timer.new()
	regen_timer.autostart = false 
	regen_timer.one_shot = false 
	regen_timer.wait_time = regen_wait_time
	regen_timer.timeout.connect(increase_health.bind(healthRegen))
	add_child(regen_timer)
	regen_timer.start()


func debuff():
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
	
	
	
