extends Demon
#Wyrm.gd

#Adjustable health & cost
#@export var health = 10
#var og_health
#@export var spinalOcculumBuffed_health = 550
#@export var mawBuffed_health = 350

@export var spinalOcculumBuffed_health = 650
@export var mawBuffed_health = 350

@export var projectile_cooldown: float = 3
@export var projectile_auto_fire := true
@export var occulum_buff_cooldown: float = 0.9
@export var projectile_speed := 600
@export var projectile_damage := 20
@export var bleed_damage_increase := 2

@export var laser_color: Color = Color(1.0, 0.0, 0.0, 1.0)
@export var extension_speed: float = 1000.0
@export var max_length: float = 1000.0
@export var laser_width: float = 4.0
@export var laser_damage: float = 20
@export var maw_damage: float = 60
@export var duration: float = 0.5
@export var laser_auto_fire: bool = false
@export var laser_cooldown: float = 3
@export var blood_buff_cooldown: float = 0.9

# Animation parameters
@export var bob_speed = 2.0  
@export var bob_height = 30.0 
@export var squash_amount = 0.3  
@export var stretch_amount = 0.3  
@export var bounce_elasticity = 0.3  
@export var animation_exaggeration = 1.0  

#@onready var healthComp := $HealthComponent

# Node references
@export var sprite_path: NodePath  
@onready var sprite = get_node(sprite_path) if sprite_path else null
@onready var laserShootComp1 = $Worm1/LaserShootComponent
@onready var laserShootComp2 = $Worm2/LaserShootComponent
@onready var projectile_shoot_component := $ProjectileShootComponent
# Raycast to detect zombies in front of the spider
@onready var attack_ray = $DMG_RayCast2D
@onready var shootTimer = $ShootTimer
@onready var buffNodes = $BuffNodesComponent
@onready var shell_sprite = $Egg

#onready var animSpriteComp = $AnimatedSprite

var isCrawlerBuffed := false
var isSpineBuffed := false
var isOcculumBuffed := false 
var spawnAnimDone = false

# Internal animation state
var time = 0.0
var current_squash = 0.0
var current_stretch = 0.0
var target_squash = 0.0
var target_stretch = 0.0
var velocity = 0.0
var prev_y = 0.0
var initial_sprite_scale: Vector2
var initial_sprite_position: Vector2  
#var isBuffed := false 
var bufferName : String 
var DemonManager
#var isCurrentlyBuffed = true  


func _ready():
	super()
	#print_scene_tree()
	
	if self.is_in_group("Green"):
		print(" I AM GREEN WYRM I WILL ATTACK GREEN")
		$DMG_RayCast2D.set_collision_mask_value(1,false)
		$DMG_RayCast2D.set_collision_mask_value(2,false)
		$DMG_RayCast2D.set_collision_mask_value(3,false)
		$DMG_RayCast2D.set_collision_mask_value(4,false)
		$DMG_RayCast2D.set_collision_mask_value(5,true)
	else:
		$DMG_RayCast2D.set_collision_mask_value(1,false)
		$DMG_RayCast2D.set_collision_mask_value(2,false)
		$DMG_RayCast2D.set_collision_mask_value(3,false)
		$DMG_RayCast2D.set_collision_mask_value(4,true)		
	

		# Get reference to demon manager
	DemonManager = get_parent().get_parent().get_node("DemonManager")
	#Verify sprite is set up correctly 
	if sprite:
		initial_sprite_scale = sprite.scale
		initial_sprite_position = sprite.position  # Store the initial position
	else:
		push_warning("No sprite assigned to animate!")
	shootTimer.wait_time = laserShootComp2.cooldown
	#animSpriteComp.animation = "spawn"
	 
	
func get_demon_true_name():
	return "Wyrm"
func get_demon_name():
	return "WYRM"
		
func get_damage():
	return projectile_shoot_component.projectile_damage
		
# Returns the demons cost 
func get_cost():
	return cost



#Handles wyrm Buffing 
func receive_buff(demon):
	var demonName = (demon.get_demon_true_name())
	
	if !isBuffed :
		super(demonName)
		print(self.name, " Buff Received from ", demonName, " var is ", isBuffed)
		match demonName:
			"Occulum":
				shell_sprite.change_form("Occulum")
				projectile_shoot_component.isOcculumBuffed = true
				#$Worm2/LaserShootComponent.isOcculumBuffed = true 
				laserShootComp2.occulumBuff()
			"Crawler":
				shell_sprite.change_form("Crawler")
				#$Worm2/LaserShootComponent.isSlowingProjectile = true 
				#$Worm3/LaserShootComponent.isSlowingProjectile = true 
				projectile_shoot_component.isCrawlerBuffed = true
				print("Change to CRAWLER")
				#animSpriteComp.change_form("Crawler")
			"SpinalOcculum" : 
				shell_sprite.change_form("SpinalOcculum")
				projectile_shoot_component.wyrm_bleed_buff()
			"Wyrm":
				shell_sprite.change_form("Wyrm")
				
				#animSpriteComp.change_form("Wyrm")
			"Hive":
				shell_sprite.change_form("Wasp")
				attack_ray.target_position = attack_ray.target_position + Vector2(100,0)
				projectile_shoot_component.hiveSpawnDroneBuffed = true 
				#animSpriteComp.change_form("Wasp")
			"Maw":
				#TODO Make Buff Heal Via Signals From Zombie
				shell_sprite.change_form("Maw")
				laserShootComp1.isDisabled = false
				laserShootComp1._ready()
				$ShellBack.visible = false 
				laserShootComp1.mawBuff()
				$Worm1.z_index = 2
				projectile_shoot_component.mawBuffed = true 
				#animSpriteComp.change_form("Maw")
				

