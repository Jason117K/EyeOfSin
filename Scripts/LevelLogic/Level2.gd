extends Control
#Level2

@onready var toolTips = $ToolTips
@onready var waveManager = $GameLayer/WaveManager

var eyeBombText = "res://Assets/Text/TextFiles/EyeBomb.txt"
var suicideBomberText = "res://Assets/Text/TextFiles/TickerTutorial.txt"
var dancerTutorial = "res://Assets/Text/TextFiles/DancerTutorial.txt"
var eggWormTutorial = "res://Assets/Text/TextFiles/EggWormTutorial.txt"

var eyeBombAnim = preload("res://Assets/Plants/Spriteframes/eyeBombAnim.tres")
var suicideBomberAnim = preload("res://Assets/Zombies/Animations/Spriteframes/TickerFrames.tres")
var dancerAnim = preload("res://Assets/Zombies/Animations/Spriteframes/DancerAnim.tres")
var eggWormAnim = preload("res://Assets/Plants/Spriteframes/EggWorm.tres")

var placedEye := false 
var placedEgg : = false

# Called when the node enters the scene tree for the first time.
func _ready():
#	$GameLayer/GridManager.set_tiles_for_rows(0,1, 28)
	$GameLayer/GridManager.set_tiles_for_rows(0,1, 68)
	$GameLayer/GridManager.set_tiles_for_rows(1,2, 66)
	
	$GameLayer/GridManager.set_tiles_for_rows(2,3, 63)
	$GameLayer/GridManager.set_tiles_for_rows(3,4, 63)
	$GameLayer/GridManager.set_tiles_for_rows(4,5, 63)
	$GameLayer/GridManager.set_tiles_for_rows(5,6, 63)
	$GameLayer/GridManager.set_tiles_for_rows(6,7, 63)
	
	$GameLayer/GridManager.set_tiles_for_rows(7,8, 66)
	$GameLayer/GridManager.set_tiles_for_rows(8,9, 69)
	
	#Sets the first tutorial popup
	toolTips.set_text(eyeBombText)
	toolTips.setAnim(eyeBombAnim)
	toolTips.noButtonShow()


func _on_plant_manager_eye_bomb_placed() -> void:
	if !placedEye:
		
		toolTips.hide()
		waveManager.canStartGame = true
		placedEye = true 


func _on_tool_tips_tool_tip_hid() -> void:
	$GameLayer/WaveManager.canStartGame = true 
	print("Let the games begin")


func _on_wave_manager_wave_1_started() -> void:
	toolTips.set_text_pause(suicideBomberText)
	toolTips.setAnim(suicideBomberAnim)
	toolTips.showButton()
	

func _on_wave_manager_wave_2_started() -> void:
	toolTips.set_text_pause(dancerTutorial)
	toolTips.setAnim(dancerAnim)
	toolTips.showButton()


func _on_wave_manager_wave_2_almost_start() -> void:
	toolTips.set_text(eggWormTutorial)
	toolTips.setAnim(eggWormAnim)
	toolTips.noButtonShow()


func _on_plant_manager_egg_worm_placed() -> void:
	if !placedEgg:
		toolTips.hide()
		waveManager.startSecondWave()
		placedEgg = true
