@tool
extends EditorScript
## Saves the open zombie/demon scene's current values as a new numbered stat
## config: <scene folder>/Stats/<root name>_v<N>.tres (e.g. reborn_v1.tres).
## Run from the Script editor with the unit scene open: File > Run (Ctrl+Shift+X).
## Reads the SCENE's values, not an assigned config: to fork a version, duplicate
## its .tres instead. Does not assign the new file; drag it into the Stats slot.
## Per-type classes are mapped in StatsCapture.TYPE_STATS.


func _run() -> void:
	var root := get_scene()
	if root == null or root.get_script() == null:
		push_error("Capture stats: open a zombie or demon scene first.")
		return
	var stats := StatsCapture.capture(root)
	if stats == null:
		push_error("Capture stats: '%s' is not a zombie or demon scene." % root.name)
		return

	var dir := root.scene_file_path.get_base_dir().path_join("Stats")
	DirAccess.make_dir_recursive_absolute(dir)
	var base := String(root.name).to_snake_case()
	var n := 1
	while FileAccess.file_exists(dir.path_join("%s_v%d.tres" % [base, n])):
		n += 1
	var path := dir.path_join("%s_v%d.tres" % [base, n])

	var err := ResourceSaver.save(stats, path)
	if err != OK:
		push_error("Capture stats: saving %s failed (%s)." % [path, error_string(err)])
		return
	EditorInterface.get_resource_filesystem().scan()
	print("Captured stats: ", path)
