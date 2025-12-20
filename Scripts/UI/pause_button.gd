extends Button

@onready var pauseMenu = $PauseMenu


func _ready() -> void:
	visible = true 
	
func _process(delta: float) -> void:
	if get_tree().paused == false :
		pauseMenu.visible = false 
		
func _on_pressed() -> void:
	print("PP Pause Button Pressed")
	get_tree().paused = true 
	pauseMenu.visible = true 

func set_restart_levels(newLevel,newAltLevel):
	pauseMenu.set_restart_levels(newLevel,newAltLevel)
