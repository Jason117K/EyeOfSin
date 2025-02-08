tool
extends EditorScript

# This script checks for scenes without owners in your Godot project
# To use: Place in your project, select it in Script Editor, then click "Run"

func _run():
	print("\n=== Starting Scene Owner Check ===")
	var dir = Directory.new()
	scan_directory("res://", dir)
	print("=== Scene Owner Check Complete ===\n")

func scan_directory(path: String, dir: Directory) -> void:
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = path + file_name
			
			if dir.current_is_dir():
				scan_directory(full_path + "/", dir)
			elif file_name.ends_with(".tscn"):
				check_scene_owner(full_path)
				
			file_name = dir.get_next()
			
		dir.list_dir_end()

func check_scene_owner(scene_path: String) -> void:
	var packed_scene = load(scene_path)
	if not packed_scene:
		print("WARNING: Could not load scene: ", scene_path)
		return
		
	var scene = packed_scene.instance()
	var has_owner = false
	
	# Check if the root node has an owner
	if scene.owner != null:
		has_owner = true
	
	# Check all child nodes recursively
	var nodes_without_owner = []
	check_node_owner(scene, nodes_without_owner)
	
	if nodes_without_owner.size() > 0:
		print("\nScene: ", scene_path)
		print("Nodes without owners:")
		for node_path in nodes_without_owner:
			print("  - ", node_path)
	
	scene.free()

func check_node_owner(node: Node, nodes_without_owner: Array) -> void:
	for child in node.get_children():
		if child.owner == null:
			nodes_without_owner.append(str(child.get_path()))
		check_node_owner(child, nodes_without_owner)
