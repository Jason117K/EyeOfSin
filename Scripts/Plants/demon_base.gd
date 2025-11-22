extends Area2D

class_name Demon 

var isCurrentlyBuffed := false 

var animSpriteComp

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
			
		animSpriteComp.make_buff_glow()


func truncate_string(input_string: String) -> String:
	for i in range(input_string.length()):
		var character = input_string[i]
		if character.is_valid_int():
			return input_string.substr(0, i)
	return input_string
