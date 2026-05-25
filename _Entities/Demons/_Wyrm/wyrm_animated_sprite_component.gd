extends DemonSpriteComp

func receive_buff(new_form: String) -> void:
	var parent := get_parent()

	if parent.has_method("adjust_position"):
		parent.adjust_position(new_form)
	print("APPLYING BUFF FROM ",new_form )
	pass
