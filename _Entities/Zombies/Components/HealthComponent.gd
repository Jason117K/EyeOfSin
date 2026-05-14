extends Node2D
#HealthComponent.gd

#Health Component for all zombie enemies

#@onready var hitAudioPlayer = $"../HitAudioPlayer"
@onready var zombie = get_parent()
var bomb_scene = preload("res://_Entities/Demons/Explosion/Bomb.tscn")

@export var health := 76 #25 # Health of the zombie
@export var healthRegen = 0.0 # Health regen rate
@export var bloodWorth := 1.0

var injured = false 
var halfHealth = health/2

var explode = false    #Determines whether or not the zombie will explode 
@onready var maxHealth := health

func _ready():
	if healthRegen <= 0.0:
		set_process(false)

# Declare the death signal
signal enemy_died(enemy)

#Returns injured status
func getInjured():
	return injured
	
	
# Function to handle zombie taking damage
func take_damage(damage):
	

	health -= damage
	injured = health < halfHealth

	#hitAudioPlayer.play()
	AudioManager.create_2d_audio_at_location(zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_TAKE_DAMAGE)
	#Handles killing the zombie if health hits 0
	if health <= 0:
		#Spawns Bomb on Zombie if it was set to explode 
		if(explode):
			var bomb = bomb_scene.instantiate()
			bomb.position = zombie.position + Vector2(0, 0)  # Adjust starting position
			#print(((get_parent().get_parent()).name), "is parent")
			get_parent().get_parent().add_child(bomb)  
		emit_signal("enemy_died", self)
		
		var gameLayer = get_parent().get_parent()
		#print("WWGameLayer is", gameLayer)
		var currentLevel = gameLayer.get_parent()
		#print("WWCurrentLevel is", currentLevel)

		var demon_manager = currentLevel.get_node("DemonManager")
		if demon_manager:  # If the DemonManager or GameManager is set
			#$CollectAudioPlayer.play()
			#print("ADDING WW Blood Worth : ", bloodWorth)
			demon_manager.add_blood(bloodWorth)  # Add 25 blood points (or whatever amount)
			#demon_manager.play_blood_collect()
		else:
			pass
			#print("Demon Manager is NULLWWWW")
		zombie.die()


#Applies small passive health regen and determines injured status 
func _process(_delta):
	if health < maxHealth:
		health += healthRegen
		injured = health < halfHealth
		
# Returns the health to it's original value 
func resetHealth():
	health = (halfHealth * 2)
	injured = false

#Sets explode to true
func willExplode():
	explode = true


	
