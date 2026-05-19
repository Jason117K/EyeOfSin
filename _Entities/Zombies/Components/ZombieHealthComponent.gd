class_name ZombieHealthComponent extends Node2D
#ZombieHealthComponent.gd


#@onready var hitAudioPlayer = $"../HitAudioPlayer"
#@onready var zombie : Zombie = get_parent()
@onready var component_manager :ZombieComponentManager = zombie.getCompManager()

#@export var time_between_bleed := 1
#@export var health := 76 #25 # Health of the zombie
#@export var healthRegen = 0.0 # Health regen rate
#@export var bloodWorth := 1.0
#@export var bleed_tick_damage := 0


var bomb_scene = preload("res://_Entities/Demons/Explosion/Bomb.tscn")
var bleed_proc_timer : Timer 
var injured = false 
var halfHealth = 1#health/2
var should_bleed := false 

var explode_from_drone = false   
@onready var maxHealth : float = zombie.getCompManager().get_health()

func receive_buff():
	pass
	
func add_blood_worth(blood_worth_to_add):
	print("New Blood Worth")
	bloodWorth = bloodWorth + blood_worth_to_add
	

func _ready():
	if healthRegen <= 0.0:
		set_process(false)

# Declare the death signal
signal enemy_died(enemy)

#Returns injured status
func getInjured():
	return injured
	
	
# Function to handle zombie taking damage
func take_damage(damage, piercing : bool = false):
	
	print(zombie.name, " just took, ", damage)
	health -= damage
	injured = health < halfHealth

	#hitAudioPlayer.play()
	AudioManager.create_2d_audio_at_location(zombie.global_position, SoundEffect.SOUND_EFFECT_TYPE.ZOMBIE_TAKE_DAMAGE)
	#Handles killing the zombie if health hits 0
	if health <= 0:
		if(explode_from_drone):
			var bomb = bomb_scene.instantiate()
			bomb.position = zombie.position + Vector2(0, 0)  # Adjust starting position
			#print(((get_parent().get_parent()).name), "is parent")
			get_parent().get_parent().add_child(bomb)  
		emit_signal("enemy_died", self)
		
		var gameLayer = get_parent().get_parent()
		var currentLevel = gameLayer.get_parent()

		var demon_manager = currentLevel.get_node("DemonManager")
		if demon_manager:  
			demon_manager.add_blood(bloodWorth) 
		else:
			pass
		zombie.die()

func bleed(bleed_damage):
	if should_bleed == false:
		bleed_tick_damage = bleed_damage
		bleed_proc_timer = Timer.new()
		bleed_proc_timer.autostart = false
		bleed_proc_timer.one_shot = false
		bleed_proc_timer.wait_time = time_between_bleed
		bleed_proc_timer.timeout.connect(bleed_tick)
		add_child(bleed_proc_timer)
		bleed_proc_timer.start()
		should_bleed = true 

func bleed_tick():
	take_damage(bleed_tick_damage)



#Applies small passive health regen and determines injured status 
func _process(_delta):
	if health < maxHealth:
		health += healthRegen
		injured = health < halfHealth

		
# Returns the health to it's original value 
func resetHealth():
	health = maxHealth
	injured = false
	


#Sets explode to true
func willExplodeFromDrone():
	explode_from_drone = true


	
