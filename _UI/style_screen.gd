extends Control

# Should Only Grab values and parse Letter Grade from those values

signal leaderboard_revealed

@onready var level_title := $CenterContainer/StylePanel/AllPanelsVbox/LevelTitlePanel/Level_Title

@onready var time_label := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/TimeLabel
@onready var time_rank := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/TimeRank
var time_rank_value : SCORE_RANKS

@onready var lives_lost_label := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/LivesLostLabel
@onready var lives_lost_rank := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/LivesLostRank
var lives_lost_rank_value : SCORE_RANKS

@onready var fireballs_used_label := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/FireballLabel
@onready var fireballs_used_rank := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/FireBallsUsedRank

@onready var style_label := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/StyleLabel
@onready var style_rank := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/StyleRank
var style_rank_value : SCORE_RANKS

var all_rank_values : Array[SCORE_RANKS] = [time_rank_value,lives_lost_rank_value,style_rank_value]

@onready var overall_score_label := $CenterContainer/StylePanel/AllPanelsVbox/TotalScorePanel/TotalScoreHbox/TotalScoreNum
@onready var overall_rank := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/StyleRankLetterPanel/StyleRankLetterLabel
@onready var total_score_panel := $CenterContainer/StylePanel/AllPanelsVbox/TotalScorePanel
var stars_label : RichTextLabel # built in _ready from a copy of TotalScorePanel

@onready var leaderboard_panel: LeaderboardPanel = %LeaderboardPanel
@onready var show_leaderboard_button: Button = %ShowLeaderboardButton
var _overall_rank_value := Progress.RANK_D
var _was_forced_win := false
var _leaderboard_level := 0
var _leaderboard_starts_hidden := false

var SSS_STYLE_POINTS_MIN := 2000
var S_STYLE_POINTS_MIN := 1500
var A_STYLE_POINTS_MIN := 1000
var B_STYLE_POINTS_MIN := 700
var C_STYLE_POINTS_MIN := 400
var D_STYLE_POINTS_MIN := 100

@onready var all_style_point_thresholds :Array[int] = [SSS_STYLE_POINTS_MIN,S_STYLE_POINTS_MIN,
		A_STYLE_POINTS_MIN,B_STYLE_POINTS_MIN,C_STYLE_POINTS_MIN,D_STYLE_POINTS_MIN]
		
var SSS_TIME_MIN := 120
var S_TIME_MIN := 110
var A_TIME_MIN := 100
var B_TIME_MIN := 90
var C_TIME_MIN := 80
var D_TIME_MIN := 70

@onready var all_time_thresholds :Array[int] = [SSS_TIME_MIN,S_TIME_MIN,A_TIME_MIN,B_TIME_MIN,
											C_TIME_MIN,D_TIME_MIN]

var SSS_TOTAL_POINTS_MIN := 5000
var S_TOTAL_POINTS_MIN := 4000
var A_TOTAL_POINTS_MIN := 3000
var B_TOTAL_POINTS_MIN := 2000
var C_TOTAL_POINTS_MIN := 1000
var D_TOTAL_POINTS_MIN := 500

@onready var all_total_point_thresholds :Array[int]= [SSS_TOTAL_POINTS_MIN,S_TOTAL_POINTS_MIN,
						A_TOTAL_POINTS_MIN,B_TOTAL_POINTS_MIN,C_TOTAL_POINTS_MIN,D_TOTAL_POINTS_MIN]

enum SCORE_RANKS{SSS,S,A,B,C,D}

func _ready() -> void:
	
		
	Global.register_style_menu(self)
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_build_stars_panel()
	show_leaderboard_button.pressed.connect(_reveal_leaderboard)

		
	#ScoreManager.level_ended.connect(_setup_score)

func configure_style_thresholds()->void:
	pass


# A copy of the total-score row (same panel style + font) placed under it for the stars line.
func _build_stars_panel()->void:
	var stars_panel : Control = total_score_panel.duplicate()
	stars_panel.name = "StarsPanel"
	total_score_panel.add_sibling(stars_panel)
	stars_panel.get_node("TotalScoreHbox/TotalScoreNum").hide()
	stars_label = stars_panel.get_node("TotalScoreHbox/TotalScoreTitle")
	stars_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	
	
