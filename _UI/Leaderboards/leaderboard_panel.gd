class_name LeaderboardPanel extends LeaderboardView
## End-of-level board. Clicking the header switches between ALL RANKS and SSS.

@onready var _header: Button = %FilterHeader


func _ready() -> void:
	super()
	_header.pressed.connect(_on_header_pressed)


func _show_filter(shown_filter: LeaderboardBoards.Filter) -> void:
	_header.text = LeaderboardBoards.FILTER_TITLE_KEYS[shown_filter]


func _on_header_pressed() -> void:
	var is_showing_all := _filter == LeaderboardBoards.Filter.ALL
	set_filter(LeaderboardBoards.Filter.SSS if is_showing_all else LeaderboardBoards.Filter.ALL)
