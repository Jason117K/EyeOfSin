extends Area2D
#Sunflower.gd


# Adjustable health and cost 
@export var health = 100
@export var cost = 50
#Keep a reference to our sun scene 
var SunScene = preload("res://Scenes/PlantScenes/Sun.tscn")  # Adjust the path to your sun sprite scene
var PlantManager
@onready var animSpriteComp = $AnimatedSprite2D

#Assign PlantManager and connect the apprioprate timers 
func _ready():
	PlantManager = get_parent().get_parent().get_node("PlantManager") 
	$SunTimer.start()  # Start the timer
	assert($SunTimer.connect("timeout", Callable(self, "_on_SunTimer_timeout")) == OK)
	
	animSpriteComp.animation = "spawn"
	

# Called every time the sun timer reaches timeout
func _on_SunTimer_timeout():
	generate_sun()

# Function to handle sun generation
func generate_sun():
	var sun_instance = SunScene.instantiate()  # Create a new instance of the sun
	add_child(sun_instance)  # Add the sun to the scene
	#Set the sun pos to above the sunflower
	sun_instance.global_position = self.global_position + Vector2(0,-40)


# TODO Implement sunflower buff 
# Handles all pontential sunflower buffs 
func receiveBuff(plantName):
	pass

#Handles the sunflower taking damage 
func take_damage(damage):
	#print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		PlantManager.clear_space(self.global_position)
		queue_free()

# Plant Cost Getter
func get_cost():
	return cost
	


# Stops Spawn Animation From Playing
func _on_AnimatedSprite_animation_finished():
	if animSpriteComp.animation == "spawn":
		animSpriteComp.animation = "idle"
		animSpriteComp.play()
		
		
		
		
		
		
		
		
		
