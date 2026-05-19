class_name ZombieComponentManager extends Node2D


@export_category("Health")
@export var time_between_bleed := 1
@export var health := 76 #25 # Health of the zombie
@export var healthRegen = 0.0 # Health regen rate
@export var bleed_tick_damage := 0


@export_category("Speed")
@export var speed = 20 

@export_category("Attack")
@export var attack_power = 33 # Adjustable reference to attack damage

@export_category("BloodWorth")
@export var bloodWorth := 1.0


func get_blood_worth():
	return bloodWorth
func get_bleed_interval_time():
	return time_between_bleed
func get_speed():
	return speed
func get_attack_power():
	return attack_power
func get_bleed_tick_damage():
	return bleed_tick_damage
func get_health():
	return health 


#State tracking variables 
var is_attacking = false
var target_demon = null
var isSlow = 0  
var thisMaterial  
var thisMaterial2
var spawn_slow_field := false 
var spawn_drone_on_death := false
var should_column_explode := false 
var reset_speed_timer : Timer

@onready var animatedSprite = $"../AnimatedSprite2D"  
@onready var attack_ray = $"../DMGRayCast2D" 
@onready var healthComp = $"../HealthComponent" 
@onready var speedComp =  $"../SpeedComponent"   
@onready var zombie : Zombie = get_parent()
@onready var bloodHit := $"../BloodHit"
@onready var damage_vfx_spawn_locations = [bloodHit]






func _process(delta):
	speedComp.tick(delta)
	animatedSprite.tick(delta)


func blood_slow():
	speedComp.setSpeed(speedComp.getOriginalSpeed()/3)
	set_hue_shift(0)
	
	
func undoBloodSlow():
	reset_speed()
	set_hue_shift(animatedSprite.original_hue_shift)	
	
	
func knockBack():
	zombie.global_position = zombie.global_position + Vector2(9,0) 
	
	
func set_hue_shift(hue_shift_degrees):
	animatedSprite.set_hue_shift(hue_shift_degrees)
	
	
#Make the zombie explode because it fought a buffed drone 
func fightDroneExplode():
	healthComp.willExplodeFromDrone()
	
	
func reset_speed():
	speedComp.setSpeed(speedComp.getOriginalSpeed())
	

func special_move():
	var specialMoveComp = $"../SpecialMoveComp"
	print("Pole Vault Special COMP Manager")
	specialMoveComp.executeMove()
	animatedSprite.setSpecialMoveTrue()
	
	
func special_move2():
	animatedSprite.setSpecialMoveTrue()
	
	
func getSlow():  
	return isSlow 
	
	
func slow():
	isSlow = isSlow + 100
	speedComp.slow()
	$DebuffDegrade.start()

func bleed(bleed_damage):
	healthComp.bleed(bleed_damage)

	
#Returns the health component 
func getHealthComponent():
	return healthComp

func append_blood_hit(new_blood_hit):
	damage_vfx_spawn_locations.append(new_blood_hit)
	
func erase_blood_hit(blood_hit_to_erase):
	damage_vfx_spawn_locations.erase(blood_hit_to_erase)
	
	
# Handles the zombie taking damage 
func take_damage(damage,piercing : bool = false):
	
	for blood_hit in damage_vfx_spawn_locations:
		blood_hit.visible = true 
		blood_hit.rotation_degrees = randf_range(-60, 60)
		if zombie.is_in_group("Purple"):
			blood_hit.play("hit_purple")
		else:
			blood_hit.play("hit_green")
	
	
	
	healthComp.take_damage(damage,piercing)
	
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
		
	
func column_explode():
	should_column_explode = true
	
# Slowly gets rid of slow debuff
func _on_DebuffDegrade_timeout():
	if isSlow > 0:
		isSlow -= 10
		if isSlow <= 0:
			isSlow = 0
			$DebuffDegrade.stop()

func spawn_drone_on_zombie_death():
	spawn_drone_on_death = true  
	
func _on_blood_hit_animation_finished() -> void:
	bloodHit.visible = false
	bloodHit.rotation_degrees = 0
