class_name Progress extends RefCounted
## Player progression (2026-10). Static helpers only — no autoload, no Global state.
## Levels are linear: beating level N unlocks level N+1 (highest_unlocked). An Act is
## unlocked once its first level is. Each level also keeps its best-ever overall rank;
## stars are DERIVED from those ranks (never stored), and Swap/Syn sorceries unlock
## from beaten levels or star thresholds (SORCERY_UNLOCKS).
## Saved to its own file so wiping progress keeps settings.cfg (language) intact.


const SAVE_PATH := "user://progress.cfg"
const SAVE_SECTION := "progress"
const RANKS_SECTION := "best_ranks" # key = level number, value = rank (0 = SSS .. 5 = D)
const SAVE_VERSION := 2

## Indexed like ScoreManager.SCORE_RANKS / style_screen.SCORE_RANKS (SSS..D).
const RANK_LETTERS: Array[String] = ["SSS", "S", "A", "B", "C", "D"]
const STARS_FOR_RANK: Array[int] = [3, 2, 2, 2, 1, 1]
const RANK_SSS := 0
const RANK_S := 1
const RANK_D := 5

## Unlock rule per sorcery id: {"level": n} = beat level n, {"stars": n} = own n stars
## (a threshold, not a cost — stars are never spent).
const SORCERY_UNLOCKS: Dictionary = {
	&"lightning_strike": {"level": 3},
	&"lightning_storm": {"level": 4},
	&"blood_ice": {"level": 12},
	&"blood_rain": {"level": 14},
	&"syn_shields": {"level": 15},
	&"lucretia_grasp": {"stars": 27},
	&"shroomie": {"stars": 33},
	&"death_mark": {"stars": 39}, # "Mark of Syn"
	&"baal_gaze": {"stars": 45},
}

## Level that must be beaten to unlock each demon (0 = from the start). Names match the
## DemonSelectionMenu card containers and the Act screens' DemonGridContainer icons.
const DEMON_UNLOCKS: Dictionary = {
	"Crawler": 0,
	"Occulum": 1,
	"SpinalOcculum": 2,
	"Wyrm": 5,
	"Hive": 10,
	"Maw": 11,
}

## Purple scene path of every level, per Act, in LEVEL-SELECT BUTTON order — not folder
## order: slot 7 is Level8's scene and slot 8 is Level7's (see level_select_alt.gd).
## A level's identity is its position here, so keep this in lockstep with the select screens.
const ACTS: Array = [
	[
		"res://_Stages/Level1/Level0-1.tscn",
		"res://_Stages/Level2/Level0-2.tscn",
		"res://_Stages/Level2/Level0-3B.tscn",
		"res://_Stages/Level4/Level0-4.tscn",
		"res://_Stages/Level5/Level0-5.tscn",
		"res://_Stages/Level6/Level0-6.tscn",
		"res://_Stages/Level8/Level8.tscn",
		"res://_Stages/Level7/Level7.tscn",
		"res://_Stages/Level9/Level9.tscn",
	],
	[
		"res://_Stages/Level10/Level10.tscn",
		"res://_Stages/Level11/Level11.tscn",
		"res://_Stages/Level12/Level12.tscn",
		"res://_Stages/Level13/Level13.tscn",
		"res://_Stages/Level14/Level14.tscn",
	],
	[
		"res://_Stages/Level15/Level15.tscn",
		"res://_Stages/Level16/Level16.tscn",
		"res://_Stages/Level17/Level17.tscn",
	],
]

const ACT_SELECT_SCREENS: Array[String] = [
	"res://_Stages/LevelSelect/LevelSelect_A1.tscn",
	"res://_Stages/LevelSelect/LevelSelect_A2.tscn",
	"res://_Stages/LevelSelect/LevelSelect_A3.tscn",
]

static var _highest := 0 # 0 = not loaded from disk yet
static var _best_ranks: Dictionary = {} # level (int) -> best rank (int); loaded with _highest
static var _last_beaten := 0 # session-only; drives post-win routing + rank recording
static var _pending_forced_rank := -1 # debug win rank for the score screen; -1 = none


static func total_levels() -> int:
	var total := 0
	for act_levels: Array in ACTS:
		total += act_levels.size()
	return total


