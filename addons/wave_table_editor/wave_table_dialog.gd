@tool
extends Window

## Full-width wave table editor. Every spawner in the scene is stacked
## vertically so the whole level can be balanced in one view.

const IO := preload("res://addons/wave_table_editor/wave_table_io.gd")
const WaveGrid := preload("res://addons/wave_table_editor/wave_grid.gd")

signal tables_changed

var _host: WaveTableHost = null
var _plugin: EditorPlugin = null

var _list: VBoxContainer = null
var _filter_check: CheckBox = null
var _status: Label = null
var _building := false


func setup(host: WaveTableHost, plugin: EditorPlugin) -> void:
	_host = host
	_plugin = plugin


func _init() -> void:
	title = "Wave Table Editor"
	unresizable = false
	exclusive = false
	close_requested.connect(hide)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)

	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var toolbar := HBoxContainer.new()
	column.add_child(toolbar)

	_filter_check = CheckBox.new()
	_filter_check.text = "Only show types already used (uncheck to add new types)"
	_filter_check.button_pressed = true
	_filter_check.toggled.connect(_on_filter_toggled)
	toolbar.add_child(_filter_check)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(spacer)

	_status = Label.new()
	_status.modulate = Color(1, 1, 1, 0.6)
	toolbar.add_child(_status)

	var copy_button := Button.new()
	copy_button.text = "Copy as Markdown"
	copy_button.pressed.connect(_on_copy_pressed)
	toolbar.add_child(copy_button)

	var refresh_button := Button.new()
	refresh_button.text = "Refresh"
	refresh_button.pressed.connect(refresh)
	toolbar.add_child(refresh_button)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	column.add_child(scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 14)
	scroll.add_child(_list)


func refresh() -> void:
	if _list == null:
		return
	_building = true

	for child: Node in _list.get_children():
		child.queue_free()
		_list.remove_child(child)

	var root: Node = null
	if _host != null and not _host.search_root.is_empty():
		root = _host.get_node_or_null(_host.search_root)
	if root == null:
		root = EditorInterface.get_edited_scene_root()

	var spawners := IO.find_spawners(root)
	var types := IO.used_types(spawners) if _filter_check.button_pressed else IO.all_types()
	if types.is_empty():
		types = IO.all_types()

	_status.text = "%d spawner%s · %d type column%s" % [
		spawners.size(), "" if spawners.size() == 1 else "s",
		types.size(), "" if types.size() == 1 else "s",
	]

	if spawners.is_empty():
		var empty := Label.new()
		empty.text = "No ZombieSpawner nodes found under %s." % (root.name if root else "the scene")
		_list.add_child(empty)
		_building = false
		return

	for spawner: ZombieSpawner in spawners:
		_list.add_child(_build_block(spawner, types))

	_building = false


func _build_block(spawner: ZombieSpawner, types: PackedStringArray) -> Control:
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 4)

	var header := HBoxContainer.new()
	block.add_child(header)

	var name_label := Label.new()
	name_label.text = spawner.name
	name_label.add_theme_font_override("font",
			EditorInterface.get_editor_theme().get_font("bold", "EditorFonts"))
	header.add_child(name_label)

	var order_label := Label.new()
	# When is_random is on the pool is shuffled, so entry order is irrelevant.
	order_label.text = "(random order)" if spawner.is_random else "(fixed spawn order)"
	order_label.modulate = Color(1, 1, 1, 0.55)
	header.add_child(order_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	var waves_label := Label.new()
	waves_label.text = "Waves:"
	header.add_child(waves_label)

	var wave_spin := SpinBox.new()
	wave_spin.min_value = 0
	wave_spin.max_value = 32
	wave_spin.step = 1
	wave_spin.value = spawner.waves.size()
	wave_spin.value_changed.connect(_on_wave_count_changed.bind(spawner))
	header.add_child(wave_spin)

	var grid := WaveGrid.new()
	grid.spawner = spawner
	grid.types = types
	grid.plugin = _plugin
	grid.wave_edited.connect(_on_grid_edited)
	block.add_child(grid)
	grid.rebuild()

	block.add_child(HSeparator.new())
	return block


func _on_grid_edited() -> void:
	tables_changed.emit()


func _on_wave_count_changed(value: float, spawner: ZombieSpawner) -> void:
	if _building:
		return
	IO.commit_set_wave_count(_plugin, spawner, int(value))
	refresh.call_deferred()
	tables_changed.emit()


func _on_filter_toggled(_pressed: bool) -> void:
	refresh()


func _on_copy_pressed() -> void:
	var root: Node = null
	if _host != null and not _host.search_root.is_empty():
		root = _host.get_node_or_null(_host.search_root)
	if root == null:
		root = EditorInterface.get_edited_scene_root()

	var spawners := IO.find_spawners(root)
	var types := IO.used_types(spawners) if _filter_check.button_pressed else IO.all_types()
	DisplayServer.clipboard_set(IO.to_markdown(spawners, types))
	_status.text = "Copied markdown for %d spawner%s" % [
		spawners.size(), "" if spawners.size() == 1 else "s",
	]
