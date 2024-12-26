extends Node2D


onready var spriteComp = $SpriteComponent
onready var hitBoxComp = $HitBoxComponent

var startNum = 0
var damage = 10
var enemiesToHit = []
var enemiesToHitTemp

export var cost = 25


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

				#print(enemy.name)
			#	var compManager = enemy.getCompManager()
			#	var healthComp = compManager.getHealthComponent()
			#	compManager.take_damage(damage)  
func _on_DetectionComponent_area_entered(area):
	if "Zombie" in area.name:
		#print("StartNum is ",startNum)
		if(startNum == 0):
			print("Boom Time")
			spriteComp.animation = "boom"
			spriteComp.scale = Vector2(1.1,1.1)
			enemiesToHitTemp = hitBoxComp.get_overlapping_areas()
			for enemy in enemiesToHitTemp:
				#print(enemy.name)
				if "Zombie" in enemy.name:
					enemiesToHit.append(enemy)
					
			
			startNum = startNum + 1

func receiveBuff(bufferName):
	pass
	
func _on_SpriteComponent_animation_finished():
	if(spriteComp.animation == "default"):
		pass
	elif(spriteComp.animation == "boom"):
		
		#print("done with boom")
		for enemy in enemiesToHit:
			if not is_instance_valid_and_alive(enemy):	
				continue
			if(enemy != null):
				#print(enemy)
				var compManager = enemy.getCompManager()
				var healthComp = compManager.getHealthComponent()
				compManager.take_damage(damage)  
		#queue_free()
		
func get_cost():
	return cost

# Add this helper function to scripts that deal with combat
func is_instance_valid_and_alive(node) -> bool:
	return is_instance_valid(node) and not node.is_queued_for_deletion()


func _on_SpriteComponent_frame_changed():
	if spriteComp.frame == 9:
		queue_free()
