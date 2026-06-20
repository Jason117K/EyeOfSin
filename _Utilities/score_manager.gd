extends Node

var total_score : float = 0
var synergy_multiplier := 1.0
var synergy_multiplier_increase := 0.1
var synergy_score_to_add := 200 
var demon_base_score_value := 50
var num_waves_called_early := 0 

var completion_time : float 
var gold_completion_time : float 
var silver_completion_time : float 
var bronze_completion_time : float 

var gold_time_bonus := 550 
var silver_time_bonus := 250 
var bronze_time_bonus := 50 

var early_wave_bonus := 75 

var lives_lost := 0 
var no_lives_lost_bonus := 750 
var some_lives_lost_bonus := 150 

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
	var score_to_add : float = num_waves_called_early * early_wave_bonus 
	score_to_add += get_lives_lost_bonus()
	
	total_score = total_score + score_to_add 
	
	return total_score
	
	
func add_score_from_demon(time_alive_secs : float, is_demon_buffed : bool = false)->void:
	var score_to_add : float = demon_base_score_value
	score_to_add += time_alive_secs 
	
	if is_demon_buffed:
		score_to_add += add_score_from_synergy()
	
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


func calc_completion_time_bonus(new_completion_time : float)->void:
	completion_time = new_completion_time
	if completion_time <= gold_completion_time:
		total_score += gold_time_bonus
	elif completion_time <= silver_completion_time:
		total_score += silver_time_bonus
	else:
		total_score += bronze_time_bonus
	
	
func set_gold_time(new_gold_time:float)->void:
	gold_completion_time = new_gold_time

	
func set_silver_time(new_gold_time:float)->void:
	gold_completion_time = new_gold_time

	
func set_bronze_time(new_gold_time:float)->void:
	gold_completion_time = new_gold_time
	
	
func get_completion_time()->float:
	return completion_time
	
func get_lives_lost()->int:
	return lives_lost

func get_total_score()->float:
	return total_score
	
	
	
	
		
	
