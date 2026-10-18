extends SwapAbility

#10
#35


@onready var baal_eye := $BaalEye
@onready var baal_eye_aoe := $BaalAOE
# The dimension being buffed, set at apply time (begin() runs before the flip,
# so it is the dimension being entered).
var baal_group := ""
var buffed_demons : Array = []

func apply_swap_ability()->void:
	baal_eye.descend()
	baal_eye_aoe.show()
	baal_group = "Green" if Global.is_on_purple_dimension() else "Purple"
	buffed_demons.clear()
	# Untyped loop + validity check: Global.all_demons keeps freed demons until
	# the next level load, and a typed loop variable errors on one.
	for demon in Global.get_all_demons():
		_buff_if_eligible(demon)

# Demons placed while the eye is up are buffed too, once their spawn animation
# is done (it resets the sprite speed).
func append_new_demon(new_demon : Demon) -> void:
	if not is_active:
		return
	while is_active and is_instance_valid(new_demon) and not new_demon.spawn_done:
		await get_tree().physics_frame
	if is_active:
		_buff_if_eligible(new_demon)

func _buff_if_eligible(demon) -> void:
	if is_instance_valid(demon) and demon is Demon and demon.is_in_group(baal_group) and not demon.is_baal_buffed:
		demon.baal_buff()
		buffed_demons.append(demon)


# Only the demons this cast buffed are undone.
func undo_swap_ability() -> void:
	if is_active:
		for demon in buffed_demons:
			if is_instance_valid(demon):
				demon.undo_baal_buff()
		stop()	
	buffed_demons.clear()
	baal_eye.stop_descend()
	baal_eye_aoe.hide()
	
func get_icon()->Texture:
	return Global.baal_gaze_icon
