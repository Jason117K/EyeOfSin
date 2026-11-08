class_name SorceryCodexCard
extends TextureButton

## Key in Progress.SORCERY_UNLOCKS. Its upper-case form is the ABILITY_* text key stem.
@export var sorcery_id: StringName
@export var icon: Texture2D


func _ready() -> void:
	texture_normal = icon


func refresh_lock() -> void:
	UiFx.set_silhouette(self, not Progress.is_sorcery_unlocked(sorcery_id))


func title_key() -> String:
	return "ABILITY_%s_TITLE" % String(sorcery_id).to_upper()


func description_key() -> String:
	return "ABILITY_%s_DESC" % String(sorcery_id).to_upper()
