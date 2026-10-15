@tool
extends RefCounted

## Named snapshots ("presets") of a scene's wave tables, saved as JSON so a level's
## wave config can be swapped out and restored later. The scene stays the source of
## truth: loading a preset is one undoable edit that you then save with the scene.
##
## Layout: <scene folder>/WavePresets/<preset>/<scene file name>.json — one file per
## dimension, so Purple and Green share preset names and each save touches only its
## own file. WavePresets/ carries a .gdignore, so presets are never imported or exported.
##
## No class_name on purpose, same as wave_table_io.gd. Use it via
##   const PresetIO := preload("res://addons/wave_table_editor/wave_preset_io.gd")

const IO := preload("res://addons/wave_table_editor/wave_table_io.gd")

const FOLDER := "WavePresets"
const FORMAT := 1
## Level-root exports saved alongside the waves: the gaps between wave starts
## (level_template.gd). Only the Purple level script reads them.
const ROOT_KEYS: Array[String] = [
	"wave2StartTime", "wave3StartTime", "wave4StartTime", "wave5StartTime", "wave6StartTime",
]


#region Paths

## <scene folder>/WavePresets, or "" if the scene has never been saved.
static func presets_dir(scene_root: Node) -> String:
	if scene_root == null or scene_root.scene_file_path.is_empty():
		return ""
	return scene_root.scene_file_path.get_base_dir().path_join(FOLDER)


## Where this scene's half of a preset lives, e.g. .../WavePresets/L10 v1/Level10.json.
static func half_path(dir: String, preset: String, scene_root: Node) -> String:
	var file_name := scene_root.scene_file_path.get_file().get_basename() + ".json"
	return dir.path_join(preset).path_join(file_name)


## Preset names are folder names.
static func clean_name(preset: String) -> String:
	return preset.strip_edges().validate_filename().lstrip(".")


static func list_presets(dir: String) -> PackedStringArray:
	var out := PackedStringArray()
	if dir.is_empty() or not DirAccess.dir_exists_absolute(dir):
		return out
	out = DirAccess.get_directories_at(dir)
	out.sort()
	return out


static func has_half(dir: String, preset: String, scene_root: Node) -> bool:
	if dir.is_empty() or preset.is_empty():
		return false
	return FileAccess.file_exists(half_path(dir, preset, scene_root))

#endregion


#region Save / read

static func save(dir: String, preset: String, scene_root: Node,
		spawners: Array[ZombieSpawner]) -> Error:
	preset = clean_name(preset)
	if dir.is_empty() or preset.is_empty():
		return ERR_INVALID_PARAMETER

	var err := DirAccess.make_dir_recursive_absolute(dir.path_join(preset))
	if err != OK:
		return err
	var ignore_path := dir.path_join(".gdignore")
	if not FileAccess.file_exists(ignore_path):
		var marker := FileAccess.open(ignore_path, FileAccess.WRITE)
		if marker == null:
			return FileAccess.get_open_error()
		marker.close()

	var file := FileAccess.open(half_path(dir, preset, scene_root), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(to_data(scene_root, spawners), "\t", false) + "\n")
	file.close()
	return OK


static func to_data(scene_root: Node, spawners: Array[ZombieSpawner]) -> Dictionary:
	var root_values := {}
	for key: String in ROOT_KEYS:
		if key in scene_root:
			root_values[key] = scene_root.get(key)

	var spawner_data := {}
	for spawner: ZombieSpawner in spawners:
		var waves: Array = []
		for wave: WaveData in spawner.waves:
			var entries: Array = []
			if wave != null:
				for entry: WaveEntry in wave.entries:
					if entry != null:
						entries.append({"type": entry.type, "count": entry.count})
			waves.append(entries)
		spawner_data[str(scene_root.get_path_to(spawner))] = {
			"is_random": spawner.is_random,
			"waves": waves,
		}

	return {
		"format": FORMAT,
		"scene": scene_root.scene_file_path,
		"saved": Time.get_datetime_string_from_system(false, true),
		"root": root_values,
		"spawners": spawner_data,
	}


