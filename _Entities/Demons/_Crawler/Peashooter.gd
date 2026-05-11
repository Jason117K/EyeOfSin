extends Demon
#Peashooter.gd


#@export var attack_speed = 5 
@export var cost = 75

var projectile_scene = preload("res://_Entities/Demons/_Crawler/PeaProjectile.tscn")  # Load the projectile scene
var spiderling_scene = preload("res://_Entities/Demons/_Crawler/spiderling.tscn")
var PlantManager
var canAttack = false   # Whether or not the peashooter can attack 
var second_shot_timer : Timer
var hiveBuffed = false 
var walnutBuffed = false
var sunBuffed = false
var wyrmBuffed = false
var mawBuffed = false
var canAttackSetTrueOnce = false
#var spawnAnimDone = false
#f
# Raycast to detect zombies in front of the spider
@onready var attack_ray = $DMG_RayCast2D
# Reference to the animatedSpriteComponent 
@onready var buffNodes = $BuffNodesComponent
@onready var projectile_shoot_component := $ProjectileShootComponent


#Grab plantmanager, start default anim and connect/start relevant timers 
func _ready():
	super()
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	

#Cost getter 
func get_cost():
	return cost
	
					
# Doubles attack speed when receiving a buff 
func receiveBuff(newPlant):
	#print("Buff Name is ", newPlant.name)
	super(newPlant)
	healthComp.receiveBuff(newPlant)
	animSpriteComp.receiveBuff(newPlant)
	var plantName = truncate_string(newPlant.name)
	
	if !isBuffed :
		
		match plantName:
			"Sunflower":
				sunBuffed = true 
			"Peashooter":
				mawBuffed = true 
			"WalnutTree" :
				walnutBuffed = true 
			"EggWorm":
				wyrmBuffed = true 
			"Hive":
				hiveBuffed = true 
			"Maw":
				mawBuffed = true

#TODO Move to Parent Class
func debuff():
	animSpriteComp.debuff()
	isBuffed = false 

			
func die():
	PlantManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
	
func die_fromClearSpace():
	#print("DD YYYING ---------------------------------")
	buffNodes.clearBuffs()
	queue_free()		
	
	


func _on_spawn_spiderling_timeout() -> void:

	if mawBuffed:
		
		var spiderling = spiderling_scene.instantiate()
		spiderling.position = position + Vector2(8, -4)  # Adjust starting position
		get_parent().add_child(spiderling)  # Add the projectile to the game layer


func _on_mouse_entered() -> void:
	$PreviewNodes/Spider.visible = false
	$PreviewNodes.visible = true 


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 

func get_can_attack():
	return projectile_shoot_component.canAttack
	
	
	
	
	
	
	
