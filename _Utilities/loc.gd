class_name Loc
## Localization module (i18n revamp, 2026-07). Static helpers only — no autoload, no Global state.
## Translation CSVs live in res://_Localization/ (UTF-8, no BOM). The tutorial/description CSVs
## are generated from the game's .txt files by res://_Localization/tools/generate_text_csvs.gd;
## re-run it after adding or renaming any .txt under _Assets/Text/TextFiles or
## _Entities/Demons/SpecialDescriptions.


const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "locale"
const SETTINGS_KEY := "language"

## Supported languages. Names are shown natively in the options dropdown
## (CJK names render correctly once the fallback fonts land — Phase L3).
const LOCALES: Array[Dictionary] = [
	{"code": "en", "name": "English"},
	{"code": "es", "name": "Español"},
	{"code": "zh_CN", "name": "简体中文"},
	{"code": "ru", "name": "Русский"},
	{"code": "pt_BR", "name": "Português (Brasil)"},
	{"code": "de", "name": "Deutsch"},
	{"code": "ja", "name": "日本語"},
	{"code": "fr", "name": "Français"},
	{"code": "pl", "name": "Polski"},
	{"code": "ko", "name": "한국어"},
]


## The .txt path IS the translation identity: key derivation must stay in
## lockstep with generate_text_csvs.gd, which uses this same function.
static func key_from_path(path: String) -> StringName:
	var stem := path.get_file().get_basename()
	return StringName("TXT_" + stem.replace("-", "_").replace(" ", "_").to_upper())


## Translated replacement for FileAccess-reading a game .txt file.
static func text(path: String) -> String:
	var key := key_from_path(path)
	var translated := TranslationServer.translate(key)
	if translated != String(key):
		return translated
	# Key missing (new/renamed .txt without a CSV regen) — fall back to the raw file.
	push_warning("Loc: no translation for %s (from %s); falling back to file contents" % [key, path])
	var file := FileAccess.open(path, FileAccess.READ)
	return file.get_as_text() if file != null else String(key)


## Translated display name for an entity (get_demon_name/get_zombie_name values,
## e.g. " REBORN ", "SPINAL OCCULUM"). Falls back to the raw string if unkeyed.
static func display_name(raw: String) -> String:
	var key := StringName("NAME_" + raw.strip_edges().replace(" ", "_").replace("-", "_").to_upper())
	var translated := TranslationServer.translate(key)
	return translated if translated != String(key) else raw


static func set_locale(code: String) -> void:
	TranslationServer.set_locale(code)
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH) # keep any other sections already saved
	cfg.set_value(SETTINGS_SECTION, SETTINGS_KEY, code)
	cfg.save(SETTINGS_PATH)


## Boot hook — called once from GameController._ready. Saved choice > OS language > en fallback.
static func apply_saved_locale() -> void:
	var cfg := ConfigFile.new()
	var choice := ""
	if cfg.load(SETTINGS_PATH) == OK:
		choice = str(cfg.get_value(SETTINGS_SECTION, SETTINGS_KEY, ""))
	if choice.is_empty():
		choice = match_supported_locale(OS.get_locale())
	if not choice.is_empty():
		TranslationServer.set_locale(choice)


## Maps a raw locale ("pt_PT", "en_US", "zh_CN") to the closest supported code, or "".
static func match_supported_locale(raw: String) -> String:
	for entry: Dictionary in LOCALES:
		if raw == str(entry.code):
			return str(entry.code)
	var lang := raw.split("_")[0]
	for entry: Dictionary in LOCALES:
		if str(entry.code).split("_")[0] == lang:
			return str(entry.code)
	return ""
