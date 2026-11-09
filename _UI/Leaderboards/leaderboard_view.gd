class_name LeaderboardView extends Control
## What the end-of-level and level-select boards share: loading rows, the rank filter, the
## Friends toggle and the status line. Subclasses show the filter in their own control.

@export var row_scene: PackedScene
@export var shape: LeaderboardLayout.Shape

@onready var _rows: VBoxContainer = %Rows
@onready var _status: Label = %Status
@onready var _friends_toggle: CheckButton = %FriendsToggle

var _level := 0
var _filter := LeaderboardBoards.Filter.ALL
var _request_id := -1


func _ready() -> void:
	_friends_toggle.toggled.connect(_on_friends_toggled)
	var service := LeaderboardService.available()
	if service != null:
		service.rows_ready.connect(_on_rows_ready)
		service.rows_failed.connect(_on_rows_failed)


func open(level: int, filter: LeaderboardBoards.Filter) -> void:
	_level = level
	_friends_toggle.set_pressed_no_signal(false)
	set_filter(filter)


func set_filter(filter: LeaderboardBoards.Filter) -> void:
	_filter = filter
	_show_filter(filter)
	refresh()


func refresh() -> void:
	_clear_rows()
	var service := LeaderboardService.available()
	if service == null:
		_show_status("UI_LEADERBOARD_UNAVAILABLE")
		return
	_show_status("UI_LEADERBOARD_LOADING")
	var scope := LeaderboardBoards.Scope.FRIENDS if _friends_toggle.button_pressed else LeaderboardBoards.Scope.GLOBAL
	_request_id = service.request_rows(_level, _filter, LeaderboardBoards.current_sort(), scope, shape)


func _show_filter(_shown_filter: LeaderboardBoards.Filter) -> void:
	pass


func _on_friends_toggled(_is_on: bool) -> void:
	refresh()


func _on_rows_ready(request_id: int, rows: Array) -> void:
	if request_id != _request_id:
		return
	if rows.is_empty():
		_show_status("UI_LEADERBOARD_EMPTY")
		return
	_status.hide()
	var player_id := SteamPlatform.local_steam_id()
	for row: Dictionary in rows:
		if LeaderboardLayout.is_divider(row):
			_rows.add_child(HSeparator.new())
			continue
		var row_node: LeaderboardRow = row_scene.instantiate()
		_rows.add_child(row_node)
		row_node.show_entry(row, row.steam_id == player_id)


func _on_rows_failed(request_id: int) -> void:
	if request_id == _request_id:
		_show_status("UI_LEADERBOARD_UNAVAILABLE")


func _show_status(text_key: String) -> void:
	_status.text = text_key
	_status.show()


func _clear_rows() -> void:
	for child: Node in _rows.get_children():
		child.queue_free()
