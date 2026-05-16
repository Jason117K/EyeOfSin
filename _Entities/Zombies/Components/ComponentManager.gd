extends Node2D
#Comp Manager

#Component Manager Script for All Zombies 

# Adjustable Stat Variables 
#@export var health = 17 #Zombie Health
#@export var speed = 29  #Zombie Movement Speed
#@export var attack_power = 33   #Damage zombie deals when attacking

#State tracking variables 
var is_attacking = false #Whether or not we attacking
var target_demon = null  #Holds reference to the demon being attacked
var isSlow = 0  #how much slow the zombie has
var thisMaterial  
var thisMaterial2
var spawn_slow_field := false 

#Onready variables for tracking nodes 
@onready var animatedSprite = $"../AnimatedSprite2D"  # RefCounted to animated Sprite2D
@onready var attack_ray = $"../DMGRayCast2D" # RefCounted to Damage Raycast
@onready var healthComp = $"../HealthComponent" # RefCounted to health comp 
@onready var speedComp =  $"../SpeedComponent"   # RefCounted to Speed Comp
@onready var zombie : Zombie = get_parent()
@onready var bloodHit := $"../BloodHit"

var reset_speed_timer : Timer

func _process(delta):
	speedComp.tick(delta)
	animatedSprite.tick(delta)

func blood_slow():
	#print("BLOOD Slow")
	speedComp.setSpeed(speedComp.getOriginalSpeed()/3)
	set_hue_shift(0)
	
func undoBloodSlow():
	#print("UNDO BLOOD Slow")
	reset_speed()
	#print("OG Hue Shift Is ", animatedSprite.original_hue_shift)
	set_hue_shift(animatedSprite.original_hue_shift)
	
	
	
func knockBack():
	zombie.global_position = zombie.global_position + Vector2(9,0) 
	
func set_hue_shift(hue_shift_degrees):
	animatedSprite.set_hue_shift(hue_shift_degrees)
	
#Tells the zombie it's locked in single combat with a drone
func fightDrone():
	pass
	#$"../AttackComponent"
	#speedComp.setSpeed(0)
	
#Make the zombie explode because it fought a buffed drone 
func fightDroneExplode():
	healthComp.willExplode()
	
#Tells the zombie to stop one on one drone combat
func reset_speed():
	speedComp.setSpeed(speedComp.getOriginalSpeed())
	
#Special Move handler for pole vaulter specifically 
func special_move():
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
	isSlow = isSlow + 100
	speedComp.slow()
	$DebuffDegrade.start()

func bleed():
	print("Health Comp Should Bleed")
	healthComp.bleed()
	
#Returns the health component 
func getHealthComponent():
	return healthComp

# Handles the zombie taking damage 
func take_damage(damage):
#	print(zombie.name, " jjust took, ", damage)
	bloodHit.visible = true 
	bloodHit.rotation_degrees = randf_range(-60, 60)
	if zombie.is_in_group("Purple"):
		bloodHit.play("hit_purple")
	else:
		bloodHit.play("hit_green")
	
	
	
	healthComp.take_damage(damage)
	
	# Adds a visual effect for damage 
	#TODO Review Damage Hit Flash Visusal Effects HitFlash
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
	
func increaseBloodWorth():
	healthComp.bloodWorth = healthComp.bloodWorth + 10.0
#Set the enemy colors on spawn 
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

# Changes sprite color 
func setMaterial(newAnimatedSprite):
	thisMaterial2 = newAnimatedSprite.material.duplicate()
	newAnimatedSprite.material = thisMaterial2
	# Set initial shader parameters
	if newAnimatedSprite:
		thisMaterial2.set_shader_parameter("target_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("replace_color", Color.BLACK)
		thisMaterial2.set_shader_parameter("tolerance", 0.1)

func make_glow():
	pass
	#thisMaterial.set_shader_parameter("glow_color", Color(0, 0, 0, 1) )		

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
	if isSlow > 0:
		isSlow -= 10
		if isSlow <= 0:
			isSlow = 0
			$DebuffDegrade.stop()


func _on_blood_hit_animation_finished() -> void:
	bloodHit.visible = false
	bloodHit.rotation_degrees = 0
