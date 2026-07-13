extends Control

# Should Only Grab values and parse Letter Grade from those values 

@onready var level_title := $CenterContainer/StylePanel/AllPanelsVbox/LevelTitlePanel/Level_Title

@onready var time_label := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/TimeLabel
@onready var time_rank := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/TimeRank
var time_rank_value : SCORE_RANKS

@onready var lives_lost_label := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/LivesLostLabel
@onready var lives_lost_rank := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/LivesLostRank
var lives_lost_rank_value : SCORE_RANKS

@onready var style_label := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/StyleLabel
@onready var style_rank := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/StyleRank
var style_rank_value : SCORE_RANKS

var all_rank_values : Array[SCORE_RANKS] = [time_rank_value,lives_lost_rank_value,style_rank_value]

@onready var overall_score_label := $CenterContainer/StylePanel/AllPanelsVbox/TotalScorePanel/TotalScoreHbox/TotalScoreNum
@onready var overall_rank := $CenterContainer/StylePanel/AllPanelsVbox/ScoringHbox/StyleRankLetterPanel/StyleRankLetterLabel

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

		
	#ScoreManager.level_ended.connect(_setup_score)

func configure_style_thresholds()->void:
	pass
	
	
func _setup_score()->void:
	#ScoreManager.set_style_points_before_bonus()
	set_visibility_layer_bit(0,false)
	if Global.game_controller.on_purple_scene():
		#set_current_visibility_layer(1)
		set_visibility_layer_bit(1,true)
		print("Style Menu On Purple")
	else:
		#set_current_visibility_layer(2)
		set_visibility_layer_bit(2,true)
		print("Style Menu On Green")
	set_time_rank()
	set_lives_lost_rank()
	set_style_rank()
	set_overall_rank()
	self.show()
	
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
	if points >= all_total_point_thresholds[SCORE_RANKS.SSS]:
		overall_rank.text = "SSS"
	elif points >= all_total_point_thresholds[SCORE_RANKS.S]:
		overall_rank.text = "S"
	elif points >= all_total_point_thresholds[SCORE_RANKS.A]:
		overall_rank.text = "A"	
	elif points >= all_total_point_thresholds[SCORE_RANKS.B]:
		overall_rank.text = "B"	
	elif points >= all_total_point_thresholds[SCORE_RANKS.C]:
		overall_rank.text = "C"	
	elif points >= all_total_point_thresholds[SCORE_RANKS.D]:
		overall_rank.text = "D"

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
		print("Style Vis Layer 2")
	elif flag == 2:
		visibility_layer = 3
		print("Style Vis Layer 3")
