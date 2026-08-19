@tool
extends RefCounted

## Read/write layer between the wave tables and ZombieSpawner.waves.
##
## No class_name on purpose: this is editor-only code and must never register a
## global class in exported builds. Use it via
##   const IO := preload("res://addons/wave_table_editor/wave_table_io.gd")


#region Discovery

## Every ZombieSpawner under `root`, in scene-tree order (that is the table order).
## owned = false so spawners inside instanced sub-scenes are found too.
static func find_spawners(root: Node) -> Array[ZombieSpawner]:
	var out: Array[ZombieSpawner] = []
	if root == null:
		return out
	for node: Node in root.find_children("*", "ZombieSpawner", true, false):
		out.append(node)
	return out

#endregion


#region Type columns

## All zombie types, in ZombieRegistry declaration order.
static func all_types() -> PackedStringArray:
	var out := PackedStringArray()
	for type_name: String in ZombieRegistry.SCENES:
		out.append(type_name)
	return out


## Only types with a count > 0 somewhere in these spawners, in registry order.
static func used_types(spawners: Array[ZombieSpawner]) -> PackedStringArray:
	var used := {}
	for spawner: ZombieSpawner in spawners:
		for wave: WaveData in spawner.waves:
			if wave == null:
				continue
			for entry: WaveEntry in wave.entries:
				if entry != null and entry.count > 0:
					used[entry.type] = true

	var out := PackedStringArray()
	for type_name: String in ZombieRegistry.SCENES:
		if used.has(type_name):
			out.append(type_name)
	return out

#endregion


#region Reads

## {type_name: total_count} for one wave. Unlike WaveData.to_dict() this keeps
## zero-count entries, because the grid needs to show them as 0 rather than blank.
static func counts_for(wave: WaveData) -> Dictionary:
	var out := {}
	if wave == null:
		return out
	for entry: WaveEntry in wave.entries:
		if entry == null:
			continue
		out[entry.type] = int(out.get(entry.type, 0)) + entry.count
	return out


## Types appearing more than once in a wave's ordered entries. A flat grid cell
## cannot represent those, so callers flag them before the user edits.
static func duplicate_types(wave: WaveData) -> PackedStringArray:
	var dupes := PackedStringArray()
	if wave == null:
		return dupes
	var seen := {}
	for entry: WaveEntry in wave.entries:
		if entry == null:
			continue
		if seen.has(entry.type):
			if not dupes.has(entry.type):
				dupes.append(entry.type)
		else:
			seen[entry.type] = true
	return dupes


## Largest wave count across the given spawners.
static func max_wave_count(spawners: Array[ZombieSpawner]) -> int:
	var most := 0
	for spawner: ZombieSpawner in spawners:
		most = maxi(most, spawner.waves.size())
	return most

#endregion


#region Cloning

## Explicit clone rather than Resource.duplicate(true). WaveEntry declares
## type/count as plain script vars surfaced through _get_property_list() rather
## than @export, so duplicate()'s storage-flag walk is not worth betting undo
## history on. Order and duplicate types are both preserved.
static func clone_wave(src: WaveData) -> WaveData:
	var copy := WaveData.new()
	var out: Array[WaveEntry] = []
	if src != null:
		for entry: WaveEntry in src.entries:
			if entry == null:
				continue
			var clone := WaveEntry.new()
			clone.type = entry.type
			clone.count = entry.count
			out.append(clone)
	copy.entries = out
	return copy


static func snapshot(waves: Array[WaveData]) -> Array[WaveData]:
	var out: Array[WaveData] = []
	for wave: WaveData in waves:
		out.append(null if wave == null else clone_wave(wave))
	return out

#endregion


#region Writes

## Surgical cell write: touches only entries of `type`, so every other entry
## keeps its exact position and authored spawn order survives round-tripping.
## Duplicate entries of `type` collapse onto the first one.
static func set_count(wave: WaveData, type: String, new_count: int) -> void:
	if wave == null:
		return

	var idx: Array[int] = []
	for i: int in wave.entries.size():
		if wave.entries[i] != null and wave.entries[i].type == type:
			idx.append(i)

	if idx.is_empty():
		if new_count > 0:
			var entry := WaveEntry.new()
			entry.type = type
			entry.count = new_count
			wave.entries.append(entry)          # new types append; existing order untouched
	elif new_count <= 0:
		for i: int in range(idx.size() - 1, -1, -1):
			wave.entries.remove_at(idx[i])
	else:
		wave.entries[idx[0]].count = new_count
		for i: int in range(idx.size() - 1, 0, -1):
			wave.entries.remove_at(idx[i])      # duplicate collapse

	wave.entries = wave.entries                 # re-trigger setter -> emit_changed()


