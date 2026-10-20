@tool
extends EditorScript
## Snapshots every zombie and demon scene into a new stats set:
## res://_Utilities/Stats/Sets/set_v<N>/ holds one config per unit plus
## set_v<N>.tres listing them. Each unit's values include its assigned Stats
## slot config, so activating a fresh set changes nothing. Edit the unit files
## in that folder for the next balance pass, then assign the set to
## GameController's Stats Set. Each set has its own copies.
## Run from the Script editor with any scene open: File > Run (Ctrl+Shift+X).

const SEARCH_DIRS: Array[String] = ["res://_Entities/Zombies", "res://_Entities/Demons"]
const SETS_DIR := "res://_Utilities/Stats/Sets"


func _run() -> void:
	var n := 1
	while DirAccess.dir_exists_absolute(SETS_DIR.path_join("set_v%d" % n)):
		n += 1
	var set_name := "set_v%d" % n
	var dir := SETS_DIR.path_join(set_name)
	DirAccess.make_dir_recursive_absolute(dir)

	var stats_set := StatsSet.new()
	stats_set.notes = "Captured from the unit scenes on %s." % Time.get_date_string_from_system()
	var used_names := {}
	for scene_path in _find_scenes():
		var scene := load(scene_path) as PackedScene
		if scene == null:
			continue
		var root := scene.instantiate()
		var stats: UnitStats = null
		# Empty blockers are demons too, but have no stats worth tuning.
		if root.get("is_empty") != true:
			stats = StatsCapture.capture(root, true)
		var unit_name := String(root.name).to_snake_case()
		root.free()
		if stats == null:
			continue

		var file_name := unit_name
		var k := 2
		while used_names.has(file_name):
			file_name = "%s_%d" % [unit_name, k]
			k += 1
		used_names[file_name] = true
		var path := dir.path_join(file_name + ".tres")
		# FLAG_CHANGE_PATH, so the set references this file instead of embedding a copy.
		var err := ResourceSaver.save(stats, path, ResourceSaver.FLAG_CHANGE_PATH)
		if err != OK:
			push_error("Capture set: saving %s failed (%s)." % [path, error_string(err)])
			continue

		var entry := StatsSetEntry.new()
		# A uid:// reference survives the scene being moved or renamed.
		var uid := ResourceLoader.get_resource_uid(scene_path)
		entry.unit_scene = ResourceUID.id_to_text(uid) if uid != ResourceUID.INVALID_ID else scene_path
		entry.stats = stats
		stats_set.entries.append(entry)
		print("  %s -> %s" % [scene_path, path])

	var set_path := dir.path_join(set_name + ".tres")
	var set_err := ResourceSaver.save(stats_set, set_path)
	if set_err != OK:
		push_error("Capture set: saving %s failed (%s)." % [set_path, error_string(set_err)])
		return
	EditorInterface.get_resource_filesystem().scan()
	print("Captured stats set: %s (%d units)" % [set_path, stats_set.entries.size()])


func _find_scenes() -> Array[String]:
	var found: Array[String] = []
	var to_visit: Array[String] = SEARCH_DIRS.duplicate()
	while not to_visit.is_empty():
		var d: String = to_visit.pop_back()
		for sub in DirAccess.get_directories_at(d):
			to_visit.append(d.path_join(sub))
		for f in DirAccess.get_files_at(d):
			if f.get_extension() == "tscn":
				found.append(d.path_join(f))
	found.sort()
	return found
