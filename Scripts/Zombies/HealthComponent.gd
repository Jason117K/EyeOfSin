extends Node2D
#HealthComponent.gd

#Health Component for all zombie enemies

@onready var hitAudioPlayer = $"../HitAudioPlayer"
@onready var zombie = get_parent()
var bomb_scene = preload("res://Scenes/PlantScenes/Bomb.tscn")

@export var health = 76 #25 # Health of the zombie
@export var healthRegen = 0.0 # Health regen rate
@export var bloodWorth := 1.0

var injured = false 
var halfHealth = health/2

var explode = false    #Determines whether or not the zombie will explode 



# Declare the death signal
signal enemy_died(enemy)

#Returns injured status
func getInjured():
	return injured
	
	
# Function to handle zombie taking damage
func take_damage(damage):
	

	health -= damage
	
	print("Taking damage ", damage, " health now ", health) 
	
	hitAudioPlayer.play()
	#Handles killing the zombie if health hits 0
	if health <= 0:
		#Spawns Bomb on Zombie if it was set to explode 
		if(explode):
			var bomb = bomb_scene.instantiate()
			bomb.position = zombie.position + Vector2(0, 0)  # Adjust starting position
			#print(((get_parent().get_parent()).name), "is parent")
			get_parent().get_parent().add_child(bomb)  
		emit_signal("enemy_died", self)
		
		var root = get_tree().current_scene
		var plant_manager = root.get_node("PlantManager")
		if plant_manager:  # If the PlantManager or GameManager is set
			#$CollectAudioPlayer.play()
			plant_manager.add_sun(bloodWorth)  # Add 25 sun points (or whatever amount)
			plant_manager.play_sun_collect()
		
		zombie.die()


#Applies small passive health regen and determines injured status 
func _process(_delta):
	health = health + healthRegen
	if health < halfHealth:
		injured = true
	else:
		injured = false
		
# Returns the health to it's original value 
func resetHealth():
	health = (halfHealth * 2)

#Sets explode to true
func willExplode():
	explode = true
	
	
