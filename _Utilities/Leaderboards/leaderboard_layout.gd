class_name LeaderboardLayout
## Picks which entries a board shows: the leaders, plus the player and their neighbours when the
## player is below the leaders. Entries are Steam leaderboard entry dictionaries.

enum Shape { END_SCREEN, POPUP }

const DIVIDER := {"divider": true}
const ROW_COUNTS := {Shape.END_SCREEN: 6, Shape.POPUP: 3}
## x = entries shown above the player, y = entries shown below.
const NEIGHBOURS := {Shape.END_SCREEN: Vector2i(1, 1), Shape.POPUP: Vector2i(0, 0)}
const SHOWS_DIVIDER := {Shape.END_SCREEN: true, Shape.POPUP: false}


static func row_count(shape: Shape) -> int:
	return ROW_COUNTS[shape]


static func neighbours(shape: Shape) -> Vector2i:
	return NEIGHBOURS[shape]


static func is_divider(row: Dictionary) -> bool:
	return row.get("divider", false)


## top = global ranks 1..row_count, around = the player's neighbourhood (GLOBAL_AROUND_USER).
static func arrange_global(shape: Shape, top: Array, around: Array, player_id: int) -> Array:
	var sorted_around := _sorted_by_rank(around)
	var player_position := 0
	for entry: Dictionary in sorted_around:
		if entry.steam_id == player_id:
			player_position = entry.global_rank
	return _arrange(shape, top, sorted_around, player_position)


## Friends are placed by their position among friends but keep their global rank for display.
static func arrange_friends(shape: Shape, entries: Array, player_id: int) -> Array:
	var sorted := _sorted_by_rank(entries)
	var player_index := sorted.find_custom(func(entry: Dictionary) -> bool: return entry.steam_id == player_id)
	var around: Array = []
	if player_index >= 0:
		var span := neighbours(shape)
		around = sorted.slice(maxi(player_index - span.x, 0), player_index + span.y + 1)
	return _arrange(shape, sorted.slice(0, row_count(shape)), around, player_index + 1)


static func _arrange(shape: Shape, top: Array, around: Array, player_position: int) -> Array:
	var count := row_count(shape)
	if player_position <= count:
		return top.slice(0, count)
	var rows := top.slice(0, count - around.size())
	if SHOWS_DIVIDER[shape]:
		rows.append(DIVIDER)
	rows.append_array(around)
	return rows


static func _sorted_by_rank(entries: Array) -> Array:
	var sorted := entries.duplicate()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.global_rank < b.global_rank)
	return sorted
