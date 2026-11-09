class_name LeaderboardRow extends Control
## One leaderboard entry. The name and avatar fill in once Steam delivers them.

const PLAYER_HIGHLIGHT := Color("ffd34d")

@onready var _position_label: Label = %Position
@onready var _avatar: TextureRect = %Avatar
@onready var _name_label: Label = %PlayerName
@onready var _time_label: Label = %Time
@onready var _score_label: Label = %Score
@onready var _rank_label: Label = %Rank

var _steam_id := 0


func show_entry(entry: Dictionary, is_player: bool) -> void:
	_steam_id = entry.steam_id
	var run := LevelRun.from_details(entry.get("details", PackedInt32Array()))
	_position_label.text = "#%d" % entry.global_rank
	_time_label.text = run.formatted_time()
	_score_label.text = str(run.score)
	_rank_label.text = run.rank_letter()
	modulate = PLAYER_HIGHLIGHT if is_player else Color.WHITE
	_show_profile()


func _show_profile() -> void:
	var service := LeaderboardService.available()
	if service == null:
		return
	_name_label.text = service.cached_name(_steam_id)
	_avatar.texture = service.cached_avatar(_steam_id)
	if service.has_profile(_steam_id):
		return
	service.name_ready.connect(_on_name_ready)
	service.avatar_ready.connect(_on_avatar_ready)
	service.request_profile(_steam_id)


func _on_name_ready(steam_id: int, player_name: String) -> void:
	if steam_id == _steam_id:
		_name_label.text = player_name


func _on_avatar_ready(steam_id: int, avatar: Texture2D) -> void:
	if steam_id == _steam_id:
		_avatar.texture = avatar