static func highest_unlocked() -> int:
	_ensure_loaded()
	return _highest


## Old (v1) saves have no ranks, so beaten-ness also falls back to highest_unlocked.
## The rank check covers the final level, which highest_unlocked can't express.
static func is_level_beaten(level: int) -> bool:
	_ensure_loaded()
	return _best_ranks.has(level) or (level >= 1 and level < _highest)


## Best-ever overall rank for a level (0 = SSS .. 5 = D), or -1 if it has none.
static func best_rank(level: int) -> int:
	_ensure_loaded()
	return _best_ranks.get(level, -1)


static func stars_for_rank(rank: int) -> int:
	return STARS_FOR_RANK[rank] if rank >= 0 and rank < STARS_FOR_RANK.size() else 0


## Each level counts its best rank only, so replays can raise the total but never farm it.
static func total_stars() -> int:
	_ensure_loaded()
	var total := 0
	for level: int in _best_ranks:
		total += stars_for_rank(_best_ranks[level])
	return total


## Card-style level name used on the select screens: level 12 -> "2-3".
static func level_label(level: int) -> String:
	var act := act_of_level(level)
	return "%d-%d" % [act, level - first_level_of_act(act) + 1]


static func is_level_unlocked(level: int) -> bool:
	return level >= 1 and level <= highest_unlocked()


## Acts are 1-based (1..ACTS.size()).
static func is_act_unlocked(act: int) -> bool:
	return is_level_unlocked(first_level_of_act(act))


static func first_level_of_act(act: int) -> int:
	var first := 1
	for i in clampi(act - 1, 0, ACTS.size()):
		first += (ACTS[i] as Array).size()
	return first


static func act_of_level(level: int) -> int:
	var last := 0
	for i in ACTS.size():
		last += (ACTS[i] as Array).size()
		if level <= last:
			return i + 1
	return ACTS.size()


## Overall level number (1..total) for a PURPLE level scene path; 0 if unknown.
## Lowercased compare: exports are case-sensitive, the Windows editor is not.
static func level_for_scene(scene_path: String) -> int:
	var wanted := scene_path.to_lower()
	var level := 0
	for act_levels: Array in ACTS:
		for path: String in act_levels:
			level += 1
			if path.to_lower() == wanted:
				return level
	return 0


## Called once per win (WaveManager._win). Never lowers progress, so replays are safe.
## forced_rank (debug wins) is handed to the score screen via resolve_rank; every call
## resets it, so a natural win (-1) can never inherit a stale debug rank.
static func mark_level_beaten(scene_path: String, forced_rank: int = -1) -> void:
	_pending_forced_rank = forced_rank
	var level := level_for_scene(scene_path)
	_last_beaten = level
	if level == 0:
		push_warning("[PROGRESS] unknown level '%s' — not recorded (add it to Progress.ACTS?)" % scene_path)
		return
	var unlocked := mini(level + 1, total_levels())
	if unlocked > highest_unlocked():
		_highest = unlocked
		_save()


## Score screen hook: the rank it computed, unless a debug win forced one.
static func resolve_rank(computed_rank: int) -> int:
	var rank := _pending_forced_rank if _pending_forced_rank >= 0 else computed_rank
	_pending_forced_rank = -1
	return rank


## Score screen hook (once per win, after mark_level_beaten): keeps the level's best rank.
## Returns the stars this run earned. Unknown/test levels record nothing.
static func record_rank(rank: int) -> int:
	rank = clampi(rank, RANK_SSS, RANK_D)
	if _last_beaten == 0:
		return stars_for_rank(rank)
	var previous := best_rank(_last_beaten)
	if previous < 0 or rank < previous:
		_best_ranks[_last_beaten] = rank
		_save()
	return stars_for_rank(rank)


static func is_sorcery_unlocked(id: StringName) -> bool:
	var rule: Dictionary = SORCERY_UNLOCKS.get(id, {})
	if rule.has("level"):
		return is_level_beaten(rule.level)
	if rule.has("stars"):
		return total_stars() >= int(rule.stars)
	return true # not gated


## True once any sorcery is unlocked; until then the select screens lock the sorcery menu.
static func any_sorcery_unlocked() -> bool:
	for id: StringName in SORCERY_UNLOCKS:
		if is_sorcery_unlocked(id):
			return true
	return false


