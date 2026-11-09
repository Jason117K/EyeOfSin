class_name SteamPlatform
## Owns Steam start-up. Nothing else may call Steam until is_available() is true.

const APP_ID := 4305730

static var _available := false


static func initialize() -> void:
	if _available:
		return
	var result: Dictionary = Steam.steamInitEx(APP_ID, false)
	_available = result.get("status", -1) == Steam.STEAM_API_INIT_RESULT_OK
	if not _available:
		print("[Steam] Unavailable (%s). Leaderboards are hidden." % result.get("verbal", ""))
		return
	Steam.initFilterText()


static func is_available() -> bool:
	return _available


static func run_callbacks() -> void:
	if _available:
		Steam.run_callbacks()


static func local_steam_id() -> int:
	return Steam.getSteamID() if _available else 0


static func persona_name(steam_id: int) -> String:
	if steam_id == local_steam_id():
		return Steam.getPersonaName()
	return Steam.getFriendPersonaName(steam_id)


## Steam applies legally required filtering plus whatever the viewing player enabled.
static func filtered_name(steam_id: int, raw_name: String) -> String:
	return Steam.filterText(Steam.TEXT_FILTERING_CONTEXT_NAME, steam_id, raw_name)
