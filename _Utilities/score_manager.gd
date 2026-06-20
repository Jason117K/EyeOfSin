extends Node

var total_score : float = 0

var synergy_multiplier := 1.0
var synergy_multiplier_increase := 0.1
var synergy_score_to_add := 200 
var demon_base_score_value := 50

var style_points_before_bonus := 0

var num_waves_called_early := 0 
var early_wave_bonus := 75 

var lives_lost := 0 
var no_lives_lost_bonus := 750 
var some_lives_lost_bonus := 150 

var SSS_Rank_Completion_Bonus : float = 3000
var S_Rank_Completion_Bonus : float = 2500
var A_Rank_Completion_Bonus : float = 2000
var B_Rank_Completion_Bonus : float = 1500
var C_Rank_Completion_Bonus : float = 1000
var D_Rank_Completion_Bonus : float = 500

var SSS_Rank_Completion_Time : float 
var S_Rank_Completion_Time : float 
var A_Rank_Completion_Time : float 
var B_Rank_Completion_Time : float 
var C_Rank_Completion_Time : float 
var D_Rank_Completion_Time : float 
var completion_time_bonus : float 
var completion_time_rank : SCORE_RANKS
var completion_time : float 
var all_completion_time_ranks : Array[float] = [SSS_Rank_Completion_Time,S_Rank_Completion_Time,
						A_Rank_Completion_Time,B_Rank_Completion_Time,C_Rank_Completion_Time,
						D_Rank_Completion_Time]


enum SCORE_RANKS{SSS,S,A,B,C,D}

@warning_ignore("unused_signal")
signal level_ended 

#Score From 
# - Num Demons Alive At End (+Bonus for being alive longer)
# - Num Demon Synergies (+Bonus for num variations)   
# - Completion Time     (Tiered, shorter is better)
# - Num Waves Called Early 
# - No Lives Lost Bonus 
  


func _ready() -> void:
	pass
	
func calc_total_level_score()->float:
	@warning_ignore("narrowing_conversion")
	style_points_before_bonus = total_score
	var score_to_add : float = num_waves_called_early * early_wave_bonus 
	score_to_add += get_lives_lost_bonus()
	score_to_add += completion_time_bonus
	
	total_score = total_score + score_to_add 
	
	return total_score

func set_style_points_before_bonus()->void:
	print("Style Points Before Bonus is ", total_score)
	style_points_before_bonus = total_score
	
func add_score_from_demon(time_alive_secs : float, is_demon_buffed : bool = false)->void:
	var score_to_add : float = demon_base_score_value
	score_to_add += time_alive_secs 
	print("Score to Add From Demon is ", score_to_add)
	
	if is_demon_buffed:
		score_to_add += add_score_from_synergy()
		print("Demon Was Buffed, Score to Add is ",score_to_add)
		
	print("Total Score Is now ", total_score)
	total_score += score_to_add
	
func add_score_from_synergy()->float:
	var score_to_add : float 
	score_to_add = synergy_score_to_add * synergy_multiplier
	synergy_multiplier += synergy_multiplier_increase
	
	return score_to_add

func wave_called_early()->void:
	num_waves_called_early += 1 

func get_lives_lost_bonus()->float:
	if lives_lost == 0:
		return no_lives_lost_bonus
	else:
		return some_lives_lost_bonus

func set_lives_lost()->void:
	lives_lost = lives_lost + 1


func set_completion_times(new_completion_time_thresholds : Array)->void:
	var count :int= 0 
	for completion_time_threshold : float in new_completion_time_thresholds:
		all_completion_time_ranks[count] = completion_time_threshold
		count += 1
	
	
func calc_completion_time_rank(new_completion_time : float)->void:
	completion_time = new_completion_time
	if completion_time <= SSS_Rank_Completion_Time:
		completion_time_rank = SCORE_RANKS.SSS
		completion_time_bonus = SSS_Rank_Completion_Bonus
	elif completion_time <= S_Rank_Completion_Time:
		completion_time_rank = SCORE_RANKS.S
		completion_time_bonus = S_Rank_Completion_Bonus
	elif completion_time <= A_Rank_Completion_Time:
		completion_time_rank = SCORE_RANKS.A
		completion_time_bonus = A_Rank_Completion_Bonus
	elif completion_time <= B_Rank_Completion_Time:
		completion_time_rank = SCORE_RANKS.B
		completion_time_bonus = B_Rank_Completion_Bonus
	elif completion_time <= C_Rank_Completion_Time:
		completion_time_rank = SCORE_RANKS.C
		completion_time_bonus = C_Rank_Completion_Bonus
	elif completion_time <= D_Rank_Completion_Time:
		completion_time_rank = SCORE_RANKS.D
		completion_time_bonus = D_Rank_Completion_Bonus


		
		
func get_style_points_before_bonus()->float:
	set_style_points_before_bonus()
	return style_points_before_bonus
	

	

func get_completion_time()->float:
	return completion_time
	
	
func get_lives_lost()->int:
	return lives_lost

func get_total_score()->float:
	return total_score
	
	
	
	
		
	
