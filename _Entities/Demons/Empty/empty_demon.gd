extends Demon


func die_fromClearSpace():
	queue_free()		

func _ready() -> void:
	pass
	
	
func on_demon_area_entered(new_area: Area2D):
	pass
		
func on_demon_area_exited(old_area: Area2D):
	pass
	
func receive_buff(newDemon):
	pass


func truncate_string(input_string: String) -> String:
	pass
	return ""
	
func receive_heart_buff():
	pass
	
func remove_heart_buff():
	pass
