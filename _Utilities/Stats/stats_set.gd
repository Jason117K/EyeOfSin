@tool
## A game-wide balance pass: the stat config each listed unit uses. Chosen in
## GameController's Stats Set slot. A unit the set doesn't list uses its own
## Stats slot, then its scene's values. Build one with capture_stats_set.gd.
class_name StatsSet extends Resource

## What this balance pass changes.
@export_multiline var notes: String
@export var entries: Array[StatsSetEntry] = []

## The set in use this launch (null = none). Set by GameController's setter,
## which runs before any unit enters the tree.
static var active: StatsSet
static var _by_scene: Dictionary = {}


static func activate(new_set: StatsSet) -> void:
	active = new_set
	_by_scene = {}
	if new_set == null:
		return
	for entry in new_set.entries:
		if entry == null or entry.unit_scene.is_empty() or entry.stats == null:
			push_warning("[Stats] %s: an entry is missing its unit scene or stats; skipped." % new_set.resource_path)
			continue
		var path := _to_res_path(entry.unit_scene)
		if not ResourceLoader.exists(path):
			push_warning("[Stats] %s: unit scene '%s' not found; skipped." % [new_set.resource_path, entry.unit_scene])
			continue
		if _by_scene.has(path):
			push_warning("[Stats] %s: '%s' is listed twice; using the first entry." % [new_set.resource_path, path])
			continue
		_by_scene[path] = entry.stats
	print("[Stats] Active set: %s (%d units)" % [new_set.resource_path, _by_scene.size()])


## The active set's config for this unit, or null if it isn't listed.
static func lookup(unit: Node) -> UnitStats:
	if _by_scene.is_empty() or unit.scene_file_path.is_empty():
		return null
	return _by_scene.get(unit.scene_file_path)


# Entries may store uid:// paths; units report res:// paths.
static func _to_res_path(path: String) -> String:
	if path.begins_with("uid://"):
		var id := ResourceUID.text_to_id(path)
		if ResourceUID.has_id(id):
			return ResourceUID.get_id_path(id)
	return path
