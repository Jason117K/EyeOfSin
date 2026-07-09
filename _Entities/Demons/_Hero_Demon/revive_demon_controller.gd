extends HeroAbilityComponent


@onready var lightning_revive_anim := $"../Lightning_Revive"
@onready var lightning_revive_detection := $"../Revive_Detection"

var demons_to_revive : Array[Area2D] = []


func _ready() -> void:
	super()
	lightning_revive_detection.area_entered.connect(add_to_revive_array) 
	lightning_revive_anim.visible = false 
	lightning_revive_anim.stop()
	
	check_for_demons_to_revive()
			
func check_for_demons_to_revive()->void:
	for revive_point in lightning_revive_detection.get_overlapping_areas():
		if revive_point.is_in_group("Demon_Revive_Point"):
			print("[HERO_REVIVE]: About to Add Revive Point : ", revive_point)
			add_to_revive_array(revive_point)
	
		

func get_detection_area()->Area2D:
	return lightning_revive_detection
	
func reset_cooldown() -> void:
	is_on_cooldown = false


func add_to_revive_array(_new_demon:Area2D)->void:
	if demons_to_revive.has(_new_demon):
		return 
	else:
		if _new_demon.is_in_group("Demon_Revive_Point"):
			print("[HERO_REVIVE]: Def Add Revive Point : ", _new_demon)
			demons_to_revive.append(_new_demon)
			await get_tree().physics_frame
			await get_tree().physics_frame
			await get_tree().physics_frame
			print("[HERO_REVIVE]: Demons to Revive Is : ", demons_to_revive)
			begin()


func begin() -> void:
	super()
	

func apply_ability()->void:
	revive_demon()

func revive_demon()->void:
	print("[HERO_REVIVE]: Calling Revive Demon : ", demons_to_revive)
	for res_point in demons_to_revive:
		if is_instance_valid(res_point) && res_point != null:
			res_point.revive_summon()
			ability_end()
			return 
			
	
		
		
func ability_end() -> void:
	super()





	
