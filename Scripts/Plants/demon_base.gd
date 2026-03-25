extends Area2D

class_name Demon 

var isCurrentlyBuffed := false 
var area : Area2D
var animSpriteComp

func _ready() -> void:
	pass
	print(self, " Heart Connect")
	self.area_entered.connect(on_demon_area_entered)
	self.area_exited.connect(on_demon_area_exited)
	
func on_demon_area_entered(new_area: Area2D):
	print(self, "New Area Heart is ", new_area)
	if new_area.is_in_group("HeartBuff"):
		print(self, "will now receive heart buff")
		receive_heart_buff()
		
func on_demon_area_exited(old_area: Area2D):
	if old_area.is_in_group("HeartBuff"):
		remove_heart_buff()		
	
	
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
	#print(self.name , " receive Heart Buff")
	$BuffNodesComponent.get_child(0).visible = true 
	self.health = self.health + 400
	pass
	
func remove_heart_buff():
	#print(self.name , " remove Heart Buff")
	$BuffNodesComponent.get_child(0).visible = false 
	pass
