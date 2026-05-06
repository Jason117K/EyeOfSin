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

func take_damage(damage):
	health = health - damage
	if(health <= 0):
		demon.die()

func _process(delta):
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
	
	
	
