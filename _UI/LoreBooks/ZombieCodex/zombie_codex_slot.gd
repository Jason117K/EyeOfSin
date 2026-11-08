class_name ZombieCodexSlot
extends Button

signal entry_pressed(entry: ZombieCodexEntry)

const MIN_PORTRAIT_SCALE := 0.1

var _entry: ZombieCodexEntry

@onready var _portrait: TextureButton = $PortraitArea/Portrait


func _ready() -> void:
	_portrait.resized.connect(_apply_portrait_transform)


func show_entry(entry: ZombieCodexEntry, discovered: bool) -> void:
	_entry = entry
	_portrait.texture_normal = entry.portrait
	_portrait.flip_h = entry.portrait_flip_h
	_apply_portrait_transform()
	UiFx.set_locked(self, self, not discovered)
	UiFx.set_silhouette(_portrait, not discovered)
	show()


func _apply_portrait_transform() -> void:
	if _entry == null:
		return
	_portrait.pivot_offset = _portrait.size / 2.0
	_portrait.scale = Vector2.ONE * maxf(_entry.portrait_scale, MIN_PORTRAIT_SCALE)
	_portrait.position = _entry.portrait_offset


func _pressed() -> void:
	entry_pressed.emit(_entry)
