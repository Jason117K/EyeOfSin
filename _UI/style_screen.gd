extends Control

# Should Only Grab values and parse Letter Grade from those values 

@onready var time_label := $CenterContainer/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/TimeLabel
@onready var time_rank := $CenterContainer/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/TimeRank
var time_rank_value : SCORE_RANKS

@onready var lives_lost_label := $CenterContainer/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/LivesLostLabel
@onready var lives_lost_rank := $CenterContainer/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/LivesLostRank
var lives_lost_rank_value : SCORE_RANKS

@onready var style_label := $CenterContainer/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaLabelsVbox/StyleLabel
@onready var style_rank := $CenterContainer/AllPanelsVbox/ScoringHbox/MainCriteriaPanel/MainCriteriaHbox/CriteriaScoringRanksVbox/StyleRank
var style_rank_value : SCORE_RANKS

var all_rank_values : Array[SCORE_RANKS] = [time_rank_value,lives_lost_rank_value,style_rank_value]

@onready var overall_score_label := $CenterContainer/AllPanelsVbox/TotalScorePanel/TotalScoreHbox/TotalScoreNum
@onready var overall_rank := $CenterContainer/AllPanelsVbox/ScoringHbox/StyleRankLetterPanel/StyleRankLetterLabel

@export var SSS_STYLE_POINTS_MIN := 2000
@export var S_STYLE_POINTS_MIN := 1500
@export var A_STYLE_POINTS_MIN := 1000
@export var B_STYLE_POINTS_MIN := 700
@export var C_STYLE_POINTS_MIN := 400
@export var D_STYLE_POINTS_MIN := 100

var all_style_point_thresholds : Array[int] 
		
@export var SSS_TIME_MIN := 120
@export var S_TIME_MIN := 110
@export var A_TIME_MIN := 100
@export var B_TIME_MIN := 90
@export var C_TIME_MIN := 80
@export var D_TIME_MIN := 70

var all_time_thresholds :Array[int] 

@export var SSS_TOTAL_POINTS_MIN := 5000
@export var S_TOTAL_POINTS_MIN := 4000
@export var A_TOTAL_POINTS_MIN := 3000
@export var B_TOTAL_POINTS_MIN := 2000
@export var C_TOTAL_POINTS_MIN := 1000
@export var D_TOTAL_POINTS_MIN := 500

var all_total_point_thresholds :Array[int] 

enum SCORE_RANKS{SSS,S,A,B,C,D}

func _ready() -> void:
	
	all_total_point_thresholds = [SSS_TOTAL_POINTS_MIN,S_TOTAL_POINTS_MIN,
						A_TOTAL_POINTS_MIN,B_TOTAL_POINTS_MIN,C_TOTAL_POINTS_MIN,D_TOTAL_POINTS_MIN]
	all_time_thresholds  = [SSS_TIME_MIN,S_TIME_MIN,A_TIME_MIN,B_TIME_MIN,
											C_TIME_MIN,D_TIME_MIN]
	all_style_point_thresholds = [SSS_STYLE_POINTS_MIN,S_STYLE_POINTS_MIN,
		A_STYLE_POINTS_MIN,B_STYLE_POINTS_MIN,C_STYLE_POINTS_MIN,D_STYLE_POINTS_MIN]
		
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
	
func set_time_rank()->void:
	time_label.text = "TIME: " + str(int(ScoreManager.get_completion_time()))
	if ScoreManager.get_completion_time() <= SSS_TIME_MIN: 
		time_rank.text = "SSS"
		time_rank_value = SCORE_RANKS.SSS
	if ScoreManager.get_completion_time() <= S_TIME_MIN: 
		time_rank.text = "S"
		time_rank_value = SCORE_RANKS.S
	if ScoreManager.get_completion_time() <= A_TIME_MIN: 
		time_rank.text = "A"
		time_rank_value = SCORE_RANKS.A
	if ScoreManager.get_completion_time() <= B_TIME_MIN: 
		time_rank.text = "B"
		time_rank_value = SCORE_RANKS.B
	if ScoreManager.get_completion_time() <= C_TIME_MIN: 
		time_rank.text = "C"
		time_rank_value = SCORE_RANKS.C
	if ScoreManager.get_completion_time() <= D_TIME_MIN: 
		time_rank.text = "D"
		time_rank_value = SCORE_RANKS.D

func set_lives_lost_rank()->void:
	lives_lost_label.text = "LIVES LOST: " + str(ScoreManager.get_lives_lost())
	if ScoreManager.get_lives_lost() > 0:
		lives_lost_rank.text = "B"
		lives_lost_rank_value = SCORE_RANKS.B
	else:
		lives_lost_rank.text = "SSS"
		lives_lost_rank_value = SCORE_RANKS.SSS
	
func set_style_rank()->void:
	style_label.text = "DEMON POINTS: " + str(int(ScoreManager.get_style_points_before_bonus()))
	if ScoreManager.get_style_points_before_bonus() >= SSS_STYLE_POINTS_MIN:
		style_rank.text = "SSS"
		style_rank_value = SCORE_RANKS.SSS
	elif ScoreManager.get_style_points_before_bonus() >= S_STYLE_POINTS_MIN:
		style_rank.text = "S"
		style_rank_value = SCORE_RANKS.S
	elif ScoreManager.get_style_points_before_bonus() >= A_STYLE_POINTS_MIN:
		style_rank.text = "A"
		style_rank_value = SCORE_RANKS.A
	elif ScoreManager.get_style_points_before_bonus() >= B_STYLE_POINTS_MIN:
		style_rank.text = "B"
		style_rank_value = SCORE_RANKS.B
	elif ScoreManager.get_style_points_before_bonus() >= C_STYLE_POINTS_MIN:
		style_rank.text = "C"
		style_rank_value = SCORE_RANKS.C
	elif ScoreManager.get_style_points_before_bonus() >= D_STYLE_POINTS_MIN:
		style_rank.text = "D"
		style_rank_value = SCORE_RANKS.D
			
func set_overall_rank()->void:
	
	ScoreManager.calc_total_level_score()
	overall_score_label.text = str(int(ScoreManager.get_total_score()))
	if ScoreManager.get_total_score() >= SSS_TOTAL_POINTS_MIN:
		overall_rank.text = "SSS"
	elif ScoreManager.get_total_score() >= S_TOTAL_POINTS_MIN:
		overall_rank.text = "S"
	elif ScoreManager.get_total_score() >= A_TOTAL_POINTS_MIN:
		overall_rank.text = "A"	
	elif ScoreManager.get_total_score() >= B_TOTAL_POINTS_MIN:
		overall_rank.text = "B"	
	elif ScoreManager.get_total_score() >= C_TOTAL_POINTS_MIN:
		overall_rank.text = "C"	
	elif ScoreManager.get_total_score() >= D_TOTAL_POINTS_MIN:
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
