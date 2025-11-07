extends Control
#Level6.gd


@onready var toolTips = $ToolTips
@onready var waveManager = $GameLayer/WaveManager

var footBallZombieText = "res://Assets/Text/TextFiles/FootBallTutorial.txt"
var footBallZombieAnim = preload("res://Assets/Zombies/Animations/Spriteframes/FootBall.tres")


func _ready():
	Global.resetSunflowerCount()
	process_mode = Node.PROCESS_MODE_ALWAYS
	#$GameLayer/GridManager.set_tiles_for_rows(0,1, 68)
	##$GameLayer/GridManager.set_tiles_for_rows(1,2, 66)
	#
	#$GameLayer/GridManager.set_tiles_for_rows(2,3, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(3,4, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(4,5, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(5,6, 63)
	#$GameLayer/GridManager.set_tiles_for_rows(6,7, 63)
	#
##	$GameLayer/GridManager.set_tiles_for_rows(7,8, 66)
	#$GameLayer/GridManager.set_tiles_for_rows(8,9, 69)
	
	toolTips.set_text_pause(footBallZombieText)
	toolTips.setAnim(footBallZombieAnim)
	toolTips.showButton()


func _on_tool_tips_tool_tip_hid() -> void:
	waveManager.canStartGame = true 


func _on_wave_manager_wave_2_almost_start() -> void:
	waveManager.startSecondWave()
