extends Control
#Level7.gd
#1000 Starting Blood

@onready var toolTips = $ToolTips
@onready var waveManager = $GameLayer/WaveManager

var poleVaultZombieText = "res://Assets/Text/TextFiles/PoleVaultTutorial.txt"
var poleVaultZombieAnim = preload("res://Assets/Zombies/Animations/Spriteframes/Leaper.tres")


func _ready():
	Global.resetSunflowerCount()
	process_mode = Node.PROCESS_MODE_ALWAYS
	#$GameLayer/GridManager.set_tiles_for_rows(0,1, 68)
	#$GameLayer/GridManager.set_tiles_for_rows(1,2, 66)
	#
	#$GameLayer/GridManager.set_tiles_for_rows(2,3, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(3,4, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(4,5, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(5,6, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(6,7, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(7,8, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(8,9, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(7,8, 66)
	#$GameLayer/GridManager.set_tiles_for_rows(9,10, 69)
	
	toolTips.set_text_pause(poleVaultZombieText)
	toolTips.setAnim(poleVaultZombieAnim)
	toolTips.showButton()


func _on_tool_tips_tool_tip_hid() -> void:
	waveManager.canStartGame = true 


func _on_wave_manager_wave_2_almost_start() -> void:
	waveManager.startSecondWave()

func make_camera_current():
	$Camera2D.make_current()
