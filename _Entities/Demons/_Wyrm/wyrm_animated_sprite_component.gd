extends DemonSpriteComp

signal frame_changed_signal(animation_name: String, frame_index: int)
@onready var worm1 := $"../Worm1"
@onready var worm2 := $"../Worm2"
@onready var shell_back := $"../ShellBack"
@onready var egg := $"../Egg"
func receive_buff(new_form: String) -> void:
	var parent := get_parent()

	if parent.has_method("adjust_position"):
		parent.adjust_position(new_form)
	print("APPLYING BUFF FROM ",new_form )
	pass

func spawn_done() -> void:
	print("Wyrm Spawn Done Called ")
	if spawnAnimDone:
		pass
	else:
		#print("Demon Setting Speed Mult Back to ", default_anim_speed_scale)
		speed_scale = default_anim_speed_scale
		play()
		spawnAnimDone = true
		demon.can_show_preview = true 
		print("Wyrm Can Show Pre")
		
		
		
		
