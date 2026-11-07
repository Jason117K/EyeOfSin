class_name ZombieCodexSlot
extends Button

signal entry_pressed(entry: ZombieCodexEntry)

var _entry: ZombieCodexEntry

@onready var _portrait: TextureButton = $Portrait


func show_entry(entry: ZombieCodexEntry, discovered: bool) -> void:
	_entry = entry
	_portrait.texture_normal = entry.portrait
	_portrait.flip_h = entry.portrait_flip_h
	UiFx.set_locked(self, self, not discovered)
	UiFx.set_silhouette(_portrait, not discovered)
	show()


func _pressed() -> void:
	entry_pressed.emit(_entry)
