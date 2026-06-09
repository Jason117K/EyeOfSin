extends TextureButton

@onready var pauseMenu := $PauseMenu
#@onready var toolTips = $"../ToolTips"

func _ready() -> void:
	pass
#	visible = true 
	
func _process(_delta: float) -> void:
	if get_tree().paused == false :
		pauseMenu.visible = false

func set_pause_process_mode():
	pauseMenu.set_pause_process_mode()
	
	
func _on_pressed() -> void:
	print("PP Pause Button Pressed, Pause Menu is ",pauseMenu )
	print("PAUSE GAME")
	get_tree().paused = true
	#pauseMenu.visible = true
	pauseMenu.visible = true
	pauseMenu.show()
	Global.hide_notification_bar()
	#Global.game_controller.help_show_pause_menu_with_pause() 
	

func set_restart_levels(newLevel: String, newAltLevel: String) -> void:
	print("Set restart levels ot ", newAltLevel,newLevel)
	pauseMenu.set_restart_levels(newLevel,newAltLevel)

#func hide_toolTip():
	#if toolTips != null:
		#
		#toolTips.hide()