func _setup_score()->void:
	#ScoreManager.set_style_points_before_bonus()
	set_visibility_layer_bit(0,false)
	if Global.game_controller.on_purple_scene():
		#set_current_visibility_layer(1)
		set_visibility_layer_bit(1,true)
		#print("Style Menu On Purple")
	else:
		#set_current_visibility_layer(2)
		set_visibility_layer_bit(2,true)
		#print("Style Menu On Green")
	set_time_rank()
	set_lives_lost_rank()
	set_fireballs_used_rank()
	set_style_rank()
	set_overall_rank()
	_present_leaderboard()
	self.show()


## Call before _setup_score. Hidden boards wait for the Show Leaderboard button.
func set_leaderboard_starts_hidden(starts_hidden: bool) -> void:
	_leaderboard_starts_hidden = starts_hidden


func reveal_leaderboard_button() -> void:
	show_leaderboard_button.visible = _leaderboard_level > 0 and not leaderboard_panel.visible


func _present_leaderboard() -> void:
	leaderboard_panel.hide()
	show_leaderboard_button.hide()
	var service := LeaderboardService.available()
	_leaderboard_level = Progress.last_beaten_level() if service != null else 0
	if _leaderboard_level <= 0:
		return
	if not _was_forced_win:
		service.submit(_build_level_run())
	leaderboard_panel.open(_leaderboard_level, LeaderboardBoards.default_filter(_overall_rank_value))
	leaderboard_panel.visible = not _leaderboard_starts_hidden


func _reveal_leaderboard() -> void:
	show_leaderboard_button.hide()
	leaderboard_panel.show()
	leaderboard_revealed.emit()


func _build_level_run() -> LevelRun:
	var run := LevelRun.new()
	run.level = _leaderboard_level
	run.time_ms = roundi(ScoreManager.get_completion_time() * 1000.0)
	run.score = int(ScoreManager.get_total_score())
	run.rank = _overall_rank_value
	run.lives_lost = ScoreManager.get_lives_lost()
	run.fireballs_used = ScoreManager.get_lawn_mowers_used()
	run.demon_points = ScoreManager.style_points_before_bonus
	return run

func set_level_title(new_level_title_text : String)->void:
	level_title.text = new_level_title_text
	pass
	
		
func set_time_rank()->void:
	var completion_time : int = int(ScoreManager.get_completion_time())
	time_label.text = tr("UI_SCORE_TIME").format({"time": completion_time})
	# Thresholds ascend (SSS tightest); first match wins, like ScoreManager.
	if ScoreManager.get_completion_time() <= all_time_thresholds[SCORE_RANKS.SSS]:
		time_rank.text = "SSS"
		time_rank_value = SCORE_RANKS.SSS
	elif ScoreManager.get_completion_time() <= all_time_thresholds[SCORE_RANKS.S]:
		time_rank.text = "S"
		time_rank_value = SCORE_RANKS.S
	elif ScoreManager.get_completion_time() <= all_time_thresholds[SCORE_RANKS.A]:
		time_rank.text = "A"
		time_rank_value = SCORE_RANKS.A
	elif ScoreManager.get_completion_time() <= all_time_thresholds[SCORE_RANKS.B]:
		time_rank.text = "B"
		time_rank_value = SCORE_RANKS.B
	elif ScoreManager.get_completion_time() <= all_time_thresholds[SCORE_RANKS.C]:
		time_rank.text = "C"
		time_rank_value = SCORE_RANKS.C
	else:
		# Slower than the D threshold: no rank (screen persists across levels,
		# so the text must always be set).
		time_rank.text = "D"
		time_rank_value = SCORE_RANKS.D

func set_lives_lost_rank()->void:
	lives_lost_label.text = tr("UI_SCORE_LIVES_LOST").format({"lives": ScoreManager.get_lives_lost()})
	if ScoreManager.get_lives_lost() > 0:
		lives_lost_rank.text = "B"
		lives_lost_rank_value = SCORE_RANKS.B
	else:
		lives_lost_rank.text = "SSS"
		lives_lost_rank_value = SCORE_RANKS.SSS

