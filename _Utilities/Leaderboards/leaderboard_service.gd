class_name LeaderboardService extends Node
## The only code that talks to Steam leaderboards. Steam's leaderboard callbacks don't say which
## request they answer, so board lookups, downloads and uploads run one at a time.

signal rows_ready(request_id: int, rows: Array)
signal rows_failed(request_id: int)
signal name_ready(steam_id: int, player_name: String)
signal avatar_ready(steam_id: int, avatar: Texture2D)
signal _submissions_settled
signal _leaderboard_call_finished

const LEADERBOARD_TIMEOUT_SECONDS := 10.0
const PROFILE_TIMEOUT_SECONDS := 5.0

var _board_handles: Dictionary = {}
var _names: Dictionary = {}
var _avatars: Dictionary = {}
var _profiles_loading: Dictionary = {}
var _pending_submissions := 0
var _is_leaderboard_call_running := false
var _last_request_id := 0

static var _instance: LeaderboardService


## Null when there's no GameController (a level run alone) or Steam isn't running.
static func available() -> LeaderboardService:
	return _instance if _instance != null and _instance.is_available() else null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_instance = self
	SteamPlatform.initialize()
	if is_available():
		Steam.set_leaderboard_details_max(LevelRun.Detail.COUNT)


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _process(_delta: float) -> void:
	SteamPlatform.run_callbacks()


func is_available() -> bool:
	return SteamPlatform.is_available()


func submit(run: LevelRun) -> void:
	if not is_available() or not LeaderboardSettings.submits_scores() or not run.is_submittable():
		return
	_pending_submissions += 1
	for filter: LeaderboardBoards.Filter in LeaderboardBoards.filters_for_rank(run.rank):
		for sort: LeaderboardBoards.Sort in LeaderboardBoards.Sort.values():
			var handle := await _board_handle(run.level, filter, sort)
			if handle != 0:
				await _upload(handle, run.value_for(sort), run.to_details())
	_pending_submissions -= 1
	if _pending_submissions == 0:
		_submissions_settled.emit()


## Answers with rows_ready or rows_failed carrying the returned id.
func request_rows(level: int, filter: LeaderboardBoards.Filter, sort: LeaderboardBoards.Sort,
		scope: LeaderboardBoards.Scope, shape: LeaderboardLayout.Shape) -> int:
	_last_request_id += 1
	_load_rows(_last_request_id, level, filter, sort, scope, shape)
	return _last_request_id


func cached_name(steam_id: int) -> String:
	return _names.get(steam_id, "")


func cached_avatar(steam_id: int) -> Texture2D:
	return _avatars.get(steam_id)


func has_profile(steam_id: int) -> bool:
	return _names.has(steam_id) and _avatars.has(steam_id)


func request_profile(steam_id: int) -> void:
	if not is_available() or has_profile(steam_id) or _profiles_loading.has(steam_id):
		return
	_profiles_loading[steam_id] = true
	await _load_name(steam_id)
	await _load_avatar(steam_id)
	_profiles_loading.erase(steam_id)


func _load_rows(request_id: int, level: int, filter: LeaderboardBoards.Filter, sort: LeaderboardBoards.Sort,
		scope: LeaderboardBoards.Scope, shape: LeaderboardLayout.Shape) -> void:
	if not is_available() or level <= 0:
		rows_failed.emit.call_deferred(request_id)
		return
	while _pending_submissions > 0:
		await _submissions_settled
	var handle := await _board_handle(level, filter, sort)
	if handle == 0:
		rows_failed.emit(request_id)
		return
	var player_id := SteamPlatform.local_steam_id()
	if scope == LeaderboardBoards.Scope.FRIENDS:
		var friends: Variant = await _download(handle, 0, 0, Steam.LEADERBOARD_DATA_REQUEST_FRIENDS)
		if friends == null:
			rows_failed.emit(request_id)
			return
		rows_ready.emit(request_id, LeaderboardLayout.arrange_friends(shape, friends, player_id))
		return
	var top: Variant = await _download(handle, 1, LeaderboardLayout.row_count(shape), Steam.LEADERBOARD_DATA_REQUEST_GLOBAL)
	var span := LeaderboardLayout.neighbours(shape)
	var around: Variant = await _download(handle, -span.x, span.y, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER)
	if top == null or around == null:
		rows_failed.emit(request_id)
		return
	rows_ready.emit(request_id, LeaderboardLayout.arrange_global(shape, top, around, player_id))


func _board_handle(level: int, filter: LeaderboardBoards.Filter, sort: LeaderboardBoards.Sort) -> int:
	var board := LeaderboardBoards.board_name(level, filter, sort)
	if _board_handles.has(board):
		return _board_handles[board]
	var result := await _leaderboard_call(&"leaderboard_find_result", 2,
			func() -> void: Steam.findOrCreateLeaderboard(board, _sort_method(sort), _display_type(sort)))
	if result.is_empty() or result[1] == 0:
		push_warning("[Leaderboards] Couldn't find or create board %s" % board)
		return 0
	_board_handles[board] = result[0]
	return result[0]


