extends Node2D
#Comp Manager

#Component Manager Script for All Zombies 

# Adjustable Stat Variables 
@export var health = 17 #Zombie Health
@export var speed = 29  #Zombie Movement Speed
@export var attack_power = 33   #Damage zombie deals when attacking

#State tracking variables 
var is_attacking = false #Whether or not we attacking
var target_plant = null  #Holds reference to the plant being attacked
var isSlow = 0  #how much slow the zombie has
var thisMaterial  
var thisMaterial2

#Onready variables for tracking nodes 
@onready var animatedSprite = $"../AnimatedSprite2D"  # RefCounted to animated Sprite2D
@onready var attack_ray = $"../DMGRayCast2D" # RefCounted to Damage Raycast
@onready var healthComp = $"../HealthComponent" # RefCounted to health comp 
@onready var speedComp =  $"../SpeedComponent"   # RefCounted to Speed Comp
@onready var zombie = get_parent()

#Tells the zombie it's locked in single combat with a drone
func fightDrone():
	speedComp.setSpeed(0)
	
#Make the zombie explode because it fought a buffed drone 
func fightDroneExplode():
	healthComp.willExplode()
	
#Tells the zombie to stop one on one drone combat
func stopFightingDrone():
	speedComp.setSpeed(speedComp.getOriginalSpeed())
	
#Special Move handler for pole vaulter specifically 
func special_move():
	print("PP Comp Manager Special Move")
	var specialMoveComp = $"../SpecialMoveComp"
	#print("Pole Vault Special COMP Manager")
	specialMoveComp.executeMove()
	animatedSprite.setSpecialMoveTrue()
	
# Generoic special move setter 
func special_move2():
	animatedSprite.setSpecialMoveTrue()
	
# Returns current slow amount
func getSlow():  
	return isSlow 
	
# Debuffs zombie with slow effect
func slow():
	#print("SLOWING")
	isSlow = isSlow + 100 
	speedComp.slow()
	
#Returns the health component 
func getHealthComponent():
	return healthComp

# Handles the zombie taking damage 
func take_damage(damage):
	#print("Just took, ", damage)
	healthComp.take_damage(damage)
	
	# Adds a visual effect for damage 
	#TODO Review Damage Visusal Effects 
	if(thisMaterial):
		#print("COKOR COCJHW")
		thisMaterial.set_shader_parameter("target_color", Color.BLACK)
		thisMaterial.set_shader_parameter("replace_color", Color.WHITE)
		thisMaterial.set_shader_parameter("tolerance", 1)
		if(thisMaterial2):
			thisMaterial2.set_shader_parameter("target_color", Color.BLACK)
			thisMaterial2.set_shader_parameter("replace_color", Color.WHITE)
			thisMaterial2.set_shader_parameter("tolerance", 1)
		$ResetThisColor.start()
	

#Set the enemy colors on spawn 
func _on_JustNowSpawned_timeout():
#Create a unique material instance for this zombie
	thisMaterial = animatedSprite.material.duplicate()
	animatedSprite.material = thisMaterial
	# Set initial shader parameters
	if thisMaterial:
		#print("Made h")
		thisMaterial.set_shader_parameter("target_color", Color.BLACK)
		thisMaterial.set_shader_parameter("replace_color", Color.BLACK)
		thisMaterial.set_shader_parameter("tolerance", 0.1)
		pass
		
	add_to_group("Alive-Enemies")
	var group_size = get_tree().get_nodes_in_group("Alive-Enemies").size()

# Changes sprite color 
func setMaterial(newAnimatedSprite):
	thisMaterial2 = newAnimatedSprite.material.duplicate()
	newAnimatedSprite.material = thisMaterial2
	# Set initial shader parameters
	if newAnimatedSprite:
		thisMaterial2.set_shader_parameter("target_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("replace_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("tolerance", 0.1)
		

# Changes sprite color back to default 
func _on_ResetThisColor_timeout():
	thisMaterial.set_shader_parameter("target_color", Color.BLACK)
	thisMaterial.set_shader_parameter("replace_color", Color.BLACK)
	thisMaterial.set_shader_parameter("tolerance", 0.1)
	if thisMaterial2:
		thisMaterial2.set_shader_parameter("target_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("replace_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("tolerance", 0.1)
	

# Slowly gets rid of slow debuff
func _on_DebuffDegrade_timeout():
	if((isSlow - 10) >= 0):
		isSlow = isSlow - 10
