extends Area2D
#Bomb.gd

var damage = 100
var enemiesToHit = []
var enemiesToHitTemp
onready var deathTimer = $DeathTimer

# Called when the node enters the scene tree for the first time.
func _ready():

	enemiesToHitTemp = get_overlapping_areas()
	print("Spawned Bomb : ", enemiesToHitTemp)
	
	for enemy in enemiesToHitTemp:
		print("Enemy is " , enemy.name)
		if "Zombie" in enemy.name:
			enemiesToHit.append(enemy)
	print("Spawned Bomb 2")		
	for enemy in enemiesToHit:
		if not is_instance_valid_and_alive(enemy):	
			if(enemy != null):
				var compManager = enemy.getCompManager()
				var healthComp = compManager.getHealthComponent()
				compManager.take_damage(damage)  
	deathTimer.start()
	print("Spawned Bomb 3")



# Add this helper function to scripts that deal with combat
func is_instance_valid_and_alive(node) -> bool:
	return is_instance_valid(node) and not node.is_queued_for_deletion()


func _on_DeathTimer_timeout():
	print("Ded")
	queue_free()
