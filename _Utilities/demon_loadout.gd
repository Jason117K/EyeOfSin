class_name DemonLoadout extends RefCounted
## Player-built demon loadouts (2026-10). Static helpers only — no autoload, no Global state.
## One loadout per dimension (purple / green), edited on the Act screens' DemonGridContainer
## (Y flips which dimension is shown/edited) and shared by all three Act screens.
## Only in effect once every demon is unlocked (Progress.DEMON_UNLOCKS), and only for levels
## FIRST_LEVEL+: GameController.change_dual_scenes hands each dimension's DemonSelectionMenu
## its loadout via set_loadout(), which can only HIDE cards the level offers, never add any.
## Saved to its own file so Progress's whole-file save can't clobber it.


const SAVE_PATH := "user://loadout.cfg"
const SAVE_SECTION := "loadout"

## Unlock order; the default loadout is the first MAX_EQUIPPED of these (everything but Maw).
const DEMONS: Array[String] = ["Crawler", "Occulum", "SpinalOcculum", "Wyrm", "Hive", "Maw"]
const MAX_EQUIPPED := 5
const FIRST_LEVEL := 12

static var _loaded := false
static var _purple: Array[String] = []
static var _green: Array[String] = []


## True once all demons are unlocked — before that every unlocked demon is simply available.
static func is_active() -> bool:
	for demon_name: String in DEMONS:
		if not Progress.is_demon_unlocked(demon_name):
			return false
	return true


static func default_loadout() -> Array[String]:
	return DEMONS.slice(0, MAX_EQUIPPED)


## Sanitised copy of a dimension's loadout: known + unlocked names only, capped at
## MAX_EQUIPPED, never empty (falls back to the default).
static func get_loadout(green: bool) -> Array[String]:
	_ensure_loaded()
	var clean: Array[String] = []
	for demon_name: String in (_green if green else _purple):
		if demon_name in DEMONS and demon_name not in clean and Progress.is_demon_unlocked(demon_name):
			clean.append(demon_name)
	if clean.size() > MAX_EQUIPPED:
		clean = clean.slice(0, MAX_EQUIPPED)
	if clean.is_empty():
		clean = default_loadout()
	return clean


static func is_equipped(demon_name: String, green: bool) -> bool:
	return demon_name in get_loadout(green)


## Click on an Act-screen icon. Unequips (unless it's the last one), or equips — dropping a
## random equipped demon first when already at MAX_EQUIPPED. Returns true if it changed.
static func toggle(demon_name: String, green: bool) -> bool:
	if not is_active() or demon_name not in DEMONS:
		return false
	var loadout := get_loadout(green)
	if demon_name in loadout:
		if loadout.size() <= 1:
			return false # at least one demon must stay equipped
		loadout.erase(demon_name)
	else:
		if loadout.size() >= MAX_EQUIPPED:
			loadout.erase(loadout.pick_random())
		loadout.append(demon_name)
	if green:
		_green = loadout
	else:
		_purple = loadout
	_save()
	return true


## Act-screen grid: locked demons hidden; once loadouts are active, unequipped ones darkened.
static func refresh_grid(grid: Control, green: bool) -> void:
	var active := is_active()
	for icon: Control in grid.get_children():
		var demon_name := String(icon.name) # node names are StringNames; keys here are Strings
		if demon_name not in DEMONS:
			continue
		icon.visible = Progress.is_demon_unlocked(demon_name)
		var darkened := active and not is_equipped(demon_name, green)
		icon.modulate = UiFx.LOCKED_MODULATE if darkened else Color.WHITE


## Makes the grid's icons clickable. is_green returns which dimension the screen shows.
static func connect_grid(grid: Control, is_green: Callable) -> void:
	for icon: Control in grid.get_children():
		var demon_name := String(icon.name)
		if demon_name not in DEMONS:
			continue
		icon.mouse_filter = Control.MOUSE_FILTER_STOP
		icon.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				var green: bool = is_green.call()
				if toggle(demon_name, green):
					# Runtime lookup, not the autoload identifier: keeps this static module
					# compilable in headless -s / --check-only runs (no autoloads there).
					var audio := grid.get_node_or_null(^"/root/AudioManager")
					if audio != null:
						audio.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
				refresh_grid(grid, green))


static func _ensure_loaded() -> void:
	if not _loaded:
		_load()


static func _load() -> void:
	_loaded = true
	_purple = default_loadout()
	_green = default_loadout()
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		return
	if err != OK:
		push_warning("[LOADOUT] could not read %s (error %d) — using the default loadout" % [SAVE_PATH, err])
		return
	_purple = _read_list(cfg, "purple")
	_green = _read_list(cfg, "green")


static func _read_list(cfg: ConfigFile, key: String) -> Array[String]:
	var saved: Variant = cfg.get_value(SAVE_SECTION, key, [])
	var names: Array[String] = []
	if typeof(saved) == TYPE_ARRAY or typeof(saved) == TYPE_PACKED_STRING_ARRAY:
		for value: Variant in saved:
			names.append(str(value))
	else:
		push_warning("[LOADOUT] bad '%s' loadout in %s — using the default" % [key, SAVE_PATH])
	return names # sanitised on read by get_loadout


static func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SAVE_SECTION, "purple", _purple)
	cfg.set_value(SAVE_SECTION, "green", _green)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("[LOADOUT] could not save %s (error %d) — loadout kept for this session only" % [SAVE_PATH, err])
