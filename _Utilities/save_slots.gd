class_name SaveSlots extends RefCounted
## Save slots (2026-11). Static helpers only — no autoload, no Global state.
## Each slot is a folder under user://saves/ holding that slot's progress.cfg, loadout.cfg
## and discovery.cfg. Progress, DemonLoadout and Discovery build their paths with
## file_path() and reload whenever active_slot() differs from the slot they loaded.
## Device settings (settings.cfg) are shared by every slot and stay at the user:// root.


const SLOT_COUNT := 3
const ROOT_DIR := "user://saves"
const STATE_PATH := "user://saves/save_slots.cfg"
const STATE_SECTION := "save_slots"
## Single-save files from before slots existed; moved into slot 1 on first launch.
const LEGACY_FILES: Array[String] = ["progress.cfg", "loadout.cfg", "discovery.cfg"]

static var _active := 0 # 0 = not loaded from disk yet


static func active_slot() -> int:
	if _active == 0:
		_load()
	return _active


static func file_path(file_name: String) -> String:
	return slot_dir(active_slot()).path_join(file_name)


static func slot_dir(slot: int) -> String:
	return ROOT_DIR.path_join("slot_%d" % slot)


## Slot 1 always exists, so it never reads as empty.
static func is_slot_used(slot: int) -> bool:
	return DirAccess.dir_exists_absolute(slot_dir(slot))


## Returns true only if the active slot changed.
static func switch_to(slot: int) -> bool:
	if slot < 1 or slot > SLOT_COUNT or slot == active_slot():
		return false
	var err := DirAccess.make_dir_recursive_absolute(slot_dir(slot))
	if err != OK:
		push_warning("[SAVE SLOTS] could not create %s (error %d) — staying on slot %d" % [slot_dir(slot), err, _active])
		return false
	_active = slot
	_save()
	return true


static func _load() -> void:
	_active = 1
	DirAccess.make_dir_recursive_absolute(slot_dir(1))
	_migrate_legacy()
	var cfg := ConfigFile.new()
	var err := cfg.load(STATE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		return
	if err != OK:
		push_warning("[SAVE SLOTS] could not read %s (error %d) — using slot 1" % [STATE_PATH, err])
		return
	var saved: Variant = cfg.get_value(STATE_SECTION, "active", 1)
	if typeof(saved) != TYPE_INT or saved < 1 or saved > SLOT_COUNT:
		push_warning("[SAVE SLOTS] bad active slot '%s' in %s — using slot 1" % [str(saved), STATE_PATH])
		return
	_active = saved
	DirAccess.make_dir_recursive_absolute(slot_dir(_active))


## Never overwrites: a file slot 1 already has stays, and a failed move is retried next launch.
static func _migrate_legacy() -> void:
	for file_name: String in LEGACY_FILES:
		var legacy_path := "user://".path_join(file_name)
		var slot_path := slot_dir(1).path_join(file_name)
		if not FileAccess.file_exists(legacy_path) or FileAccess.file_exists(slot_path):
			continue
		var err := DirAccess.rename_absolute(legacy_path, slot_path)
		if err != OK:
			push_warning("[SAVE SLOTS] could not move %s into slot 1 (error %d) — will retry next launch" % [legacy_path, err])


static func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(STATE_SECTION, "active", _active)
	var err := cfg.save(STATE_PATH)
	if err != OK:
		push_warning("[SAVE SLOTS] could not save %s (error %d) — slot %d kept for this session only" % [STATE_PATH, err, _active])
