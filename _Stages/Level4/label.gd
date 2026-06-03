extends Label

func _process(delta: float) -> void:
	text = str(Engine.get_frames_per_second())
	text = "%d fps  %.2f ms" % [
		Engine.get_frames_per_second(),Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0]
