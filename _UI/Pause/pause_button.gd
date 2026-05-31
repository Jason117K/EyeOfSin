extends TextureButton

@onready var pauseMenu := $PauseMenu
#@onready var toolTips = $"../ToolTips"

func _ready() -> void:
	pass
#	visible = true 
	
func _process(_delta: float) -> void:
	if get_tree().paused == false :
		pauseMenu.visible = false

func _on_pressed() -> void:
	#print("PP Pause Button Pressed")
	#print("PAUSE GAME")
	get_tree().paused = true
	#pauseMenu.visible = true
	pauseMenu.visible = true
	Global.hide_notification_bar()
	#Global.game_controller.help_show_pause_menu_with_pause() 
	

func set_restart_levels(newLevel: String, newAltLevel: String) -> void:
	pauseMenu.set_restart_levels(newLevel,newAltLevel)

#func hide_toolTip():
	#if toolTips != null:
		#
		#toolTips.hide()
