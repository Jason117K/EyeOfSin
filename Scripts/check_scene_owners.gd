tool
extends EditorScript

var all_files = []
var referenced_files = {}
var orphaned_files = []

func _run():
	print("\n=== Starting Orphaned File Check ===")
	
	# First pass: Collect all files
	scan_directory("res://")
	
	# Second pass: Check all scene files for references
	check_scene_references()
	
	# Third pass: Check script files for references
	check_script_references()
	
	# Find orphaned files
	find_orphaned_files()
	
	# Print results
	print("\nOrphaned files found:")
	if orphaned_files.empty():
		print("No orphaned files found!")
	else:
		for file in orphaned_files:
			print("- ", file)
	
	print("\n=== File Check Complete ===")
	print("Total files checked: ", all_files.size())
	print("Orphaned files: ", orphaned_files.size())

func scan_directory(path: String) -> void:
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = path + file_name
			
			if dir.current_is_dir():
				scan_directory(full_path + "/")
			else:
				# Skip import files and temporary files
				if !file_name.begins_with(".") and !file_name.ends_with(".import"):
					all_files.append(full_path)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()

func check_scene_references() -> void:
	for file_path in all_files:
		if file_path.ends_with(".tscn"):
			var file = File.new()
			if file.open(file_path, File.READ) == OK:
				var content = file.get_as_text()
				file.close()
				
				# Check for file references in the scene file
				for other_file in all_files:
					if other_file != file_path:
						var file_name = other_file.get_file()
						if content.find(file_name) != -1:
							referenced_files[other_file] = true

func check_script_references() -> void:
	for file_path in all_files:
		if file_path.ends_with(".gd"):
			var file = File.new()
			if file.open(file_path, File.READ) == OK:
				var content = file.get_as_text()
				file.close()
				
				# Check for file references in the script
				for other_file in all_files:
					if other_file != file_path:
						var file_name = other_file.get_file()
						if content.find(file_name) != -1:
							referenced_files[other_file] = true

func find_orphaned_files() -> void:
	for file_path in all_files:
		# Skip scenes, scripts, and resource files as they're typically root files
		if file_path.ends_with(".tscn") or file_path.ends_with(".gd") or file_path.ends_with(".tres"):
			continue
			
		# If the file isn't referenced anywhere, it's orphaned
		if !referenced_files.has(file_path):
			orphaned_files.append(file_path)
