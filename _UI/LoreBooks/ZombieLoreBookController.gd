extends Control

@export var entries: Array[ZombieCodexEntry] = []

var _slots: Array[ZombieCodexSlot] = []
var _page := 0
var _shown_entry: ZombieCodexEntry

@onready var _grid: GridContainer = %ZombieGrid
@onready var _previous_page_button: Button = %PreviousPage
@onready var _next_page_button: Button = %NextPage
@onready var _preview_area: Control = %ZombiePreviewArea
@onready var _preview: AnimatedSprite2D = %CurrentZombieAnim
@onready var _title: Label = %CurrentZombieTitle
@onready var _description: RichTextLabel = %CurrentZombieLabel


func _ready() -> void:
	_slots.assign(_grid.get_children())
	if _slots.is_empty():
		push_error("Zombie codex: ZombieGrid has no slots")
		return
	for slot: ZombieCodexSlot in _slots:
		slot.entry_pressed.connect(_show_entry)
	_preview_area.resized.connect(_fit_preview)
	_warn_undiscoverable_entries()
	_open_first_discovered()


## GameController calls this after the debug unlock-all (Ctrl+U).
func refresh_locks() -> void:
	_show_page(_page)


func _page_count() -> int:
	return maxi(1, ceili(entries.size() / float(_slots.size())))


func _page_of(entry_index: int) -> int:
	return floori(entry_index / float(_slots.size()))


func _show_page(page: int) -> void:
	_page = clampi(page, 0, _page_count() - 1)
	var first_index := _page * _slots.size()
	for i: int in _slots.size():
		var entry_index := first_index + i
		if entry_index < entries.size():
			var entry := entries[entry_index]
			_slots[i].show_entry(entry, _is_discovered(entry))
		else:
			_slots[i].hide()
	_update_page_buttons()


func _update_page_buttons() -> void:
	var has_pages := _page_count() > 1
	_previous_page_button.visible = has_pages
	_next_page_button.visible = has_pages
	UiFx.set_locked(_previous_page_button, _previous_page_button, _page == 0)
	UiFx.set_locked(_next_page_button, _next_page_button, _page == _page_count() - 1)


func _open_first_discovered() -> void:
	for entry_index: int in entries.size():
		if _is_discovered(entries[entry_index]):
			_show_page(_page_of(entry_index))
			_show_entry(entries[entry_index])
			return
	_show_page(0)
	_clear_details()


func _show_entry(entry: ZombieCodexEntry) -> void:
	_shown_entry = entry
	_preview.visible = entry.animation != null
	if entry.animation != null:
		_preview.sprite_frames = entry.animation
		_preview.flip_h = entry.animation_flip_h
		_preview.play(entry.animation_name)
		_fit_preview()
	_title.text = tr(entry.title_key)
	_description.text = "" if entry.description_path.is_empty() else Loc.text(entry.description_path)


## Largest whole-number scale whose visible pixels fit the panel (below 1x only when even 1x
## is too big), capped at the entry's preview_scale, with the visible pixels centered.
func _fit_preview() -> void:
	if _shown_entry == null or _shown_entry.animation == null:
		return
	var area := _preview_area.size
	if not area.x > 0.0 or not area.y > 0.0:
		return
	var bounds := SpriteFramesBounds.visible_rect(_shown_entry.animation, _shown_entry.animation_name)
	var fit := minf(area.x / bounds.size.x, area.y / bounds.size.y)
	var preview_scale := minf(floorf(fit) if fit >= 1.0 else fit, _shown_entry.preview_scale)
	var center := bounds.get_center()
	if _shown_entry.animation_flip_h:
		center.x = -center.x
	_preview.centered = true
	_preview.offset = Vector2.ZERO
	_preview.scale = Vector2.ONE * preview_scale
	_preview.position = (area / 2.0 - center * preview_scale).round()


func _clear_details() -> void:
	_preview.hide()
	_title.text = ""
	_description.text = ""


func _is_discovered(entry: ZombieCodexEntry) -> bool:
	return Discovery.is_zombie_discovered(entry.discovery_name)


func _warn_undiscoverable_entries() -> void:
	for entry: ZombieCodexEntry in entries:
		if not ZombieRegistry.SCENES.has(entry.discovery_name):
			push_warning("Zombie codex: '%s' is not in ZombieRegistry.SCENES, so it can never be discovered" % entry.discovery_name)


func _on_previous_page_pressed() -> void:
	_show_page(_page - 1)


func _on_next_page_pressed() -> void:
	_show_page(_page + 1)


func _on_back_button_pressed() -> void:
	hide()
	Global.game_controller.restore_previous_scene()
