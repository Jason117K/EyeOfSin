extends SwapAbility
@onready var baal_eye := $BaalEye
@onready var baal_eye_aoe := $BaalAOE
func apply_swap_ability()->void:
	baal_eye.descend()
	baal_eye_aoe.show()
	for demon : Demon in Global.get_all_demons():
		if demon != null && is_instance_valid(demon):
			if Global.is_on_purple_dimension():
				if !demon.is_in_group("Purple"):
					demon.baal_buff()
			else:
				if !demon.is_in_group("Green"):
					demon.baal_buff()


func undo_swap_ability() -> void:
	if is_active:
		for demon : Demon in Global.get_all_demons():
			if demon != null:
				demon.undo_baal_buff()
		stop()	
	baal_eye.stop_descend()
	baal_eye_aoe.hide()
	
func get_icon()->Texture:
	return Global.baal_gaze_icon