## Undoable single-cell edit. Scoped to the spawner so the scene is marked dirty.
static func commit_set_count(plugin: EditorPlugin, spawner: ZombieSpawner,
		wave_index: int, type: String, new_count: int) -> void:
	if plugin == null or spawner == null:
		return
	if wave_index < 0 or wave_index >= spawner.waves.size():
		return

	var before := snapshot(spawner.waves)
	var after := snapshot(spawner.waves)
	if after[wave_index] == null:
		after[wave_index] = WaveData.new()
	set_count(after[wave_index], type, new_count)

	var undo_redo := plugin.get_undo_redo()
	# Name omits the value so dragging a spinner merges into one undo step.
	undo_redo.create_action("Wave table: %s W%d %s" % [spawner.name, wave_index + 1, type],
			UndoRedo.MERGE_ENDS, spawner)
	undo_redo.add_do_property(spawner, "waves", after)
	undo_redo.add_undo_property(spawner, "waves", before)
	undo_redo.add_do_method(spawner, "notify_property_list_changed")
	undo_redo.add_undo_method(spawner, "notify_property_list_changed")
	undo_redo.commit_action()


## Undoable resize of a spawner's wave list. Grows with empty waves, truncates
## from the end.
static func commit_set_wave_count(plugin: EditorPlugin, spawner: ZombieSpawner,
		new_size: int) -> void:
	if plugin == null or spawner == null:
		return
	new_size = maxi(0, new_size)
	if new_size == spawner.waves.size():
		return

	var before := snapshot(spawner.waves)
	var after := snapshot(spawner.waves)
	while after.size() > new_size:
		after.remove_at(after.size() - 1)
	while after.size() < new_size:
		after.append(WaveData.new())

	var undo_redo := plugin.get_undo_redo()
	undo_redo.create_action("Wave table: %s wave count" % spawner.name,
			UndoRedo.MERGE_ENDS, spawner)
	undo_redo.add_do_property(spawner, "waves", after)
	undo_redo.add_undo_property(spawner, "waves", before)
	undo_redo.add_do_method(spawner, "notify_property_list_changed")
	undo_redo.add_undo_method(spawner, "notify_property_list_changed")
	undo_redo.commit_action()

#endregion


#region Text output

## GitHub-flavoured markdown, one table per spawner: wave rows, type columns.
static func to_markdown(spawners: Array[ZombieSpawner], types: PackedStringArray) -> String:
	var lines := PackedStringArray()
	for spawner: ZombieSpawner in spawners:
		lines.append("### %s" % spawner.name)
		lines.append("")

		var header := PackedStringArray(["Wave"])
		var rule := PackedStringArray([":----:"])
		for type_name: String in types:
			header.append(type_name)
			rule.append(":----:")
		header.append("Danger")
		rule.append("-----:")
		lines.append("| %s |" % " | ".join(header))
		lines.append("|%s|" % "|".join(rule))

		for w: int in spawner.waves.size():
			var wave: WaveData = spawner.waves[w]
			var counts := counts_for(wave)
			var row := PackedStringArray([str(w + 1)])
			for type_name: String in types:
				var count := int(counts.get(type_name, 0))
				row.append("—" if count == 0 else str(count))
			row.append("0" if wave == null else str(wave.get_danger_score()))
			lines.append("| %s |" % " | ".join(row))

		lines.append("")
	return "\n".join(lines)


## Compact fixed-width preview for the inspector dock: transposed (types as rows,
## waves as columns) and sparse (unused types omitted), because 6 wave columns fit
## a ~330px dock and 10 type columns do not.
static func to_preview_text(spawners: Array[ZombieSpawner]) -> String:
	if spawners.is_empty():
		return "No ZombieSpawner nodes found in this scene."

	var blocks := PackedStringArray()
	for spawner: ZombieSpawner in spawners:
		var wave_count := spawner.waves.size()
		var order := "random" if spawner.is_random else "ordered"
		var lines := PackedStringArray()
		lines.append("%s  (%s, %d wave%s)"
				% [spawner.name, order, wave_count, "" if wave_count == 1 else "s"])

		if wave_count == 0:
			lines.append("  (no waves)")
			blocks.append("\n".join(lines))
			continue

		# Only types this spawner actually uses.
		var just_this: Array[ZombieSpawner] = [spawner]
		var rows := used_types(just_this)
		var label_width := 4
		for type_name: String in rows:
			label_width = maxi(label_width, type_name.length())
		label_width = maxi(label_width, 6)  # "Danger"

		var header := "Type".rpad(label_width)
		for w: int in wave_count:
			header += ("W%d" % (w + 1)).lpad(5)
		lines.append(header)

		for type_name: String in rows:
			var line := type_name.rpad(label_width)
			for w: int in wave_count:
				var count := int(counts_for(spawner.waves[w]).get(type_name, 0))
				line += ("·" if count == 0 else str(count)).lpad(5)
			lines.append(line)

		var danger := "Danger".rpad(label_width)
		for w: int in wave_count:
			var wave: WaveData = spawner.waves[w]
			danger += ("0" if wave == null else str(wave.get_danger_score())).lpad(5)
		lines.append(danger)

		blocks.append("\n".join(lines))

	return "\n\n".join(blocks)

#endregion
