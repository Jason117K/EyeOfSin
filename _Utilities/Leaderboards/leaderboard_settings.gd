class_name LeaderboardSettings
## Device-wide leaderboard options, saved in settings.cfg next to the language.

const SECTION := "leaderboards"
const SUBMIT_SCORES_KEY := "submit_scores"
const SORT_BY_TIME_KEY := "sort_by_time"


static func submits_scores() -> bool:
	return _read(SUBMIT_SCORES_KEY, true)


static func set_submits_scores(enabled: bool) -> void:
	_write(SUBMIT_SCORES_KEY, enabled)


static func sorts_by_time() -> bool:
	return _read(SORT_BY_TIME_KEY, false)


static func set_sorts_by_time(enabled: bool) -> void:
	_write(SORT_BY_TIME_KEY, enabled)


static func _read(key: String, default_value: bool) -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(Loc.SETTINGS_PATH) != OK:
		return default_value
	return bool(cfg.get_value(SECTION, key, default_value))


static func _write(key: String, value: bool) -> void:
	var cfg := ConfigFile.new()
	cfg.load(Loc.SETTINGS_PATH)
	cfg.set_value(SECTION, key, value)
	cfg.save(Loc.SETTINGS_PATH)
