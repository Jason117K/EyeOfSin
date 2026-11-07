class_name ReviveDemonController
extends HeroAbilityComponent


@onready var lightning_revive_anim := $"../Lightning_Revive"
@onready var lightning_revive_detection := $"../Revive_Detection"

var demons_to_revive : Array[Area2D] = []
var revive_fx_offset_y : float


func _ready() -> void:
	super()
	lightning_revive_anim.visible = false
	lightning_revive_anim.stop()
	revive_fx_offset_y = lightning_revive_anim.position.y
	lightning_revive_anim.animation_finished.connect(lightning_revive_anim.hide)
	if is_demo:
		return
	lightning_revive_detection.area_entered.connect(add_to_revive_array)
	check_for_demons_to_revive()
			
func check_for_demons_to_revive()->void:
	for revive_point in lightning_revive_detection.get_overlapping_areas():
		if revive_point.is_in_group("Demon_Revive_Point"):
			#print("[HERO_REVIVE]: About to Add Revive Point : ", revive_point)
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
			#print("[HERO_REVIVE]: Def Add Revive Point : ", _new_demon)
			demons_to_revive.append(_new_demon)
			await get_tree().physics_frame
			await get_tree().physics_frame
			await get_tree().physics_frame
			#print("[HERO_REVIVE]: Demons to Revive Is : ", demons_to_revive)
			begin()


func begin() -> void:
	super()
	

func apply_ability()->void:
	revive_demon()

func revive_demon()->void:
	#print("[HERO_REVIVE]: Calling Revive Demon : ", demons_to_revive)
	demons_to_revive = demons_to_revive.filter(func(point) -> bool: return is_instance_valid(point))
	for res_point in demons_to_revive:
		play_revive_fx(res_point.global_position)
		res_point.revive_summon()
		ability_end()
		return
	is_active = false
	is_on_cooldown = false


func play_revive_fx(target_global_position: Vector2) -> void:
	var hero := lightning_revive_anim.get_parent() as Node2D
	lightning_revive_anim.position = hero.to_local(target_global_position) + Vector2(0, revive_fx_offset_y)
	lightning_revive_anim.show()
	lightning_revive_anim.play(&"default")
			
	
		
		
func ability_end() -> void:
	super()





	
