extends Demon


func die_fromClearSpace() -> void:
	queue_free()

func _ready() -> void:
	pass


func on_demon_area_entered(new_area: Area2D) -> void:
	pass

func on_demon_area_exited(old_area: Area2D) -> void:
	pass

func receive_buff(newDemon) -> void:
	pass


func truncate_string(input_string: String) -> String:
	pass
	return ""

func receive_heart_buff() -> void:
	pass

func remove_heart_buff() -> void:
	pass
