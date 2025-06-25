extends Button

@onready var pauseMenu = $PauseMenu

func _process(delta: float) -> void:
	if get_tree().paused == false :
		pauseMenu.visible = false 
		
func _on_pressed() -> void:
	get_tree().paused = true 
	pauseMenu.visible = true 
