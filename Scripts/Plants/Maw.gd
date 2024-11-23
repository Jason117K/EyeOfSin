extends Area2D

var health = 100
var tentacle_scene = preload("res://Scenes/Verlet.tscn")  # Preload the tentacle scene
var PlantManager
var attacking = false
var current_target = null
var tentacle = null

# Detection radius for zombies
onready var detection_area = $DetectionComponent

func _ready():
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	# Create and set up the tentacle
	tentacle = tentacle_scene.instance()
	add_child(tentacle)
	tentacle.visible = false  # Hide tentacle initially

func _process(_delta):
	if not attacking:
		# Check for zombies in detection area
		var overlapping_areas = detection_area.get_overlapping_areas()
		for area in overlapping_areas:
			if area.is_in_group("Zombie") and not attacking:
				start_attack(area)
				break

func start_attack(target):
	attacking = true
	current_target = target
	tentacle.visible = true
	tentacle.enemy = current_target  # Set the enemy reference for the tentacle
	tentacle.start_grab_sequence()  # Start the grab sequence
	# Connect to the tentacle's retraction completion signal if you want to handle enemy removal
	if not tentacle.is_connected("retraction_complete", self, "_on_retraction_complete"):
		tentacle.connect("retraction_complete", self, "_on_retraction_complete")

func _on_retraction_complete():
	if current_target and is_instance_valid(current_target):
		current_target.queue_free()  # Remove the zombie
	attacking = false
	current_target = null
	tentacle.visible = false

func take_damage(damage):
	health = health - damage
	if health <= 0:
		PlantManager.clear_space(self.global_position)
		queue_free()
