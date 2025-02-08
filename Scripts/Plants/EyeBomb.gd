extends Node2D
#EyeBomb.gd

#Component References
onready var spriteComp = $AnimSpriteComponent
onready var hitBoxComp = $HitBoxComponent

export var cost = 25 
export var damage = 10 #explosion damage 

var enemiesToHit = []  #Stores reference to valid enemy 
var enemiesToHitTemp   #Stores reference to enemy targets, both valid and invalid
var startNum = 0       #Makes sure the eye only explodes once  


#Returns the plant cost 
func get_cost():
	return cost


#Add zombies to the list of enemies to hit & start the explosion
func _on_DetectionComponent_area_entered(area):
	if "Zombie" in area.name:
		#Start the explosion and only do it the first time the area is entered 
		if(startNum == 0):
			#print("Boom Time")
			spriteComp.animation = "boom"
			spriteComp.scale = Vector2(1.1,1.1)
			enemiesToHitTemp = hitBoxComp.get_overlapping_areas()
			for enemy in enemiesToHitTemp:
				#print(enemy.name)
				if "Zombie" in enemy.name:
					enemiesToHit.append(enemy)
					
			startNum = startNum + 1

#Method stub for future buff implementation
func receiveBuff(bufferName):
	pass
	
#Damages enemies on explosion finish, looping through array 
func _on_SpriteComponent_animation_finished():
	if(spriteComp.animation == "default"):
		pass
	elif(spriteComp.animation == "boom"):
		for enemy in enemiesToHit:
			if not is_instance_valid_and_alive(enemy):	
				continue
			if(enemy != null):
				var compManager = enemy.getCompManager()
				var healthComp = compManager.getHealthComponent()
				compManager.take_damage(damage)  
		
# Add this helper function to scripts that deal with combat
func is_instance_valid_and_alive(node) -> bool:
	return is_instance_valid(node) and not node.is_queued_for_deletion()

# Delete the eyebomb on explosion completion 
func _on_SpriteComponent_frame_changed():
	if spriteComp.frame == 9:
		queue_free()
