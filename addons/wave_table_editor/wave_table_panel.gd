@tool
extends VBoxContainer

## Inspector panel shown on a WaveTableHost node: a compact read-only preview of
## every spawner's tables, plus the entry point to the full editor.

const IO := preload("res://addons/wave_table_editor/wave_table_io.gd")
const WaveTableDialog := preload("res://addons/wave_table_editor/wave_table_dialog.gd")

var _host: WaveTableHost = null
var _plugin: EditorPlugin = null

var _preview: Label = null
var _scroll: ScrollContainer = null
var _dialog: Window = null
var _watched: Array[Resource] = []
var _watched_spawners: Array[ZombieSpawner] = []


func setup(host: WaveTableHost, plugin: EditorPlugin) -> void:
	_host = host
	_plugin = plugin


func _ready() -> void:
	add_theme_constant_override("separation", 6)

	var header := Label.new()
	header.text = "Wave Tables"
	header.add_theme_font_override("font",
			EditorInterface.get_editor_theme().get_font("bold", "EditorFonts"))
	add_child(header)

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)

	_preview = Label.new()
	_preview.autowrap_mode = TextServer.AUTOWRAP_OFF
	var theme := EditorInterface.get_editor_theme()
	if theme != null:
		_preview.add_theme_font_override("font", theme.get_font("source", "EditorFonts"))
		_preview.add_theme_font_size_override("font_size",
				theme.get_font_size("source_size", "EditorFonts"))
	_scroll.add_child(_preview)

	var buttons := HBoxContainer.new()
	add_child(buttons)

	var edit_button := Button.new()
	edit_button.text = "Edit Wave Tables…"
	edit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit_button.pressed.connect(_on_edit_pressed)
	buttons.add_child(edit_button)

	var copy_button := Button.new()
	copy_button.text = "Copy as Markdown"
	copy_button.tooltip_text = "Copy all tables to the clipboard as markdown."
	copy_button.pressed.connect(_on_copy_pressed)
	buttons.add_child(copy_button)

	var refresh_button := Button.new()
	refresh_button.text = "Refresh"
	refresh_button.pressed.connect(refresh)
	buttons.add_child(refresh_button)

	refresh()


func _exit_tree() -> void:
	_disconnect_watches()
	if is_instance_valid(_dialog):
		_dialog.queue_free()
		_dialog = null


func _search_root() -> Node:
	if _host != null and not _host.search_root.is_empty():
		var scoped := _host.get_node_or_null(_host.search_root)
		if scoped != null:
			return scoped
	return EditorInterface.get_edited_scene_root()


func refresh() -> void:
	if _preview == null:
		return
	var spawners := IO.find_spawners(_search_root())
	_preview.text = IO.to_preview_text(spawners)
	_rewatch(spawners)
	_fit_preview.call_deferred()


func _fit_preview() -> void:
	if _scroll == null or _preview == null:
		return
	# ScrollContainer has no natural height, so pin it to the label's content.
	_scroll.custom_minimum_size.y = _preview.get_combined_minimum_size().y


#region Live refresh

## Wave resources emit changed() on edit (WaveData.gd / WaveEntry.gd), and
## spawners emit property_list_changed when waves is replaced by undo/redo.
func _rewatch(spawners: Array[ZombieSpawner]) -> void:
	_disconnect_watches()
	for spawner: ZombieSpawner in spawners:
		if not spawner.property_list_changed.is_connected(_on_data_changed):
			spawner.property_list_changed.connect(_on_data_changed)
			_watched_spawners.append(spawner)
		for wave: WaveData in spawner.waves:
			if wave != null and not wave.changed.is_connected(_on_data_changed):
				wave.changed.connect(_on_data_changed)
				_watched.append(wave)


func _disconnect_watches() -> void:
	for res: Resource in _watched:
		if is_instance_valid(res) and res.changed.is_connected(_on_data_changed):
			res.changed.disconnect(_on_data_changed)
	_watched.clear()
	for spawner: ZombieSpawner in _watched_spawners:
		if is_instance_valid(spawner) and spawner.property_list_changed.is_connected(_on_data_changed):
			spawner.property_list_changed.disconnect(_on_data_changed)
	_watched_spawners.clear()


func _on_data_changed() -> void:
	refresh.call_deferred()

#endregion


#region Buttons

func _on_edit_pressed() -> void:
	if not is_instance_valid(_dialog):
		_dialog = WaveTableDialog.new()
		_dialog.setup(_host, _plugin)
		_dialog.tables_changed.connect(_on_data_changed)
		EditorInterface.get_base_control().add_child(_dialog)

	_dialog.refresh()
	var scale := EditorInterface.get_editor_scale()
	_dialog.popup_centered(Vector2i(int(1100 * scale), int(700 * scale)))


func _on_copy_pressed() -> void:
	var spawners := IO.find_spawners(_search_root())
	DisplayServer.clipboard_set(IO.to_markdown(spawners, IO.used_types(spawners)))

#endregion
