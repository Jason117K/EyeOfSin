class_name Discovery extends RefCounted
## Zombies and synergies the player has discovered (2026-10). Static helpers only — no
## autoload, no Global state. A zombie is discovered the first time one spawns in a real
## game (Global.unlock_zombie); a synergy the first time it triggers (Global.unlock_buff).
## The codexes silhouette and disable anything not discovered yet. Demons aren't tracked
## here: their codex state is Progress.is_demon_unlocked.
## Saved to its own file so Progress's whole-file save can't clobber it.


const SAVE_PATH := "user://discovery.cfg"
const SAVE_SECTION := "discovery"

static var _loaded := false
static var _zombies: Array[String] = []
static var _synergies: Array[StringName] = []


static func is_zombie_discovered(zombie_name: String) -> bool:
	_ensure_loaded()
	return zombie_name in _zombies


## Returns true only the first time (callers show their "new zombie" pop-up on true).
static func discover_zombie(zombie_name: String) -> bool:
	if zombie_name.is_empty() or is_zombie_discovered(zombie_name):
		return false
	_zombies.append(zombie_name)
	_save()
	return true


static func is_synergy_discovered(id: StringName) -> bool:
	_ensure_loaded()
	return id in _synergies


## Returns true only the first time (callers show their "new synergy" pop-up on true).
static func discover_synergy(id: StringName) -> bool:
	if id == &"" or is_synergy_discovered(id):
		return false
	_synergies.append(id)
	_save()
	return true


## DEBUG (Ctrl+U): discovers every zombie name in zombie_names (any iterable, e.g.
## ZombieRegistry.SCENES) and every synergy in the catalog. Taken as arguments so this
## module never references Global or an autoload.
static func discover_all(zombie_names, catalog: SynergyCatalog) -> void:
	_ensure_loaded()
	for zombie_name in zombie_names:
		if String(zombie_name) not in _zombies:
			_zombies.append(String(zombie_name))
	if catalog != null:
		for synergy: SynergyDefinition in catalog.synergies:
			if synergy != null and synergy.id not in _synergies:
				_synergies.append(synergy.id)
	_save()


static func _ensure_loaded() -> void:
	if not _loaded:
		_load()


static func _load() -> void:
	_loaded = true
	_zombies = []
	_synergies = []
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		return
	if err != OK:
		push_warning("[DISCOVERY] could not read %s (error %d) — starting with nothing discovered" % [SAVE_PATH, err])
		return
	for zombie_name: String in _read_list(cfg, "zombies"):
		if zombie_name not in _zombies:
			_zombies.append(zombie_name)
	for id: String in _read_list(cfg, "synergies"):
		if StringName(id) not in _synergies:
			_synergies.append(StringName(id))


static func _read_list(cfg: ConfigFile, key: String) -> Array[String]:
	var saved: Variant = cfg.get_value(SAVE_SECTION, key, [])
	var names: Array[String] = []
	if typeof(saved) == TYPE_ARRAY or typeof(saved) == TYPE_PACKED_STRING_ARRAY:
		for value: Variant in saved:
			if not str(value).is_empty():
				names.append(str(value))
	else:
		push_warning("[DISCOVERY] bad '%s' list in %s — ignoring it" % [key, SAVE_PATH])
	return names


static func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SAVE_SECTION, "zombies", PackedStringArray(_zombies))
	var ids := PackedStringArray()
	for id: StringName in _synergies:
		ids.append(String(id))
	cfg.set_value(SAVE_SECTION, "synergies", ids)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("[DISCOVERY] could not save %s (error %d) — discoveries kept for this session only" % [SAVE_PATH, err])
