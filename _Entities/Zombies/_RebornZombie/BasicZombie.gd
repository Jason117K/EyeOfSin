extends Zombie
# BasicZombie.gd

# Handles Any Basic Zombie Specific Logic 

func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)

func _ready() -> void:
	super()
	#print_scene_tree()
	

#Kills the Zombie 
func die():
	if compManager.spawn_slow_field == true :
		spawn_slow_field_on_death()
	#if compMana
	#print("Should die")
	zombie_death.emit()
	$AnimatedSprite2D.isDead = true 
	$AnimatedSprite2D.play("death")
	#queue_free()


func kill_zombie():
	queue_free()


func get_zombie_name():
	return " REBORN "
	
	
	
	
	
