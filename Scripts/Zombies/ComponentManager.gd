extends Node2D
#Comp Manager

export var health = 17 #Zombie Health
export var speed = 29  #Zombie Movement Speed
var is_attacking = false #Whether or not we attacking
var target_plant = null  #Holds reference to the plant being attacked
export var attack_power = 33   #Damage zombie deals when attacking
var isSlow = 0  #how much slow the  has
var thisMaterial
var thisMaterial2


onready var animatedSprite = $"../AnimatedSprite"  # Reference to animated Sprite
onready var attack_ray = $"../DMGRayCast2D" # Reference to Damage Raycast
onready var healthComp = $"../HealthComponent" # Reference to health comp 
onready var speedComp =  $"../SpeedComponent"   # Reference to Speed Comp
onready var zombie = get_parent()


func fightDrone():
	speedComp.setSpeed(0)
	
func fightDroneExplode():
	healthComp.willExplode()
	

func stopFightingDrone():
	speedComp.setSpeed(speedComp.getOriginalSpeed())
	

func special_move():
	var specialMoveComp = $"../SpecialMoveComp"
	print("Pole Vault Special COMP Manager")
	specialMoveComp.executeMove()
	animatedSprite.setSpecialMoveTrue()
	
	
func getSlow():  
	return isSlow 
	
func slow():
	#print("SLOWING")
	isSlow = isSlow + 100 
	speedComp.slow()
	
func getHealthComponent():
	return healthComp

func take_damage(damage):
	print("Just took, ", damage)
	healthComp.take_damage(damage)
	
	if(thisMaterial):
		#print("COKOR COCJHW")
		thisMaterial.set_shader_param("target_color", Color.black)
		thisMaterial.set_shader_param("replace_color", Color.white)
		thisMaterial.set_shader_param("tolerance", 1)
		if(thisMaterial2):
			thisMaterial2.set_shader_param("target_color", Color.black)
			thisMaterial2.set_shader_param("replace_color", Color.white)
			thisMaterial2.set_shader_param("tolerance", 1)
		$ResetThisColor.start()
	


func _on_JustNowSpawned_timeout():
# Create a unique material instance for this zombie

	if(zombie.name == "ConeHeadZombie"):
		#print(animatedSprite)
		pass
	if(animatedSprite.material == null):
		#print("IS NULL")
		pass
	#print(animatedSprite)
	#print(animatedSprite.get_parent().name)
	thisMaterial = animatedSprite.material.duplicate()
	animatedSprite.material = thisMaterial
	# Set initial shader parameters
	if thisMaterial:
		#print("Made h")
		thisMaterial.set_shader_param("target_color", Color.black)
		thisMaterial.set_shader_param("replace_color", Color.black)
		thisMaterial.set_shader_param("tolerance", 0.1)
		pass
		
	add_to_group("Alive-Enemies")
	var group_size = get_tree().get_nodes_in_group("Alive-Enemies").size()

func setMaterial(newAnimatedSprite):
	thisMaterial2 = newAnimatedSprite.material.duplicate()
	newAnimatedSprite.material = thisMaterial2
	# Set initial shader parameters
	if newAnimatedSprite:
		thisMaterial2.set_shader_param("target_color", Color.black)
		thisMaterial2.set_shader_param("replace_color", Color.black)
		thisMaterial2.set_shader_param("tolerance", 0.1)
		

func _on_ResetThisColor_timeout():
	thisMaterial.set_shader_param("target_color", Color.black)
	thisMaterial.set_shader_param("replace_color", Color.black)
	thisMaterial.set_shader_param("tolerance", 0.1)
	if thisMaterial2:
		thisMaterial2.set_shader_param("target_color", Color.black)
		thisMaterial2.set_shader_param("replace_color", Color.black)
		thisMaterial2.set_shader_param("tolerance", 0.1)
	


func _on_DebuffDegrade_timeout():
	if((isSlow - 20) >= 0):
		isSlow = isSlow - 20
