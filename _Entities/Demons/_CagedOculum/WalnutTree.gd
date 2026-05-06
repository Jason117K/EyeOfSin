extends Demon
#WalnutTree.gd

#var spawnAnimDone = false
var isEggWyrmBuffed := false 
var isMawBuffed := false 
var isSunflowerBuffed:= false 
var hiveBuffed:= false
var sunBuffed = false

@export var cost = 100
@export var aoeDamage = 4

var PlantManager
@onready var AOEComp = $AOEDamageComponent
@onready var buffNodes = $BuffNodesComponent


var eggWyrmBuffed := false 
var thisBufferName : String
var phantomHive = preload("res://_Entities/Demons/_Hive/phantom_hive.tscn")
var can_damage_zombie= false 

var bloodScene = preload("res://_Entities/Demons/Blood/Sun.tscn")  

#Grabs reference to plantManager 
func _ready():
	super()
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	


func receiveBuff(bufferName):
	if !isBuffed :
		super(bufferName)
		healthComp.receiveBuff(bufferName)
		
		if "Sun" in bufferName.name && !isSunflowerBuffed:
			sunBuffed = true 
			isSunflowerBuffed = true 
		elif "EggWorm" in bufferName.name && !isEggWyrmBuffed:
			eggWyrmBuffed = true 
			isEggWyrmBuffed = true 
			can_damage_zombie = true 
		elif "Maw" in bufferName.name && !isMawBuffed:
			isMawBuffed = true 
			#TODO Re Implement Color Changes
			#$AnimatedSpriteComponent.change_color()
		elif "Pea" in bufferName.name :
			$Web.visible  = true 
			$Web/Area2D.monitoring= true
		elif "Hive" in bufferName.name:
			spawnPhantomHive()
		thisBufferName = bufferName.name
		isBuffed = true 

func debuff():
	healthComp.debuff()
	#Call Debuff On Rest of Components Here
	isBuffed = false

		


		
#Cost getter
func get_cost():
	#print("Walnut returning cost of ", cost)
	return cost
	
	
#func spawn_done():
	#if spawnAnimDone:
		#pass
	#else:
		#spawnAnimDone = true 
	

#TODO Move to AOE Damage Component that gets Added
func _on_aoe_damage_timer_timeout() -> void:
	if eggWyrmBuffed:
		for area in AOEComp.get_overlapping_areas():
			if area.is_in_group("Zombies"):
				var compManager = area.getCompManager()
				compManager.take_damage(aoeDamage) 
			
		
func die():
	PlantManager.clear_space(self.global_position)
	if buffNodes != null:
		buffNodes.clearBuffs()
	queue_free()			
	
func die_fromClearSpace():
	if buffNodes != null:
		buffNodes.clearBuffs()
	queue_free()				
		

#TODO Move to PhantomHiveSpawner Component That Gets Added
func spawnPhantomHive():
	var hive_instance = phantomHive.instantiate()
	print("Spawn HIVE")
	get_parent().add_child(hive_instance)  # Add the phantom hive to the scene as a child of gamelayer
	#Set the sun pos to above the sunflower
	hive_instance.global_position = self.global_position 



#TODO Move to Slow Field Component That Gets Added
func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area , " just entered walnut snow field  ")
	if area.is_in_group("Zombie"):
		print("Zombie Entered Slow Field")
		#if area.get_parent().get_parent() != self.get_parent().get_parent():
			#return
		var compManager = area.getCompManager()
		var enemyHealthComp = compManager.getHealthComponent()
		#TODO Balance
		compManager.slow()



func walnutWyrmBuffed():
	pass
	


func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSpriteComponent2.visible = false
	$PreviewNodes.visible = true 


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 
