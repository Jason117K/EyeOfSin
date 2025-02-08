extends Area2D
#WalnutTree.gd

#Adjustbale Plant Parameter Variables
export var health = 650
export var healthRegen = 0.1
export var buffedHealthRegen = 0.2
export var maxHealth = 800
#Adjustable Cost 
export var cost = 100
var PlantManager
onready var animComponent = $AnimatedSpriteComponent
var isBuffed = false



#Grabs reference to plantManager 
func _ready():
	PlantManager = get_parent().get_parent().get_node("PlantManager")

#Sets buffed to true 
func receiveBuff(bufferName):
	isBuffed = true
	
#Handles the walnut taking damage 
func take_damage(damage):
	print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		PlantManager.clear_space(self.global_position)
		queue_free()
		
#Dynamically adjusts the walnuts animation based on damage level 
func _process(delta):
	if health > (maxHealth * 0.9):
		animComponent.animation = "default"
	elif health < maxHealth && health > ((maxHealth/3)*2) :
		animComponent.animation = "hurt1"
	elif (health < ((maxHealth/3)*2)) && health > (maxHealth/3):
		animComponent.animation = "hurt2"
	else:
		animComponent.animation = "hurt3"
		
	if isBuffed:
		health = health + buffedHealthRegen
	else:	
		health = health + healthRegen
		
#Cost getter
func get_cost():
	return cost
