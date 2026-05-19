extends Demon
#SpinalOcculum.gd

@export var cost = 100
@export var aoeDamage = 4
@export var lightning_damage := 10

@onready var AOEComp = $AOEDamageComponent
@onready var buffNodes = $BuffNodesComponent
@onready var web := $Web
@onready var spike_rock := $SpikeRock
@onready var silence_field := $SilenceField
@onready var maw_lightning := $LightningCrackle
var is_lightning_maw_buff := false 

var DemonManager
var phantomHive = preload("res://_Entities/Demons/_Hive/phantom_hive.tscn")
var can_damage_zombie= false 
var bloodScene = preload("res://_Entities/Demons/Blood/Blood.tscn")  

func _ready():
	super()
	DemonManager = get_parent().get_parent().get_node("DemonManager")
	

func receive_buff(bufferName):
	var demonName = truncate_string(bufferName.name)
	
	if !isBuffed :
		super(demonName)
		match demonName:
			"Occulum":
				pass
			"Crawler":
				if self.is_in_group("Green"):
					web.add_to_group("Green")
				else:
					web.add_to_group("Purple")
				web.activate()
			"SpinalOcculum" :
				pass
			"Wyrm":
				spike_rock.activate()
				
			"Hive":
				silence_field.activate()
				pass
				#spawnPhantomHive()
			"Maw":
				lightning_maw_buff()
				pass


	


func debuff():
	healthComp.debuff()
	#Call Debuff On Rest of Components Here
	isBuffed = false

func get_demon_name():
	return "SPINAL OCCULUM"
	
func get_cost():
	return cost


#TODO Move to AOE Damage Component that gets Added
func _on_aoe_damage_timer_timeout() -> void:
	if wyrmBuff:
		for area in AOEComp.get_overlapping_areas():
			if area.is_in_group("Zombies"):
				area.take_damage(aoeDamage) 
			
func lightning_maw_buff():
	maw_lightning.play()
	maw_lightning.show()
	
	is_lightning_maw_buff = true 

func get_lightning_damage():
	return lightning_damage
			
func die():
	DemonManager.clear_space(self.global_position)
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
	#Set the blood pos to above the occulum
	hive_instance.global_position = self.global_position 


#TODO Move to Slow Field Component That Gets Added
func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area , " just entered spinal occulum snow field  ")
	if area.is_in_group("Zombie"):
		print("Zombie Entered Slow Field")
		#if area.get_parent().get_parent() != self.get_parent().get_parent():
			#return
		#TODO Balance
		area.slow()

#TODO Move to Parent Class
func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSpriteComponent2.visible = false
	$PreviewNodes.visible = true 


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false 
	
	
func get_damage():
	return "NONE"
