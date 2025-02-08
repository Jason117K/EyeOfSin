extends Area2D
#Bomb.gd

# Spawns Bomb that explodes and damages all zombies in the area 

export var damage = 100 # Adjustable damage  
var enemiesToHit = [] # Stores all the valid enemies to hit 
var enemiesToHitTemp # Stores enemies to hit, some of which are invalid targets
onready var deathTimer = $DeathTimer # Timer to trigger explosion and destroy bomb


# Add this helper function to scripts that deal with combat
func is_instance_valid_and_alive(node) -> bool:
	return is_instance_valid(node) and not node.is_queued_for_deletion()

# Triggers explosion and destroys bomb
func _on_DeathTimer_timeout():
	# Get all areas, some of which are enemies, some aren't 
	enemiesToHitTemp = get_overlapping_areas()
	#print("Spawned Bomb : ", enemiesToHitTemp)
	
	# Gets & stores all the actual zombies from enemiesToHitTemp 
	for enemy in enemiesToHitTemp:
		if "Zombie" in enemy.name:
			enemiesToHit.append(enemy)
	
	# Damages all enemies in area after checking they are still valid and alive
	for enemy in enemiesToHit:
		if is_instance_valid_and_alive(enemy):	
			if(enemy != null):
				var compManager = enemy.getCompManager()
				var healthComp = compManager.getHealthComponent()
				compManager.take_damage(damage)  
	queue_free()
