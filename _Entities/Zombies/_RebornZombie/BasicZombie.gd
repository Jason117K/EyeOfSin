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

func kill_zombie():
	die()
	#queue_free()


func get_zombie_name():
	return " REBORN "
	
	
	
	
	
