extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var health = 650
export var healthRegen = 0.1
export var buffedHealthRegen = 0.2
var maxHealth
var PlantManager
onready var animComponent = $AnimatedSpriteComponent
var isBuffed = false

export var cost = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	maxHealth = 650#health
	PlantManager = get_parent().get_parent().get_node("PlantManager")

func receiveBuff(bufferName):
	isBuffed = true
	
func take_damage(damage):
	print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		PlantManager.clear_space(self.global_position)
		queue_free()
		

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
		
func get_cost():
	return cost
