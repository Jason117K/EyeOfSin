@tool
extends Tree

## Editable table for one ZombieSpawner: wave rows, zombie-type columns,
## plus a read-only danger total per wave.

const IO := preload("res://addons/wave_table_editor/wave_table_io.gd")

const ROW_HEIGHT := 30.0
const WAVE_COL_WIDTH := 70
const DANGER_COL_WIDTH := 74
const TYPE_COL_WIDTH := 64

signal wave_edited

var spawner: ZombieSpawner = null
var types := PackedStringArray()
var plugin: EditorPlugin = null

var _building := false


func _init() -> void:
	hide_root = true
	column_titles_visible = true
	allow_reselect = true
	select_mode = Tree.SELECT_SINGLE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_edited.connect(_on_item_edited)


func rebuild() -> void:
	_building = true
	clear()

	if spawner == null:
		_building = false
		return

	var type_count := types.size()
	columns = 1 + type_count + 1
	var danger_col := columns - 1

	set_column_title(0, "Wave")
	set_column_expand(0, false)
	set_column_custom_minimum_width(0, WAVE_COL_WIDTH)

	for i: int in type_count:
		var col := i + 1
		set_column_title(col, types[i])
		set_column_expand(col, true)
		set_column_custom_minimum_width(col, TYPE_COL_WIDTH)
		set_column_title_alignment(col, HORIZONTAL_ALIGNMENT_CENTER)

	set_column_title(danger_col, "Danger")
	set_column_expand(danger_col, false)
	set_column_custom_minimum_width(danger_col, DANGER_COL_WIDTH)
	set_column_title_alignment(danger_col, HORIZONTAL_ALIGNMENT_RIGHT)

	var root := create_item()
	for w: int in spawner.waves.size():
		var wave: WaveData = spawner.waves[w]
		var counts := IO.counts_for(wave)
		var dupes := IO.duplicate_types(wave)

		var item := create_item(root)
		item.set_metadata(0, w)
		item.set_text(0, "Wave %d" % (w + 1))
		item.set_selectable(0, false)

		for i: int in type_count:
			var type_name := types[i]
			var col := i + 1
			item.set_cell_mode(col, TreeItem.CELL_MODE_RANGE)
			item.set_range_config(col, 0, 99, 1)
			item.set_range(col, float(int(counts.get(type_name, 0))))
			item.set_editable(col, true)
			if dupes.has(type_name):
				item.set_custom_color(col, Color(1.0, 0.75, 0.25))
				item.set_tooltip_text(col, ("'%s' appears more than once in this wave's ordered "
						+ "entries and is shown here as the sum. Editing this cell puts the whole "
						+ "count on the first entry and removes the others.") % type_name)

		item.set_text(danger_col, "0" if wave == null else str(wave.get_danger_score()))
		item.set_text_alignment(danger_col, HORIZONTAL_ALIGNMENT_RIGHT)
		item.set_editable(danger_col, false)
		item.set_selectable(danger_col, false)
		item.set_custom_color(danger_col, Color(0.65, 0.65, 0.7))

	var scale := EditorInterface.get_editor_scale()
	custom_minimum_size.y = (spawner.waves.size() + 1) * ROW_HEIGHT * scale + 8.0 * scale
	_building = false


func _on_item_edited() -> void:
	if _building or spawner == null or plugin == null:
		return
	var item := get_edited()
	var col := get_edited_column()
	if item == null or col <= 0 or col > types.size():
		return

	var wave_index: int = item.get_metadata(0)
	IO.commit_set_count(plugin, spawner, wave_index, types[col - 1], int(item.get_range(col)))
	# Deferred: rebuilding frees the TreeItem currently mid-signal.
	rebuild.call_deferred()
	wave_edited.emit()
