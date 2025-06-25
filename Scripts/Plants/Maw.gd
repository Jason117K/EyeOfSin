extends Area2D
#Maw.gd

# Color export variables for tentacle 1
@export var tentacle1_start_color := Color(0.8, 0.2, 0.2, 1.0)  # Blood red
var tentacle1_end_color := Color(0.4, 0.0, 0.0, 1.0)    # Dark red

# Color export variables for tentacle 2
@export var tentacle2_start_color := Color(0.7, 0.0, 1.0, 1.0)  # Bright purple
var tentacle2_end_color := Color(0.35, 0.0, 0.5, 1.0)   # Dark purple

# Color export variables for tentacle 3
@export var tentacle3_start_color := Color(0.0, 1.0, 0.0, 1.0)  # Bright green
var tentacle3_end_color := Color(1.0, 1.0, 0.0, 1.0)    # Yellow

#Reference to tentacle scene 
var tentacle_scene = preload("res://Scenes/MawTentacle.tscn")  
@onready var detectionAreaShape = $DetectionComponent/CollisionShape2D
#Adjustable maw health & cost 
@export var health = 100
@onready var ogHealth = 100
@export var cost = 200

var PlantManager              # Plantmanager RefCounted 
var tentacles = []            # Array to track all tentacles
var attacking_tentacles = {}  # Dictionary to track which tentacles are attacking which enemies
var tentacle1
var tentacle2
var tentacle3
var currentTentacle
var charges = 4.0             # Essentially Maw ammo 
var willBelchWebs = false     # Whether or not we have a peashooter buff 
var available_tentacles = []  # Track which tentacles are available
var willBelchSun := false 

@export var bloodAmount = 10

#Essentially a reload timer for the maw
@onready var digestionTimer = $DigestionTimer
@export var digestTime : float
@onready var ogDigestTime = digestTime
# Detection radius for zombies
@onready var detection_area = $DetectionComponent
@onready var buffNodes = $BuffNodesComponent
@onready var animSpriteComp = $AnimatedSprite2D
@onready var ogDetectionRadius = detectionAreaShape.shape.radius

var bloodScene = preload("res://Scenes/PlantScenes/Sun.tscn")  # Adjust the path to your sun sprite scene
var isBuffed := false 
var bufferName : String 

func _ready():
	collision_mask = 2
	print("Maw Area2D: ", name)
	print("Maw Collision Layer: ", collision_layer)
	print("Maw Collision Mask: ", collision_mask)
	print("Maw Monitoring: ", monitoring)
	print("Maw Monitorable: ", monitorable)
	
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	setup_tentacles()
	animSpriteComp.animation = "spawn"
	
#Plant Cost Getter
func get_cost():
	return cost
		
#Sets Up and Configures all the tentacles 
func setup_tentacles():
	# First tentacle setup
	tentacle1 = tentacle_scene.instantiate()
	add_child(tentacle1)
	tentacle1.z_index = z_index - 1
	#tentacle1.position += Vector2(0, -2)
	tentacle1.set_colors(tentacle1_start_color, tentacle1_end_color)
	tentacle1.connect("retraction_complete", Callable(self, "_on_tentacle_retraction_complete").bind(tentacle1))
	tentacles.append(tentacle1)
	available_tentacles.append(tentacle1)
	
	# Second tentacle setup
	tentacle2 = tentacle_scene.instantiate()
	add_child(tentacle2)
	tentacle2.z_index = z_index - 1
	tentacle2.set_colors(tentacle2_start_color, tentacle2_end_color)
	tentacle2.set_pulse(true, 2.0, 0.25)
	tentacle2.wriggle_amplitude = 3
	tentacle2.wriggle_speed = 2.0
	tentacle2.phase_offset = PI
	tentacle2.direction_bias = 0.0
	tentacle2.wriggle_dampening = 0.9
	tentacle2.secondary_frequency = 1.7
	#tentacle2.position += Vector2(5, 2)
	tentacle2.connect("retraction_complete", Callable(self, "_on_tentacle_retraction_complete").bind(tentacle2))
	tentacles.append(tentacle2)
	available_tentacles.append(tentacle2)
	
	# Third tentacle setup
	tentacle3 = tentacle_scene.instantiate()
	add_child(tentacle3)
	tentacle3.z_index = z_index - 1
	tentacle3.set_colors(tentacle3_start_color, tentacle3_end_color)
	tentacle3.set_pulse(true, 1.0, 0.2)
	tentacle3.wriggle_amplitude = 2.5
	tentacle3.wriggle_speed = 1
	tentacle3.phase_offset = PI * 0.7
	tentacle3.direction_bias = -0.9
	tentacle3.wriggle_dampening = 0.7
	tentacle3.secondary_frequency = 1.5
	#tentacle3.position += Vector2(-3, -2)
	tentacle3.connect("retraction_complete", Callable(self, "_on_tentacle_retraction_complete").bind(tentacle3))
	tentacles.append(tentacle3)
	available_tentacles.append(tentacle3)

#Constantly check for enemies in range and assign them for eating appropriately 
func _process(_delta):
	pass
	#var overlapping_areas = detection_area.get_overlapping_areas()
	#print("Maw Overlapping Areas Is ", overlapping_areas)
	#for area in overlapping_areas:
		#print("AArea Is ", area)
		#if area.is_in_group("Zombie"):
			#print("BBAssigning Tentacle to  ", area)
		###	assign_tentacle_to_target(area)

