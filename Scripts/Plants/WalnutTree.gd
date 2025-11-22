extends Demon
#WalnutTree.gd

#Adjustbale Plant Parameter Variables
@export var health = 800
@export var buffedHealth = 1200
@onready var ogHealth = health

@export var healthRegen = 0.1
@export var buffedHealthRegen = 0.6
@onready var ogHealthRegen = healthRegen

@export var maxHealth = 800
@export var buffedMaxHealth = 1000
@onready var ogMaxHealth = maxHealth

var isEggWyrmBuffed := false 
var isMawBuffed := false 
var isSunflowerBuffed:= false 	
var hiveBuffed:= false
var sunBuffed = false
var canGenSun = false


#Adjustable Cost 
@export var cost = 100
#Damage of AOE 
@export var aoeDamage = 4
var PlantManager
#@onready var animSpriteComp = $AnimatedSpriteComponent
@onready var AOEComp = $AOEDamageComponent
@onready var buffNodes = $BuffNodesComponent
var isBuffed := false
var eggWyrmBuffed := false 
var thisBufferName : String
var SunScene = preload("res://Scenes/PlantScenes/Sun.tscn")  
var phantomHive = preload("res://Scenes/PlantScenes/phantom_hive.tscn")
var can_damage_zombie= false 

#Grabs reference to plantManager 
func _ready():
	animSpriteComp = $AnimatedSpriteComponent
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	animSpriteComp.animation = "spawn"



#Sets buffed to true 
func receiveBuff(bufferName):
	if !isBuffed :
		super(bufferName)
		animSpriteComp.make_buff_glow()
		
		if "Sun" in bufferName.name && !isSunflowerBuffed:
			canGenSun = true 
			sunBuffed = true 
			health = buffedHealth
			maxHealth = buffedMaxHealth
			isSunflowerBuffed = true 
		elif "EggWorm" in bufferName.name && !isEggWyrmBuffed:
			eggWyrmBuffed = true 
			isEggWyrmBuffed = true 
			can_damage_zombie = true 
		elif "Maw" in bufferName.name && !isMawBuffed:
			healthRegen = buffedHealthRegen
			isMawBuffed = true 
			print("GG Color Changed")
			#TODO Re Implement Color Changes
			#$AnimatedSpriteComponent.change_color()
		elif "Pea" in bufferName.name :
			$Web.visible  = true 
			$Web/Area2D.monitoring= true
		elif "Hive" in bufferName.name:
			
			spawnPhantomHive()
		thisBufferName = bufferName.name
		isBuffed = true 

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
	if sunBuffed:
		if canGenSun:
			generate_sun()
	print("walnut taking damage, health is " , health, " damage is ", damage)
	health = health - damage
	if(health <= 0):
		die()
		
func generate_sun():
	var sun_instance = SunScene.instantiate()
	print("Spawn Sun")
	get_parent().add_child(sun_instance)  # Add the sun to the scene as a child of gamelayer
	#Set the sun pos to above the sunflower
	sun_instance.global_position = self.global_position + Vector2(0,-40)
	canGenSun = false 
		
#Dynamically adjusts the walnuts animation based on damage level 
func _process(delta):
	if animSpriteComp.animation == "spawn":
		return
	else:
		pass#TODO Restore Hurt Anims
		#if health > (maxHealth * 0.9):
			#animSpriteComp.animation = "default"
		#elif health < maxHealth && health > ((maxHealth/3)*2) :
			#animSpriteComp.animation = "hurt1"
		#elif (health < ((maxHealth/3)*2)) && health > (maxHealth/3):
			#animSpriteComp.animation = "hurt2"
		#else:
			#animSpriteComp.animation = "hurt3"
		

	health = health + healthRegen

		
#Cost getter
func get_cost():
	print("Walnut returning cost of ", cost)
	return cost
	
	

func _on_AnimatedSprite_animation_finished():

	if animSpriteComp.animation == "spawn":
		animSpriteComp.animation = "idle"
		animSpriteComp.play()
	else:
		animSpriteComp.animation = animSpriteComp.currentAnim
		animSpriteComp.play()


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
		
		
func spawnPhantomHive():
	var hive_instance = phantomHive.instantiate()
	print("Spawn HIVE")
	get_parent().add_child(hive_instance)  # Add the phantom hive to the scene as a child of gamelayer
	#Set the sun pos to above the sunflower
	hive_instance.global_position = self.global_position 

		
		
		
		


func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area , " just entered walnut snow field  ")
	if area.is_in_group("Zombie"):
		print("Zombie Entered Slow Field")
		#if area.get_parent().get_parent() != self.get_parent().get_parent():
			#return
		var compManager = area.getCompManager()
		var healthComp = compManager.getHealthComponent()
		#TODO Balance
		compManager.slow()


func _on_reset_sun_cooldown_timeout() -> void:
	canGenSun = true 


func walnutWyrmBuffed():
	pass
	