#Handles wyrm Buffing 
func debuff():
	if("Crawler" in bufferName):
		laserShootComp2.extension_speed = laserShootComp2.ogExtension_Speed
		laserShootComp2.max_length = laserShootComp2.ogMax_Length
		#Applies a different buff to the laser projectile 
	elif("Occulum" in bufferName):
		laserShootComp2.unBloodBuff()
			
	isBuffed = false 
		
				
# Handles Receiving Damage for the Wyrm 
func take_damage(damage):
	healthComp.take_damage(damage)

# Constantly animates the two worms of the Wyrm 
func _process(delta):

	if not sprite:
		return
		
	time += delta * bob_speed
	
	# Calculate smooth up/down motion with slight ease-in/out
	var raw_bob = sin(time)
	var smoothed_bob = sign(raw_bob) * pow(abs(raw_bob), 0.7)
	var y_offset = smoothed_bob * bob_height * animation_exaggeration
	
	# Calculate velocity for squash/stretch
	var new_velocity = (y_offset - prev_y) / delta
	velocity = lerp(velocity, new_velocity, 0.5)
	prev_y = y_offset
	
	# Determine target squash/stretch based on motion
	var normalized_velocity = clamp(velocity / (bob_height * 2), -1, 1)
	
	if abs(normalized_velocity) > 0.1:
		target_stretch = normalized_velocity * stretch_amount * animation_exaggeration
		target_squash = -target_stretch * 0.5
	else:
		target_squash = abs(smoothed_bob) * squash_amount * animation_exaggeration
		target_stretch = -target_squash * 0.5
	
	# Apply bounce elasticity to squash/stretch
	current_squash = lerp(current_squash, target_squash, bounce_elasticity)
	current_stretch = lerp(current_stretch, target_stretch, bounce_elasticity)
	
	# Apply transformations to the sprite
	var scale_y = initial_sprite_scale.y * (1.0 + current_squash)
	var scale_x = initial_sprite_scale.x * (1.0 + current_stretch)
	
	# Update sprite's transform relative to its initial position
	sprite.position.x = initial_sprite_position.x
	sprite.position.y = initial_sprite_position.y + y_offset
	sprite.scale = Vector2(scale_x, scale_y)
	
func die():
	DemonManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	

func die_fromClearSpace():
	buffNodes.clearBuffs()
	queue_free()		
		
	
# Stops Spawn Animation From Playing
#func _on_AnimatedSprite_animation_finished():
	#if animSpriteComp.animation == "spawn":
	#	animSpriteComp.animation = "idle"

#func spawn_done():
	#
	#if spawnAnimDone:
		#print("Crawler Self Spawn Adjust 1")
		#animSpriteComp.animation = animSpriteComp.currentAnim
		#animSpriteComp.play()
	#else:
		#print("Crawler Self Spawn Adjust 2")
		#animSpriteComp.position = Vector2(animSpriteComp.position.x, animSpriteComp.position.y -8.5)
		#animSpriteComp.animation = animSpriteComp.currentAnim
		#animSpriteComp.play()
		#spawnAnimDone = true 
		



func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSprite2D.visible = false
	$PreviewNodes.visible = true 


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 




	
func receive_heart_buff():
	print(self.name , " receive Heart Buff")
	$BuffNodesComponent.get_child(0).visible = true 
	self.health = self.health + 400
	pass
	
func adjust_position(new_form):
	pass
	#match new_form:
		#"Occulum":
			#print("Self pos was ", self.global_position)
			#self.global_position = self.global_position + Vector2(0,-2)
			#print("Self pos IS ", self.global_position)
#
		#"Crawler":
			#print("Self pos was ", self.global_position)
			#self.global_position = self.global_position + Vector2(0,-2)
			#print("Self pos IS ", self.global_position)
			#
		#"SpinalOcculum" :
			#print("Self pos was ", self.global_position)
			#self.global_position = self.global_position + Vector2(0,-2)
			#print("Self pos IS ", self.global_position)
			#
		#"Wyrm":
			#pass
			#
		#"Wasp":
			#print("Self pos was ", self.global_position)
			#self.global_position = self.global_position + Vector2(0,-2)
			#print("Self pos IS ", self.global_position)
			#
		#"Maw":
			#print("Self pos was ", self.global_position)
			#self.global_position = self.global_position + Vector2(0,-2)
			#print("Self pos IS ", self.global_position)	
