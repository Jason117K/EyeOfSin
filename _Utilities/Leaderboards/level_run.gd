class_name LevelRun extends RefCounted
## One finished level run, stored in a Steam leaderboard entry's details array.

const DETAILS_VERSION := 1
const NO_RANK := -1

enum Detail { VERSION, TIME_MS, SCORE, RANK, LIVES_LOST, FIREBALLS_USED, DEMON_POINTS, COUNT }

var level := 0
var time_ms := 0
var score := 0
var rank := NO_RANK
var lives_lost := 0
var fireballs_used := 0
var demon_points := 0


static func from_details(details: PackedInt32Array) -> LevelRun:
	var run := LevelRun.new()
	if details.size() < Detail.COUNT:
		return run
	run.time_ms = details[Detail.TIME_MS]
	run.score = details[Detail.SCORE]
	run.rank = details[Detail.RANK]
	run.lives_lost = details[Detail.LIVES_LOST]
	run.fireballs_used = details[Detail.FIREBALLS_USED]
	run.demon_points = details[Detail.DEMON_POINTS]
	return run


@warning_ignore("integer_division")
static func format_time(milliseconds: int) -> String:
	return "%d:%02d.%03d" % [milliseconds / 60000, (milliseconds / 1000) % 60, milliseconds % 1000]


func to_details() -> PackedInt32Array:
	var details := PackedInt32Array()
	details.resize(Detail.COUNT)
	details[Detail.VERSION] = DETAILS_VERSION
	details[Detail.TIME_MS] = time_ms
	details[Detail.SCORE] = score
	details[Detail.RANK] = rank
	details[Detail.LIVES_LOST] = lives_lost
	details[Detail.FIREBALLS_USED] = fireballs_used
	details[Detail.DEMON_POINTS] = demon_points
	return details


func is_submittable() -> bool:
	return level > 0 and time_ms > 0 and score > 0 and rank != NO_RANK


func value_for(sort: LeaderboardBoards.Sort) -> int:
	return time_ms if sort == LeaderboardBoards.Sort.TIME else score


func rank_letter() -> String:
	if rank < Progress.RANK_SSS or rank > Progress.RANK_D:
		return "-"
	return Progress.RANK_LETTERS[rank]


func formatted_time() -> String:
	return format_time(time_ms)
