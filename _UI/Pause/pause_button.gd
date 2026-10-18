extends TextureButton

@onready var pauseMenu := $PauseMenu
var toolTips : Control
var previous_toolTip_visibility : bool
@onready var demon_selection_menu := $"../../../../.."

var can_click := true 

func _ready() -> void:
	
	pass
#	visible = true 
	
func _process(_delta: float) -> void:
	if get_tree().paused == false :
		pauseMenu.visible = false

func set_pause_process_mode():
	pauseMenu.set_pause_process_mode()
	
	
func _on_pressed() -> void:
	if can_click:
		open_pause_menu()

func open_pause_menu() -> void:
	toolTips = demon_selection_menu.get_tooltips()
	##print("Tooltips is ", toolTips)
	toolTips.set_modulate_invis()
	#toolTips.modulate = Color(1,1,1,0)
	##print("PP Pause Button Pressed, Pause Menu is ",pauseMenu )
	##print("PAUSE GAME")
	get_tree().paused = true
	#pauseMenu.visible = true


	pauseMenu.visible = true
	pauseMenu.show()
	Global.hide_notification_bar()
	#Global.game_controller.help_show_pause_menu_with_pause()

# Hides this dimension's menu without unpausing (a swap while paused hands the
# open menu to the other dimension).
func close_pause_menu() -> void:
	undo_toolTip_change()
	pauseMenu.hide()

func undo_toolTip_change()->void:
	# Null until this dimension's menu has been opened.
	if toolTips != null:
		toolTips.modulate = Color(1,1,1,1)

func set_restart_levels(newLevel: String, newAltLevel: String) -> void:
	#print("Set restart levels ot ", newAltLevel,newLevel)
	pauseMenu.set_restart_levels(newLevel,newAltLevel)

#func hide_toolTip():
	#if toolTips != null:
		#
		#toolTips.hide()
