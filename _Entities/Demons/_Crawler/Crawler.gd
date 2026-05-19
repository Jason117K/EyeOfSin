extends Demon
#Crawler.gd

@export var spiderling_wait_time := 2
@export var spinalOcculumHealth = 375

@export var damage := 60
@export var attack_speed_mult := 1.0
@export var projectile_spawn_offest: Vector2 = Vector2(32, 0)
@export var blood_worth_to_add := 10.0

var projectile_scene = preload("res://_Entities/Demons/_Crawler/DemonProjectile.tscn")  # Load the projectile scene
var spiderling_scene = preload("res://_Entities/Demons/_Crawler/spiderling.tscn")
var DemonManager
var canAttack = false  
var second_shot_timer : Timer
var spiderling_timer : Timer

var canAttackSetTrueOnce = false

@onready var attack_ray = $DMG_RayCast2D
@onready var buffNodes = $BuffNodesComponent
@onready var projectile_shoot_component := $ProjectileShootComponent

#Grab demonmanager, start default anim and connect/start relevant timers 
func _ready():
	super()
	DemonManager = get_parent().get_parent().get_node("DemonManager")
	

func get_damage():
	return projectile_shoot_component.damage
	
#Cost getter 
func get_cost():
	return cost

func get_demon_name():
	return "CRAWLER"
					
# Doubles attack speed when receiving a buff 
func receive_buff(newDemon):
	#print("Buff Name is ", newDemon.name)

	var demonName = truncate_string(newDemon.name)
	
	if !isBuffed :
		super(demonName)
		projectile_shoot_component.receive_buff(demonName)
		match demonName:
			"Occulum":
				pass 
			"Crawler":
				pass
			"SpinalOcculum" :
				pass
			"Wyrm":
				pass
			"Hive":
				pass
			"Maw":
				spiderling_timer = Timer.new()
				spiderling_timer.wait_time = spiderling_wait_time
				spiderling_timer.one_shot = false
				spiderling_timer.timeout.connect(_on_spawn_spiderling_timeout)
				add_child(spiderling_timer)
				spiderling_timer.start()

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
	if mawBuff:
		var spiderling = spiderling_scene.instantiate()
		spiderling.position = position + Vector2(8, -4) 
		if self.is_in_group("Green"):
			spiderling.add_to_group("Green")
		else:
			spiderling.add_to_group("Purple")
		get_parent().add_child(spiderling)  

func _on_mouse_entered() -> void:
	$PreviewNodes/Spider.visible = false
	$PreviewNodes.visible = true 

func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 

func get_can_attack():
	return projectile_shoot_component.canAttack
	
	
	
	
	
	
	