## The parsed preset, or {} if the file is missing or unreadable.
static func read(dir: String, preset: String, scene_root: Node) -> Dictionary:
	var path := half_path(dir, preset, scene_root)
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		var data: Dictionary = parsed
		if data.get("spawners") is Dictionary:
			return data
	push_warning("Wave preset: could not read %s" % path)
	return {}

#endregion


#region Apply

## Replace each matching spawner's waves + is_random, and the root's wave gaps, with
## the preset's — all as ONE undo step. Spawners are matched by path from the scene
## root; anything that doesn't match is left alone. Returns warnings (empty = clean).
static func commit_apply(plugin: EditorPlugin, scene_root: Node,
		spawners: Array[ZombieSpawner], data: Dictionary, preset: String) -> Array[String]:
	var warnings: Array[String] = []
	if plugin == null or scene_root == null:
		return warnings

	var saved: Dictionary = data.get("spawners", {})
	var root_values: Dictionary = data.get("root", {})
	var scene_waves := IO.max_wave_count(spawners)
	var preset_waves := 0
	var matched := {}

	var undo_redo := plugin.get_undo_redo()
	undo_redo.create_action("Load wave preset '%s'" % preset, UndoRedo.MERGE_DISABLE, scene_root)

	for spawner: ZombieSpawner in spawners:
		var key := str(scene_root.get_path_to(spawner))
		if not saved.has(key) or saved[key] is not Dictionary:
			warnings.append("%s isn't in the preset; left as is." % spawner.name)
			continue
		matched[key] = true
		var spawner_data: Dictionary = saved[key]
		var waves := _waves_from_data(spawner_data.get("waves", []), spawner.name, warnings)
		preset_waves = maxi(preset_waves, waves.size())

		undo_redo.add_do_property(spawner, "waves", waves)
		undo_redo.add_undo_property(spawner, "waves", IO.snapshot(spawner.waves))
		undo_redo.add_do_property(spawner, "is_random", bool(spawner_data.get("is_random", true)))
		undo_redo.add_undo_property(spawner, "is_random", spawner.is_random)
		undo_redo.add_do_method(spawner, "notify_property_list_changed")
		undo_redo.add_undo_method(spawner, "notify_property_list_changed")

	for key: String in saved:
		if not matched.has(key):
			warnings.append("Preset spawner %s isn't in this scene; skipped." % key)

	for key: String in ROOT_KEYS:
		if root_values.has(key) and key in scene_root:
			undo_redo.add_do_property(scene_root, key, int(root_values[key]))
			undo_redo.add_undo_property(scene_root, key, scene_root.get(key))

	undo_redo.commit_action()

	if not matched.is_empty() and preset_waves != scene_waves:
		warnings.append(("The preset has %d waves; the scene had %d. The real wave count comes "
				+ "from the level script's wave_delays, so check it.") % [preset_waves, scene_waves])
	return warnings


static func _waves_from_data(raw: Variant, spawner_name: String,
		warnings: Array[String]) -> Array[WaveData]:
	var out: Array[WaveData] = []
	if raw is not Array:
		return out
	for raw_wave: Variant in raw:
		var entries: Array[WaveEntry] = []
		if raw_wave is Array:
			for raw_entry: Variant in raw_wave:
				if raw_entry is not Dictionary:
					continue
				var entry_data: Dictionary = raw_entry
				var type := str(entry_data.get("type", ""))
				if not ZombieRegistry.SCENES.has(type):
					warnings.append("%s: unknown zombie type '%s' skipped." % [spawner_name, type])
					continue
				var entry := WaveEntry.new()
				entry.type = type
				entry.count = int(entry_data.get("count", 0))
				entries.append(entry)
		var wave := WaveData.new()
		wave.entries = entries
		out.append(wave)
	return out

#endregion
