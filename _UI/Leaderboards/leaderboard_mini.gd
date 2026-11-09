class_name LeaderboardMini extends LeaderboardView
## Level-select board, with ALL RANKS / SSS tabs.

@onready var _all_ranks_tab: Button = %AllRanksTab
@onready var _sss_tab: Button = %SssTab


func _ready() -> void:
	super()
	_all_ranks_tab.pressed.connect(set_filter.bind(LeaderboardBoards.Filter.ALL))
	_sss_tab.pressed.connect(set_filter.bind(LeaderboardBoards.Filter.SSS))


func _show_filter(shown_filter: LeaderboardBoards.Filter) -> void:
	_all_ranks_tab.set_pressed_no_signal(shown_filter == LeaderboardBoards.Filter.ALL)
	_sss_tab.set_pressed_no_signal(shown_filter == LeaderboardBoards.Filter.SSS)