func _upload(handle: int, value: int, details: PackedInt32Array) -> void:
	var result := await _leaderboard_call(&"leaderboard_score_uploaded", 3,
			func() -> void: Steam.uploadLeaderboardScore(value, true, details, handle),
			func(args: Array) -> bool: return args[1] == handle)
	if result.is_empty() or not result[0]:
		push_warning("[Leaderboards] Upload to board %d failed or timed out" % handle)


## The entries array, or null when the download failed or timed out.
func _download(handle: int, start: int, end: int, request_type: int) -> Variant:
	var result := await _leaderboard_call(&"leaderboard_scores_downloaded", 3,
			func() -> void: Steam.downloadLeaderboardEntries(start, end, request_type, handle),
			func(args: Array) -> bool: return args[1] == handle)
	return null if result.is_empty() else result[2]


func _load_name(steam_id: int) -> void:
	if _names.has(steam_id):
		return
	if steam_id != SteamPlatform.local_steam_id() and Steam.requestUserInformation(steam_id, false):
		await _wait_for_steam(&"persona_state_change", 2, Callable(),
				func(args: Array) -> bool: return args[0] == steam_id, PROFILE_TIMEOUT_SECONDS)
	_names[steam_id] = SteamPlatform.filtered_name(steam_id, SteamPlatform.persona_name(steam_id))
	name_ready.emit(steam_id, _names[steam_id])


func _load_avatar(steam_id: int) -> void:
	if _avatars.has(steam_id):
		return
	var result := await _wait_for_steam(&"avatar_loaded", 3,
			func() -> void: Steam.getPlayerAvatar(Steam.AVATAR_SMALL, steam_id),
			func(args: Array) -> bool: return args[0] == steam_id, PROFILE_TIMEOUT_SECONDS)
	if result.is_empty():
		return
	var size: int = result[1]
	var pixels: PackedByteArray = result[2]
	if pixels.size() != size * size * 4:
		return
	_avatars[steam_id] = ImageTexture.create_from_image(Image.create_from_data(size, size, false, Image.FORMAT_RGBA8, pixels))
	avatar_ready.emit(steam_id, _avatars[steam_id])


func _leaderboard_call(signal_name: StringName, arg_count: int, start: Callable, accepts := Callable()) -> Array:
	while _is_leaderboard_call_running:
		await _leaderboard_call_finished
	_is_leaderboard_call_running = true
	var result := await _wait_for_steam(signal_name, arg_count, start, accepts, LEADERBOARD_TIMEOUT_SECONDS)
	_is_leaderboard_call_running = false
	_leaderboard_call_finished.emit()
	return result


## Calls start, then returns the first emission that accepts approves, or [] after the timeout.
func _wait_for_steam(signal_name: StringName, arg_count: int, start: Callable, accepts: Callable, timeout: float) -> Array:
	var waiter := SteamSignalWaiter.new(accepts)
	var steam_signal := Signal(Steam, signal_name)
	var listener := waiter.listener(arg_count)
	steam_signal.connect(listener)
	get_tree().create_timer(timeout, true, false, true).timeout.connect(waiter.give_up)
	if start.is_valid():
		start.call()
	var result := await waiter.result()
	steam_signal.disconnect(listener)
	return result


static func _sort_method(sort: LeaderboardBoards.Sort) -> int:
	if sort == LeaderboardBoards.Sort.TIME:
		return Steam.LEADERBOARD_SORT_METHOD_ASCENDING
	return Steam.LEADERBOARD_SORT_METHOD_DESCENDING


static func _display_type(sort: LeaderboardBoards.Sort) -> int:
	if sort == LeaderboardBoards.Sort.TIME:
		return Steam.LEADERBOARD_DISPLAY_TYPE_TIME_MILLISECONDS
	return Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC


## Settles on one matching emission or on give_up(). A Steam callback can arrive inside the
## call that requested it, before anyone awaits, so the result is kept until it's read.
class SteamSignalWaiter extends RefCounted:
	signal _settled

	var _accepts: Callable
	var _result: Array = []
	var _is_waiting := true

	func _init(accepts: Callable) -> void:
		_accepts = accepts

	func listener(arg_count: int) -> Callable:
		return _offer_two if arg_count == 2 else _offer_three

	func give_up() -> void:
		_settle([])

	func result() -> Array:
		if _is_waiting:
			await _settled
		return _result

	func _offer_two(first: Variant, second: Variant) -> void:
		_offer([first, second])

	func _offer_three(first: Variant, second: Variant, third: Variant) -> void:
		_offer([first, second, third])

	func _offer(args: Array) -> void:
		if not _accepts.is_valid() or _accepts.call(args):
			_settle(args)

	func _settle(args: Array) -> void:
		if not _is_waiting:
			return
		_is_waiting = false
		_result = args
		_settled.emit()
