extends Area2D

class_name Demon 

#Handle Area Detection for Buffs, Buffs, Storing Cost, Showing Preview Nodes

var isCurrentlyBuffed := false 
var area : Area2D
var isBuffed := false

@onready var animSpriteComp := $AnimatedSpriteComponent
@onready var healthComp := $HealthComponent

func _ready() -> void:
	pass
	await get_tree().physics_frame
	print(self, " Heart Connect")
	for new_area in get_overlapping_areas():
		print("New Area is ", new_area)
		if new_area.is_in_group("HeartBuff"):
			receive_heart_buff()
	self.area_entered.connect(on_demon_area_entered)
	#self.area_exited.connect(on_demon_area_exited)
	
func on_demon_area_entered(new_area: Area2D):
	#print(self, "New Area Heart is ", new_area)
	if new_area.is_in_group("HeartBuff"):
		#print(self, "will now receive heart buff")
		pass
		#receive_heart_buff()
		
func on_demon_area_exited(old_area: Area2D):
	if old_area.is_in_group("HeartBuff"):
		remove_heart_buff()		
	
#TODO Call ReceiveBuff On ALL Components Here
#TODO Set All isDemonBuffed Variables Here As Well
func receiveBuff(newPlant):
	#print("Buff Name is ", newPlant.name)
	var plantName = truncate_string(newPlant.name)
	
	if !isCurrentlyBuffed :
		print(self.name, " Buff Received from ", plantName)
		match plantName:
			"Sunflower":
				animSpriteComp.change_form("Sunflower")
			"Peashooter":
				print("Change to SPIDER")
				animSpriteComp.change_form("Peashooter")
			"WalnutTree" :
				animSpriteComp.change_form("Walnut")
			"EggWorm":
				animSpriteComp.change_form("Wyrm")
			"Hive":
				animSpriteComp.change_form("Wasp")
			"Maw":
				animSpriteComp.change_form("Maw")

		
		isCurrentlyBuffed = true 
			
		#animSpriteComp.make_buff_glow()


func truncate_string(input_string: String) -> String:
	for i in range(input_string.length()):
		var character = input_string[i]
		if character.is_valid_int():
			return input_string.substr(0, i)
	return input_string
	
func receive_heart_buff():
	print(self.name , " receive Heart Buff")
	$BuffNodesComponent.get_child(0).visible = true 
	increase_max_health(400)
	increase_health(400)
	pass
	
func remove_heart_buff():
	print(self.name , " remove Heart Buff")
	$BuffNodesComponent.get_child(0).visible = false 
	pass
	
func finish_spawn():
	animSpriteComp.visible = true		
	animSpriteComp.animation = animSpriteComp.currentAnim
	animSpriteComp.play()

func get_is_buffed():
	return isBuffed

func increase_health(added_health_amount):
	if healthComp.is_node_ready():
		healthComp.increase_health(added_health_amount)

func increase_max_health(added_health_amount):
	healthComp.increase_max_health(added_health_amount)

func take_damage(damage):
	#print(self, " is now taking damage : ", damage)
	healthComp.take_damage(damage)

func get_health():
	#print(self, " now getting the health")
	return healthComp.get_health()
	
	
	
	
	
	
	
	
	
	