#Assign a target to a tentacle 
func assign_tentacle_to_target(target):
	#Early return if the target is already being eaten 
	if target in attacking_tentacles.values():
		return
	#If we have a free tentacle, assignment is possible 
	if available_tentacles.size() > 0 and charges > 0:
		#Select a tentacle, give it an enemy, and decrement charges 
		var tentacle = available_tentacles.pop_front()
		attacking_tentacles[tentacle] = target
		tentacle.enemy = target
		tentacle.start_grab_sequence()
		charges -= 1

#Handle Tentacle Retraction 
func _on_tentacle_retraction_complete(tentacle):
	
	#Get a reference to the eaten enemy 
	if tentacle in attacking_tentacles:
		var enemy = attacking_tentacles[tentacle]
		
		if is_instance_valid(enemy):
			#print(enemy.name)
			var enemyCompManager = enemy.getCompManager()
			var slow = enemyCompManager.getSlow()
			#If the swallowed enemy is slow and maw is buffed, belch a web bomb
			if(slow > 0):
				if willBelchWebs:
					var web_ball = preload("res://Scenes/PlantScenes/WebBall.tscn").instantiate()
					add_child(web_ball)
					web_ball.target_position = Vector2(100, 0)
					web_ball.travel_time = 1.5

			var compManager = enemy.getCompManager()	
			compManager.take_damage(9999)	
			#enemy.queue_free()
		attacking_tentacles.erase(tentacle)
		tentacle.visible = false  # Hide tentacle after retraction

#Handles the Maw taking damage 
func take_damage(damage):
	health = health - damage
	if health <= 0:
		for tentacle in tentacles:
			tentacle.queue_free()
		die()

#When the time is up, free up a tentacle by adding a charge
func _on_DigestionTimer_timeout():
	charges += 1
	if charges > tentacles.size():
		charges = tentacles.size()
		
	# Make a tentacle available if we have charges
	for tentacle in tentacles:
		if not tentacle in available_tentacles and not tentacle in attacking_tentacles:
			available_tentacles.append(tentacle)
			tentacle.visible = true
			break
	if willBelchSun:
		generate_sun()

#Handles Receiving Buffs From EggWorm, Peashooter, and Hive, setting color accordingly 
func receiveBuff(plant):
	if !isBuffed:
	#print(bufferName)
		bufferName = plant.name
		if("EggWorm" in bufferName):
			tentacle1.set_colors(Color.YELLOW, Color.YELLOW)
			tentacle2.set_colors(Color.BLUE, Color.BLUE)
			digestionTimer.wait_time = 6
		elif("Peashooter" in bufferName):
			tentacle1.set_colors(Color.PURPLE, Color.PURPLE)
			tentacle2.set_colors(Color.DARK_MAGENTA, Color.DARK_MAGENTA)
			willBelchWebs = true
		elif("Hive" in bufferName):
			tentacle1.set_colors(Color.WHITE, Color.WHITE)
			tentacle2.set_colors(Color.BLACK, Color.BLACK)
			print("DD Area Shape Radius is : ", detectionAreaShape.shape.radius)
			detectionAreaShape.shape.radius = detectionAreaShape.shape.radius * 1.2
			health = 200
			print("Buffer Was HHIve")
		elif("Sunflower" in bufferName):
			willBelchSun = true 
		isBuffed = true 
		
func debuff():
	if("EggWorm" in bufferName):
		tentacle1.set_colors(Color.YELLOW, Color.YELLOW)
		tentacle2.set_colors(Color.BLUE, Color.BLUE)
		digestionTimer.wait_time = ogDigestTime
	elif("Peashooter" in bufferName):
		tentacle1.set_colors(Color.PURPLE, Color.PURPLE)
		tentacle2.set_colors(Color.DARK_MAGENTA, Color.DARK_MAGENTA)
		willBelchWebs = false
	elif("Hive" in bufferName):
		tentacle1.set_colors(Color.WHITE, Color.WHITE)
		tentacle2.set_colors(Color.BLACK, Color.BLACK)
		print("DD Area Shape Radius is : ", detectionAreaShape.shape.radius)
		detectionAreaShape.shape.radius = ogDetectionRadius
		health = ogHealth
		print("Buffer Was HHIve")
	elif("Sunflower" in bufferName):
		willBelchSun = false 
	isBuffed = false 		

# Stops Spawn Animation From Playing
func _on_AnimatedSprite_animation_finished():
	if animSpriteComp.animation == "spawn":
		animSpriteComp.animation = "default"
		animSpriteComp.play()
		
# Function to handle sun generation
func generate_sun():
	var sun_instance = bloodScene.instantiate()  # Create a new instance of the sun
	add_child(sun_instance)  # Add the sun to the scene
	sun_instance.setWorth(bloodAmount)
	#Set the sun pos to above the sunflower
	sun_instance.global_position = self.global_position + Vector2(0,-40)	
		


func _on_detection_component_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
	#	print("Maw Assigning Tentacle to  ", area)
		assign_tentacle_to_target(area)
		
func die():
	PlantManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	


func die_fromClearSpace():
	buffNodes.clearBuffs()
	queue_free()		
