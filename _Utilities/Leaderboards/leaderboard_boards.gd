class_name LeaderboardBoards
## Every level has four Steam boards: <LevelKey>_<ALL|SSS>_<SCORE|TIME>. The level key is the
## purple scene's file name, so renaming that scene starts fresh boards. Debug builds use DEV_ boards.

enum Filter { ALL, SSS }
enum Sort { SCORE, TIME }
enum Scope { GLOBAL, FRIENDS }

const DEV_PREFIX := "DEV_"
const FILTER_NAMES := {Filter.ALL: "ALL", Filter.SSS: "SSS"}
const SORT_NAMES := {Sort.SCORE: "SCORE", Sort.TIME: "TIME"}
const FILTER_TITLE_KEYS := {Filter.ALL: "UI_LEADERBOARD_ALL_RANKS", Filter.SSS: "UI_LEADERBOARD_SSS"}


static func level_key(level: int) -> String:
	return Progress.scene_for_level(level).get_file().get_basename()


static func board_name(level: int, filter: Filter, sort: Sort, is_dev_build := OS.is_debug_build()) -> String:
	var prefix := DEV_PREFIX if is_dev_build else ""
	return "%s%s_%s_%s" % [prefix, level_key(level), FILTER_NAMES[filter], SORT_NAMES[sort]]


static func filters_for_rank(rank: int) -> Array[Filter]:
	if rank == Progress.RANK_SSS:
		return [Filter.ALL, Filter.SSS]
	return [Filter.ALL]


static func default_filter(rank: int) -> Filter:
	return Filter.SSS if rank == Progress.RANK_SSS else Filter.ALL


static func current_sort() -> Sort:
	return Sort.TIME if LeaderboardSettings.sorts_by_time() else Sort.SCORE
