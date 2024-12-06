extends Area2D
#Maw.gd
#Create tentacle component 

var health = 100
var tentacle_scene = preload("res://Scenes/Verlet.tscn")  # Preload tentacle scene
var PlantManager
var tentacles = []  # Array to track all tentacles
var attacking_tentacles = {}  # Dictionary to track which tentacles are attacking which enemies

# Detection radius for zombies
onready var detection_area = $DetectionComponent

var currentTentacle


var charges = 3.0
#Maw has 6 'Charges'
#Basic Zombie 1 Charge
#ConeheadZombie 2 Charges
#BucketHeadZombie 4 Charges

func _ready():
	# Get reference to plant manager
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	setup_tentacles()

func setup_tentacles():
	# First tentacle - Blood red color scheme with aggressive movements
	var tentacle1 = tentacle_scene.instance()
	add_child(tentacle1)
	
	
	# Offset position slightly
	tentacle1.position += Vector2(0, -2)
	
	# Connect retraction signal
	tentacle1.connect("retraction_complete", self, "_on_tentacle_retraction_complete", [tentacle1])
	tentacles.append(tentacle1)
	
	# Second tentacle - Purple color scheme with quick, erratic movements
	var tentacle2 = tentacle_scene.instance()
	add_child(tentacle2)
	
	# Configure colors and pulsing
	#tentacle2.set_colors(
	#	Color(0.7, 0.0, 1.0, 1.0),  # Bright purple
	#	Color(0.35, 0.0, 0.5, 1.0)  # Dark purple
	#)
	tentacle2.set_pulse(true, 2.0, 0.25)  # Faster pulsing
	
	# Configure movement parameters
	tentacle2.wriggle_amplitude = 3   # Moderate movement range
	tentacle2.wriggle_speed = 2.0         # Moderate movement
	tentacle2.phase_offset = PI        # 90-degree phase offset
	tentacle2.direction_bias = 0.0        
	tentacle2.wriggle_dampening = 0.9     # More uniform movement
	tentacle2.secondary_frequency = 1.7    # Faster secondary motion
	
	# Offset position slightly
	tentacle2.position += Vector2(5, 2)
	
	# Connect retraction signal
	tentacle2.connect("retraction_complete", self, "_on_tentacle_retraction_complete", [tentacle2])
	tentacles.append(tentacle2)
	
	# Third tentacle - Green and yellow color scheme with medium, smooth movements
	var tentacle3 = tentacle_scene.instance()
	add_child(tentacle3)
	
	# Configure colors and pulsing
#	tentacle3.set_colors(
#		Color(1.0, 1.0, 0.0, 1.0),
#		Color(0.0, 1.0, 0.0, 1.0)
		#Color(0.0, 1.0, 0.0, 1.0),  # Bright green
		#Color(1.0, 1.0, 0.0, 1.0)   # Yellow
#	)
	tentacle3.set_pulse(true, 1.0, 0.2)  # Gentle pulsing
	
	# Configure movement parameters
	tentacle3.wriggle_amplitude = 2.5   # Small movement range
	tentacle3.wriggle_speed = 1         # Slow speed
	tentacle3.phase_offset = PI * 0.7     # ~126-degree phase offset
	tentacle3.direction_bias = -0.9        
	tentacle3.wriggle_dampening = 0.7     # Balanced movement distribution
	tentacle3.secondary_frequency = 1.5    # Moderate secondary motion
	
	# Offset position slightly
	tentacle3.position += Vector2(-3, -2)
	
	# Connect retraction signal
	tentacle3.connect("retraction_complete", self, "_on_tentacle_retraction_complete", [tentacle3])
	tentacles.append(tentacle3)

func _process(_delta):
	# Check for zombies in detection area
	var overlapping_areas = detection_area.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("Zombie"):
			assign_tentacle_to_target(area)

func assign_tentacle_to_target(target):
	# Don't assign if target is already being attacked
	if target in attacking_tentacles.values():
		return
		
	# Find first available tentacle
	for tentacle in tentacles:
		if not tentacle in attacking_tentacles: 
			#print("Charges is ", charges)
			if charges > 0.0:
				# Assign target to tentacle
				attacking_tentacles[tentacle] = target
				tentacle.enemy = target
				tentacle.start_grab_sequence()
				#charges = charges - target.getChargeComp.getValue()
				charges = charges - 1
				break
			else:
				#print("Cannot attack")
				pass

func _on_tentacle_retraction_complete(tentacle):
	# Remove the enemy-tentacle pair from tracking
	if tentacle in attacking_tentacles:
		var enemy = attacking_tentacles[tentacle]
		if is_instance_valid(enemy):
			enemy.queue_free()  # Remove the caught enemy
		attacking_tentacles.erase(tentacle)
		
 

func take_damage(damage):
	health = health - damage
	if health <= 0:
		# Clean up tentacles
		for tentacle in tentacles:
			tentacle.queue_free()
		PlantManager.clear_space(self.global_position)
		queue_free()


func _on_ShootTimer_timeout():
	pass
	#laser.fire()

func _on_DigestionTimer_timeout():
	#print(charges)
	charges = charges + 2
