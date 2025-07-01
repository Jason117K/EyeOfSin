extends Area2D
#WalnutTree.gd

#Adjustbale Plant Parameter Variables
@export var health = 800
@export var buffedHealth = 1000
@onready var ogHealth = health

@export var healthRegen = 0.1
@export var buffedHealthRegen = 0.4
@onready var ogHealthRegen = healthRegen

@export var maxHealth = 800
@export var buffedMaxHealth = 1000
@onready var ogMaxHealth = maxHealth




#Adjustable Cost 
@export var cost = 100
#Damage of AOE 
@export var aoeDamage = 4
var PlantManager
@onready var animComponent = $AnimatedSpriteComponent
@onready var AOEComp = $AOEDamageComponent
@onready var buffNodes = $BuffNodesComponent
var isBuffed := false
var eggWyrmBuffed := false 
var thisBufferName : String


#Grabs reference to plantManager 
func _ready():
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	animComponent.animation = "spawn"


#Sets buffed to true 
func receiveBuff(bufferName):
	if !isBuffed:
		if "SunFlower" in bufferName.name:
			health = buffedHealth
			maxHealth = buffedMaxHealth
		elif "EggWorm" in bufferName.name:
			eggWyrmBuffed = true 
		elif "Maw" in bufferName.name:
			healthRegen = buffedHealthRegen
			print("GG Color Changed")
			$AnimatedSpriteComponent.change_color()
	isBuffed = true 
	thisBufferName = bufferName.name

func debuff():
	if "SunFlower" in thisBufferName:
		health = ogHealth
		maxHealth = ogMaxHealth
	elif "EggWorm" in thisBufferName:
		eggWyrmBuffed = false 
	elif "Maw" in thisBufferName:
		healthRegen = ogHealthRegen
	isBuffed = false

	
		
#Handles the walnut taking damage 
func take_damage(damage):
	print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		die()
		
#Dynamically adjusts the walnuts animation based on damage level 
func _process(delta):
	if animComponent.animation == "spawn":
		return
	else:
		if health > (maxHealth * 0.9):
			animComponent.animation = "default"
		elif health < maxHealth && health > ((maxHealth/3)*2) :
			animComponent.animation = "hurt1"
		elif (health < ((maxHealth/3)*2)) && health > (maxHealth/3):
			animComponent.animation = "hurt2"
		else:
			animComponent.animation = "hurt3"
		

	health = health + buffedHealthRegen

		
#Cost getter
func get_cost():
	print("Walnut returning cost of ", cost)
	return cost
	
	

func _on_AnimatedSpriteComponent_animation_finished():
	if animComponent.animation == "spawn":
		animComponent.animation = "default"
		animComponent.play()


func _on_aoe_damage_timer_timeout() -> void:
	if eggWyrmBuffed:
		for area in AOEComp.get_overlapping_areas():
			if area.is_in_group("Zombies"):
				var compManager = area.getCompManager()
				compManager.take_damage(aoeDamage) 
			
		
func die():
	PlantManager.clear_space(self.global_position)
	if buffNodes != null:
		buffNodes.clearBuffs()
	queue_free()			
	
func die_fromClearSpace():
	if buffNodes != null:
		buffNodes.clearBuffs()
	queue_free()				
		
		
		
		
		
		
		
