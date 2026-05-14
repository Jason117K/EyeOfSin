extends Demon
#Crawler.gd

@export var cost = 75

var projectile_scene = preload("res://_Entities/Demons/_Crawler/DemonProjectile.tscn")  # Load the projectile scene
var spiderling_scene = preload("res://_Entities/Demons/_Crawler/spiderling.tscn")
var DemonManager
var canAttack = false  
var second_shot_timer : Timer
var hiveBuffed = false 
var spinalOcculumBuffed = false
var occulumBuffed = false
var wyrmBuffed = false
var mawBuffed = false
var canAttackSetTrueOnce = false

@onready var attack_ray = $DMG_RayCast2D
@onready var buffNodes = $BuffNodesComponent
@onready var projectile_shoot_component := $ProjectileShootComponent

#Grab demonmanager, start default anim and connect/start relevant timers 
func _ready():
	super()
	DemonManager = get_parent().get_parent().get_node("DemonManager")
	

#Cost getter 
func get_cost():
	return cost
	
					
# Doubles attack speed when receiving a buff 
func receiveBuff(newDemon):
	#print("Buff Name is ", newDemon.name)
	super(newDemon)
	healthComp.receiveBuff(newDemon)
	animSpriteComp.receiveBuff(newDemon)
	var demonName = truncate_string(newDemon.name)
	
	if !isBuffed :
		
		match demonName:
			"Occulum":
				occulumBuffed = true 
			"Crawler":
				mawBuffed = true 
			"SpinalOcculum" :
				spinalOcculumBuffed = true 
			"Wyrm":
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
	DemonManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()	
	
func die_fromClearSpace():
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
	
	
	
	
	
	
	
