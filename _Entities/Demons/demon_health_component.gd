class_name DemonHealthComponent extends Node

@export var health = 800
@export var buffedHealth = 1200
@onready var ogHealth = health

@export var healthRegen = 0.1
@export var buffedHealthRegen = 0.6
@onready var ogHealthRegen = healthRegen

@export var maxHealth = 800
@export var buffedMaxHealth = 1000
@onready var ogMaxHealth = maxHealth

@export var blood_spawn_time := 5 

@onready var demon : Demon = get_parent()


var isEggWyrmBuffed := false 
var isMawBuffed := false 
var isSunflowerBuffed:= false 
var isHiveBuffed:= false
var isCrawlerBuffed:= false
var isSpinalOcculumBuffed := false
var isHeartBuffed:= false  

func get_health():
	return health
	
func take_damage(damage):
	print(demon, " is taking DAMAGE health is ", health)
	health = health - damage
	if(health <= 0):
		demon.die()

func increase_health(added_health_amount):
	health = clamp(health + added_health_amount, 0, maxHealth)
	pass
	
func increase_max_health(added_max_health_amount):
	maxHealth = maxHealth + added_max_health_amount
	
func _process(delta):
	if health != null && healthRegen != null:	
		health = health + healthRegen


func debuff():
	health = ogHealth
	maxHealth = ogMaxHealth
	healthRegen = ogHealthRegen
	
	isEggWyrmBuffed = false 
	isSunflowerBuffed = false
	isMawBuffed = false
	isHiveBuffed = false 
	isCrawlerBuffed = false
	isSpinalOcculumBuffed = false
	isHeartBuffed = false
	
	
	
