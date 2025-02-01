tool
extends EditorScript

var diagram := ""
var processed_files := []
var project_dir := "res://"

func _run():
	diagram = "graph TD\n"
	scan_directory(project_dir)
	print(diagram)
	
func scan_directory(path: String) -> void:
	var dir := Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name := dir.get_next()
		
		while file_name != "":
			var full_path = path + "/" + file_name
			
			if dir.current_is_dir():
				scan_directory(full_path)
			else:
				process_file(full_path)
				
			file_name = dir.get_next()
			
func process_file(path: String) -> void:
	if path in processed_files:
		return
		
	processed_files.append(path)
	
	if path.ends_with(".tscn"):
		process_scene(path)
	elif path.ends_with(".gd"):
		process_script(path)

func process_scene(path: String) -> void:
	var packed_scene = load(path) as PackedScene
	if not packed_scene:
		return
		
	var scene_name := path.get_file().get_basename()
	
	# Add node for the scene
	add_node(scene_name, "scene")
	
	# Parse scene file for script references
	var file := File.new()
	if file.open(path, File.READ) == OK:
		var content := file.get_as_text()
		file.close()
		
		# Look for script references
		var regex := RegEx.new()
		regex.compile('script = ExtResource\\( "(.+)" \\)')
		var results := regex.search_all(content)
		
		for result in results:
			var script_path = result.get_string(1)
			var script_name = script_path.get_file().get_basename()
			add_node(script_name, "script")
			add_connection(scene_name, script_name)

func process_script(path: String) -> void:
	var file := File.new()
	if file.open(path, File.READ) == OK:
		var content := file.get_as_text()
		file.close()
		
		var script_name := path.get_file().get_basename()
		add_node(script_name, "script")
		
		# Look for extends
		var regex := RegEx.new()
		regex.compile('extends (.+)')
		var result := regex.search(content)
		if result:
			var parent = result.get_string(1)
			if parent != "Node" and parent != "Node2D" and parent != "Control":
				add_node(parent, "class")
				add_connection(script_name, parent)
		
		# Look for preloads and loads
		regex.compile('(preload|load)\\(["|\'](.+)["|\']\\)')
		var results := regex.search_all(content)
		for result1 in results:
			var dep_path = result1.get_string(2)
			var dep_name = dep_path.get_file().get_basename()
			if dep_name != script_name:  # Avoid self-references
				add_node(dep_name, "dependency")
				add_connection(script_name, dep_name)

func add_node(name: String, type: String) -> void:
	var style := ""
	match type:
		"scene":
			style = "style " + name + " fill:#f9f,stroke:#333,stroke-width:2px"
		"script":
			style = "style " + name + " fill:#bbf,stroke:#333,stroke-width:2px"
		"class":
			style = "style " + name + " fill:#bfb,stroke:#333,stroke-width:2px"
		"dependency":
			style = "style " + name + " fill:#fbb,stroke:#333,stroke-width:2px"
			
	if not diagram.find(style) >= 0:
		diagram += style + "\n"

func add_connection(from_node: String, to_node: String) -> void:
	var connection := from_node + " --> " + to_node + "\n"
	if not diagram.find(connection) >= 0:
		diagram += connection
