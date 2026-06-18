extends Demon


func die_fromClearSpace() -> void:
	queue_free()

func _ready() -> void:
	disable_buff_nodes()

func disable_buff_nodes()->void:
	for child in $BuffNodesComponent.get_children():
		if child is Area2D:
			child.monitorable = false
			child.monitoring = false

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