static func is_demon_unlocked(demon_name: String) -> bool:
	var level: int = DEMON_UNLOCKS.get(demon_name, -1)
	if level < 0:
		return false
	return level == 0 or is_level_beaten(level)


## "LOCKED - ..." text for a locked sorcery (static funcs can't call tr()).
static func sorcery_requirement_text(id: StringName) -> String:
	var rule: Dictionary = SORCERY_UNLOCKS.get(id, {})
	if rule.has("level"):
		return TranslationServer.translate("UI_SORCERY_LOCKED_LEVEL").format({"level": level_label(rule.level)})
	if rule.has("stars"):
		return TranslationServer.translate("UI_SORCERY_LOCKED_STARS").format({"cost": rule.stars, "stars": total_stars()})
	return ""


## DEBUG (Ctrl+U): unlock every level and Act, with SSS on every level (all stars).
static func unlock_all() -> void:
	_ensure_loaded()
	_highest = total_levels()
	for level in range(1, total_levels() + 1):
		_best_ranks[level] = RANK_SSS
	_save()


## Where the win screen's Next/Continue goes: the Act of the level AFTER the one just
## beaten, so finishing an Act's last level lands on the newly unlocked Act.
static func select_screen_after_win() -> String:
	if _last_beaten == 0:
		return ACT_SELECT_SCREENS[0]
	return ACT_SELECT_SCREENS[act_of_level(mini(_last_beaten + 1, total_levels())) - 1]


## Darkens + disables an Act's level panels on a level-select screen and fills each card's
## best-rank letter. Expects the select-screen naming: Level_<slot>_PanelContainer holding a
## Level<slot>Button and Level_Vbox/Rank_HBox/RankLetter.
static func apply_level_locks(root: Node, act: int) -> void:
	var first := first_level_of_act(act)
	for slot in range(1, (ACTS[act - 1] as Array).size() + 1):
		var panel := root.find_child("Level_%d_PanelContainer" % slot, true, false) as Control
		if panel == null:
			push_warning("[PROGRESS] %s has no Level_%d_PanelContainer" % [root.name, slot])
			continue
		var level := first + slot - 1
		var button := panel.get_node_or_null("Level%dButton" % slot) as BaseButton
		UiFx.set_locked(panel, button, not is_level_unlocked(level))
		var rank_letter := panel.get_node_or_null("Level_Vbox/Rank_HBox/RankLetter") as Label
		if rank_letter != null:
			var rank := best_rank(level)
			rank_letter.text = RANK_LETTERS[rank] if rank >= 0 else "-"


static func _ensure_loaded() -> void:
	if _highest == 0:
		_load()


static func _load() -> void:
	_highest = 1
	_best_ranks = {}
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		return
	if err != OK:
		push_warning("[PROGRESS] could not read %s (error %d) — starting from level 1" % [SAVE_PATH, err])
		return
	var saved: Variant = cfg.get_value(SAVE_SECTION, "highest_unlocked", 1)
	if typeof(saved) != TYPE_INT:
		push_warning("[PROGRESS] bad highest_unlocked in %s — starting from level 1" % SAVE_PATH)
	else:
		_highest = clampi(saved, 1, total_levels())
	if cfg.has_section(RANKS_SECTION):
		for key: String in cfg.get_section_keys(RANKS_SECTION):
			var level := key.to_int()
			var rank: Variant = cfg.get_value(RANKS_SECTION, key)
			if not key.is_valid_int() or level < 1 or level > total_levels() \
					or typeof(rank) != TYPE_INT or rank < RANK_SSS or rank > RANK_D:
				push_warning("[PROGRESS] skipping bad best rank '%s = %s' in %s" % [key, str(rank), SAVE_PATH])
				continue
			_best_ranks[level] = rank


static func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SAVE_SECTION, "version", SAVE_VERSION)
	cfg.set_value(SAVE_SECTION, "highest_unlocked", _highest)
	for level: int in _best_ranks:
		cfg.set_value(RANKS_SECTION, str(level), _best_ranks[level])
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("[PROGRESS] could not save %s (error %d) — progress kept for this session only" % [SAVE_PATH, err])