# Fireballs are the player-facing name for lawnmowers.
func set_fireballs_used_rank()->void:
	var used : int = ScoreManager.get_lawn_mowers_used()
	fireballs_used_label.text = tr("UI_SCORE_FIREBALLS_USED").format({"fireballs": used})
	if used == 0:
		fireballs_used_rank.text = "S"
	elif ScoreManager.are_all_lawn_mowers_used():
		fireballs_used_rank.text = "D"
	else:
		fireballs_used_rank.text = "B"

func set_style_rank()->void:
	var points : int = int(ScoreManager.get_style_points_before_bonus())
	style_label.text = tr("UI_SCORE_DEMON_POINTS").format({"points": points})
	if points >= all_style_point_thresholds[SCORE_RANKS.SSS]:
		style_rank.text = "SSS"
		style_rank_value = SCORE_RANKS.SSS
	elif points >= all_style_point_thresholds[SCORE_RANKS.S]:
		style_rank.text = "S"
		style_rank_value = SCORE_RANKS.S
	elif points >= all_style_point_thresholds[SCORE_RANKS.A]:
		style_rank.text = "A"
		style_rank_value = SCORE_RANKS.A
	elif points >= all_style_point_thresholds[SCORE_RANKS.B]:
		style_rank.text = "B"
		style_rank_value = SCORE_RANKS.B
	elif points >= all_style_point_thresholds[SCORE_RANKS.C]:
		style_rank.text = "C"
		style_rank_value = SCORE_RANKS.C
	elif points >= all_style_point_thresholds[SCORE_RANKS.D]:
		style_rank.text = "D"
		style_rank_value = SCORE_RANKS.D
			
func set_overall_rank()->void:
	ScoreManager.calc_total_level_score()
	var points : int = int(ScoreManager.get_total_score())
	overall_score_label.text = str(points)
	var rank : SCORE_RANKS
	if points >= all_total_point_thresholds[SCORE_RANKS.SSS]:
		rank = SCORE_RANKS.SSS
	elif points >= all_total_point_thresholds[SCORE_RANKS.S]:
		rank = SCORE_RANKS.S
	elif points >= all_total_point_thresholds[SCORE_RANKS.A]:
		rank = SCORE_RANKS.A
	elif points >= all_total_point_thresholds[SCORE_RANKS.B]:
		rank = SCORE_RANKS.B
	elif points >= all_total_point_thresholds[SCORE_RANKS.C]:
		rank = SCORE_RANKS.C
	else:
		# Below the D threshold still counts as D (1 star); the letter used to go stale here.
		rank = SCORE_RANKS.D
	if rank == SCORE_RANKS.SSS and not ScoreManager.are_all_lawn_mowers_intact():
		rank = SCORE_RANKS.S
	# The overall rank is what earns stars; a debug win may force it (Progress.resolve_rank).
	_was_forced_win = Progress.has_pending_forced_rank()
	var final_rank := Progress.resolve_rank(rank)
	_overall_rank_value = final_rank
	overall_rank.text = Progress.RANK_LETTERS[final_rank]
	var stars_earned := Progress.record_rank(final_rank)
	if stars_label != null:
		stars_label.text = tr("UI_SCORE_STARS").format({"stars": stars_earned, "total": Progress.total_stars()})

func set_completion_times(new_completion_time_thresholds : Array)->void:
	var count :int= 0 
	for completion_time_threshold : int in new_completion_time_thresholds:
		all_time_thresholds[count] = completion_time_threshold
		count += 1

func set_style_point_thresholds(new_style_point_thresholds : Array)->void:
	var count :int= 0 
	for style_point_threshold : int in new_style_point_thresholds:
		all_style_point_thresholds[count] = style_point_threshold
		count += 1

func set_total_point_thresholds(new_total_point_thresholds : Array)->void:
	var count :int= 0 
	for total_point_threshold : int in new_total_point_thresholds:
		all_total_point_thresholds[count] = total_point_threshold
		count += 1	
		
func set_current_visibility_layer(flag : int)->void:
	if flag == 1:
		visibility_layer = 2
		#print("Style Vis Layer 2")
	elif flag == 2:
		visibility_layer = 3
		#print("Style Vis Layer 3")
