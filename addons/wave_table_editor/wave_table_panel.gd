@tool
extends VBoxContainer

## Inspector panel shown on a WaveTableHost node: a compact read-only preview of
## every spawner's tables, the entry point to the full editor, and wave presets
## (save / load named snapshots of the tables; see wave_preset_io.gd).

const IO := preload("res://addons/wave_table_editor/wave_table_io.gd")
const PresetIO := preload("res://addons/wave_table_editor/wave_preset_io.gd")
const WaveTableDialog := preload("res://addons/wave_table_editor/wave_table_dialog.gd")

var _host: WaveTableHost = null
var _plugin: EditorPlugin = null

var _preview: Label = null
var _scroll: ScrollContainer = null
var _dialog: Window = null
var _watched: Array[Resource] = []
var _watched_spawners: Array[ZombieSpawner] = []

var _preset_select: OptionButton = null
var _load_button: Button = null
var _preset_status: Label = null
var _save_dialog: ConfirmationDialog = null
var _name_edit: LineEdit = null
var _overwrite_dialog: ConfirmationDialog = null
var _pending_preset := ""


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

	_build_presets()
	refresh()


func _exit_tree() -> void:
	_disconnect_watches()
	if is_instance_valid(_dialog):
		_dialog.queue_free()
	if is_instance_valid(_save_dialog):
		_save_dialog.queue_free()
	if is_instance_valid(_overwrite_dialog):
		_overwrite_dialog.queue_free()
	_dialog = null
	_save_dialog = null
	_overwrite_dialog = null


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
	_refresh_presets()


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


#region Presets

func _build_presets() -> void:
	var header := Label.new()
	header.text = "Presets"
	header.add_theme_font_override("font",
			EditorInterface.get_editor_theme().get_font("bold", "EditorFonts"))
	add_child(header)

	var row := HBoxContainer.new()
	add_child(row)

	_preset_select = OptionButton.new()
	_preset_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preset_select.clip_text = true
	_preset_select.item_selected.connect(_on_preset_selected)
	row.add_child(_preset_select)

	_load_button = Button.new()
	_load_button.text = "Load"
	_load_button.tooltip_text = ("Replace this scene's wave tables and wave gaps with the preset "
			+ "(one undo step). Save the scene afterwards to keep it.")
	_load_button.pressed.connect(_on_load_pressed)
	row.add_child(_load_button)

	var save_button := Button.new()
	save_button.text = "Save As…"
	save_button.tooltip_text = "Save this scene's wave tables and wave gaps as a preset."
	save_button.pressed.connect(_on_save_pressed)
	row.add_child(save_button)

	_preset_status = Label.new()
	_preset_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preset_status.modulate = Color(1, 1, 1, 0.6)
	add_child(_preset_status)


## Popups live on the editor base control, like the table dialog, so an inspector
## rebuild can't free one mid-use; _exit_tree frees them.
func _ensure_preset_dialogs() -> void:
	# Both are created here and freed together in _exit_tree.
	if is_instance_valid(_save_dialog):
		return

	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Preset name, e.g. L10 v2"
	_save_dialog = ConfirmationDialog.new()
	_save_dialog.title = "Save Wave Preset"
	_save_dialog.ok_button_text = "Save"
	_save_dialog.add_child(_name_edit)
	_save_dialog.register_text_enter(_name_edit)
	_save_dialog.confirmed.connect(_on_save_confirmed)
	EditorInterface.get_base_control().add_child(_save_dialog)

	_overwrite_dialog = ConfirmationDialog.new()
	_overwrite_dialog.title = "Overwrite Wave Preset?"
	_overwrite_dialog.ok_button_text = "Overwrite"
	_overwrite_dialog.confirmed.connect(_on_overwrite_confirmed)
	EditorInterface.get_base_control().add_child(_overwrite_dialog)


func _scene_root() -> Node:
	return EditorInterface.get_edited_scene_root()


func _selected_preset() -> String:
	if _preset_select == null or _preset_select.disabled or _preset_select.selected < 0:
		return ""
	var meta: Variant = _preset_select.get_item_metadata(_preset_select.selected)
	return "" if meta == null else str(meta)


## Rebuild the dropdown, keeping `keep` (or the current pick) selected if it still exists.
func _refresh_presets(keep: String = "") -> void:
	if _preset_select == null:
		return
	if keep.is_empty():
		keep = _selected_preset()
	_preset_select.clear()

	var root := _scene_root()
	var dir := PresetIO.presets_dir(root)
	var names := PresetIO.list_presets(dir)
	for preset_name: String in names:
		var label := preset_name
		if not PresetIO.has_half(dir, preset_name, root):
			label += "  (no data for this scene)"
		_preset_select.add_item(label)
		var index := _preset_select.item_count - 1
		_preset_select.set_item_metadata(index, preset_name)
		if preset_name == keep:
			_preset_select.select(index)

	_preset_select.disabled = names.is_empty()
	if names.is_empty():
		_preset_select.add_item("(no presets yet)" if not dir.is_empty()
				else "(save the scene first)")
	_update_load_button()


func _update_load_button() -> void:
	var root := _scene_root()
	_load_button.disabled = not PresetIO.has_half(
			PresetIO.presets_dir(root), _selected_preset(), root)


func _on_preset_selected(_index: int) -> void:
	_update_load_button()


func _on_load_pressed() -> void:
	var preset := _selected_preset()
	var root := _scene_root()
	var data := PresetIO.read(PresetIO.presets_dir(root), preset, root)
	if data.is_empty():
		_preset_status.text = "Couldn't read preset '%s'." % preset
		return

	var warnings := PresetIO.commit_apply(_plugin, root, IO.find_spawners(_search_root()),
			data, preset)
	_preset_status.text = "Loaded '%s'. Save the scene to keep it (Ctrl+Z undoes the load)." % preset
	if not warnings.is_empty():
		_preset_status.text += "\n" + "\n".join(PackedStringArray(warnings))

	refresh()
	if is_instance_valid(_dialog):
		_dialog.refresh()


func _on_save_pressed() -> void:
	if PresetIO.presets_dir(_scene_root()).is_empty():
		_preset_status.text = "Save the scene once before saving presets."
		return
	_ensure_preset_dialogs()
	_name_edit.text = _selected_preset()
	var scale := EditorInterface.get_editor_scale()
	_save_dialog.popup_centered(Vector2i(int(360 * scale), 0))
	_name_edit.select_all()
	_name_edit.grab_focus.call_deferred()


func _on_save_confirmed() -> void:
	var preset := PresetIO.clean_name(_name_edit.text)
	if preset.is_empty():
		_preset_status.text = "Enter a preset name."
		return
	var root := _scene_root()
	if PresetIO.has_half(PresetIO.presets_dir(root), preset, root):
		_pending_preset = preset
		_overwrite_dialog.dialog_text = "Preset '%s' already has data for %s. Overwrite it?" % [
			preset, root.scene_file_path.get_file(),
		]
		# Deferred: the save dialog is still closing.
		_overwrite_dialog.popup_centered.call_deferred()
		return
	_save_preset(preset)


func _on_overwrite_confirmed() -> void:
	_save_preset(_pending_preset)


func _save_preset(preset: String) -> void:
	var root := _scene_root()
	var err := PresetIO.save(PresetIO.presets_dir(root), preset, root,
			IO.find_spawners(_search_root()))
	if err != OK:
		_preset_status.text = "Couldn't save preset '%s' (%s)." % [preset, error_string(err)]
		return
	_preset_status.text = "Saved '%s' for %s." % [preset, root.scene_file_path.get_file()]
	_refresh_presets(preset)

#endregion
