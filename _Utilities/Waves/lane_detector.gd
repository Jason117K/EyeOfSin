extends Area2D

signal zombie_detected(detector_area : Area2D, is_green:bool)

var is_disabled := false 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		if area.is_in_group("Green") && !is_disabled:
			print(self, "Green Zombie Detected Emititing")
			zombie_detected.emit(self,true)
			set_disabled()
		elif area.is_in_group("Purple") && !is_disabled:
			print(self,"Purple Zombie Detected Emitting cos of ", area)
			zombie_detected.emit(self,false)
			set_disabled()

func set_disabled()->void:
	
	self.monitoring = false
	is_disabled = true
	
