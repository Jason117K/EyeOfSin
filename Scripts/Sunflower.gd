extends Area2D
#Sunflower.gd


# Adjustable health and cost 
@export var health = 100
@export var cost = 50
#Keep a reference to our sun scene 
var SunScene = preload("res://Scenes/PlantScenes/Sun.tscn")  # Adjust the path to your sun sprite scene
var PlantManager
@onready var animSpriteComp = $AnimatedSprite2D
@onready var sunTimer = $SunTimer
@export var sunWaitTime := 15.0
@export var buffedSunWaitTime := 12.0 
@onready var buffNodes = $BuffNodesComponent
var isBuffed = false 
var highlight_active = false
var highlight_material = null
var original_material = null

#Assign PlantManager and connect the apprioprate timers 
func _ready():
	sunTimer.wait_time = sunWaitTime
	PlantManager = get_parent().get_parent().get_node("PlantManager") 
	$SunTimer.start()  # Start the timer
	assert($SunTimer.connect("timeout", Callable(self, "_on_SunTimer_timeout")) == OK)
	animSpriteComp.animation = "spawn"
	
	## Store the original material
	#original_material = animSpriteComp.material
	#
	## Create the highlight material (shader)
	#highlight_material = ShaderMaterial.new()
	#highlight_material.shader = load("res://Scripts/Shaders/outline_shader.gdshader")
	#highlight_material.set_shader_parameter("outline_width", 5.0)
	#highlight_material.set_shader_parameter("outline_color", Color(1.0, 0.7, 0.0, 1.0)) # Golden highlight	
	
	
func toggle_highlight():
	print("Highlight Toggled")
	highlight_active = !highlight_active
	
	if highlight_active:
		animSpriteComp.material = highlight_material
	else:
		animSpriteComp.material = original_material	

# Called every time the sun timer reaches timeout
func _on_SunTimer_timeout():
	generate_sun()

# Function to handle sun generation
func generate_sun():
	var sun_instance = SunScene.instantiate()  # Create a new instance of the sun
	get_parent().add_child(sun_instance)  # Add the sun to the scene as a child of gamelayer
	#Set the sun pos to above the sunflower
	sun_instance.global_position = self.global_position + Vector2(0,-40)


# TODO Implement sunflower buff 
# Handles all pontential sunflower buffs 
func receiveBuff(plantName):
	animSpriteComp.make_buff_glow()
	if !isBuffed : 
		sunTimer.wait_time = buffedSunWaitTime
		isBuffed = true 

func debuff():
	sunTimer.wait_time = sunWaitTime
	isBuffed = false
	pass

#Handles the sunflower taking damage 
func take_damage(damage):
	#print("taking damage, health is " , health)
	health = health - damage
	if(health <= 0):
		die()

# Plant Cost Getter
func get_cost():
	#print("1CCost is ", cost)
	cost = cost + (5 * Global.getSunflowerCount())
	#print("2CCost is ", cost)
	return cost
	#cost = cost + 5
	

# Stops Spawn Animation From Playing
func _on_AnimatedSprite_animation_finished():
	if animSpriteComp.animation == "spawn":
		animSpriteComp.animation = "idle"
		animSpriteComp.play()
		
		
		
func die():
	PlantManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
		
func die_fromClearSpace():
	print("Should Clear the DDD Buffs")
	buffNodes.clearBuffs()
	queue_free()		
		

func highlight():
	print("Highlight Here")		
		
		
