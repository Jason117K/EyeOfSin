extends Demon


func die_fromClearSpace() -> void:
	queue_free()

func _ready() -> void:
	pass


func on_demon_area_entered(_new_area: Area2D) -> void:
	pass

func on_demon_area_exited(_old_area: Area2D) -> void:
	pass

func receive_buff(_newDemon:String) -> void:
	pass


func truncate_string(_input_string: String) -> String:
	pass
	return ""

func receive_heart_buff() -> void:
	pass

func remove_heart_buff() -> void:
	pass
