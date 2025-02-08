extends Area2D
#Bomb.gd

var damage = 100
var enemiesToHit = []
var enemiesToHitTemp
onready var deathTimer = $DeathTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass




# Add this helper function to scripts that deal with combat
func is_instance_valid_and_alive(node) -> bool:
	return is_instance_valid(node) and not node.is_queued_for_deletion()


func _on_DeathTimer_timeout():
	print("WE HEREEEE")
	enemiesToHitTemp = get_overlapping_areas()
	#print("Spawned Bomb : ", enemiesToHitTemp)
	
	for enemy in enemiesToHitTemp:
		#print("Enemy is " , enemy.name)
		if "Zombie" in enemy.name:
			#print("Enemy is " , enemy.name)
			enemiesToHit.append(enemy)
	
	for enemy in enemiesToHit:
		print("About Damage")
		if is_instance_valid_and_alive(enemy):	
			if(enemy != null):
				print("Will NOW DAMAGE")
				var compManager = enemy.getCompManager()
				var healthComp = compManager.getHealthComponent()
				compManager.take_damage(damage)  
	
	print("Spawned Bomb 3")

	print("Ded")
	queue_free()
