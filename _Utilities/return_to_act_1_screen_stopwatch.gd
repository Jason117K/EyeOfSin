extends Timer

@export var allowed_elapsed_time := 45
var elapsed_time : float = 0 



func _on_timeout() -> void:
	elapsed_time += self.wait_time 
	if elapsed_time >= allowed_elapsed_time:
		Global.show_trailer_footage()
		elapsed_time = 0
		

func reset_timer()->void:
	elapsed_time = 0
	if !self.is_stopped():
		Global.stop_trailer_footage()
	
