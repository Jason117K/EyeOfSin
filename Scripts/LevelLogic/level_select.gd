extends Control


var canPlayLevel2 := false 
var canPlayLevel3 := false 
var canPlayLevel4 := false 
var canPlayLevel5 := false 
var canPlayLevel6 := false 
var canPlayLevel7 := false 

var startScreen = ("res://Scenes/LevelScenes/StartScreen.tscn")
var level1 = ("res://Scenes/LevelScenes/Main.tscn")
var level2 = ("res://Scenes/LevelScenes/Level2.tscn")
var level3 = ("res://Scenes/LevelScenes/Level3.tscn")
var level4 = ("res://Scenes/LevelScenes/Level4.tscn")
var level5 = ("res://Scenes/LevelScenes/Level5.tscn")
var level6 = ("res://Scenes/LevelScenes/Level6.tscn")
var level7 = ("res://Scenes/LevelScenes/Level7.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	canPlayLevel2 = Global.getCanPlayLevel2()
	canPlayLevel3 = Global.getCanPlayLevel3()
	canPlayLevel4 = Global.getCanPlayLevel4()
	canPlayLevel5 = Global.getCanPlayLevel5()
	canPlayLevel6 = Global.getCanPlayLevel6()
	canPlayLevel7 = Global.getCanPlayLevel7()
	$GridManager.set_tiles_for_rows(0,1, 68)
	$GridManager.set_tiles_for_rows(1,2, 66)
	
	$GridManager.set_tiles_for_rows(2,3, 63)
	$GridManager.set_tiles_for_rows(3,4, 63)
	$GridManager.set_tiles_for_rows(4,5, 63)
	$GridManager.set_tiles_for_rows(5,6, 63)
	$GridManager.set_tiles_for_rows(6,7, 63)
	
	$GridManager.set_tiles_for_rows(7,8, 66)
	$GridManager.set_tiles_for_rows(8,9, 69)

func _on_level_1_pressed() -> void:
	#assert(get_tree().change_scene_to_file(level1) ==OK)
	Global.game_controller.change_scene(level1)
	


func _on_level_2_pressed() -> void:
	if canPlayLevel2:
		#assert(get_tree().change_scene_to_file(level2) ==OK)
		Global.game_controller.change_scene(level2)


func _on_level_3_pressed() -> void:
	if canPlayLevel3:
		#assert(get_tree().change_scene_to_file(level3) ==OK)
		Global.game_controller.change_scene(level3)

func _on_level_4_pressed() -> void:
	if canPlayLevel4:
		#assert(get_tree().change_scene_to_file(level4) ==OK)
		Global.game_controller.change_scene(level4)

func _on_level_5_pressed() -> void:
	if canPlayLevel5:
		#assert(get_tree().change_scene_to_file(level5) ==OK)
		Global.game_controller.change_scene(level5)


func _on_level_6_pressed() -> void:
	if canPlayLevel6:
		#assert(get_tree().change_scene_to_file(level6) ==OK)
		Global.game_controller.change_scene(level6)


func _on_level_7_pressed() -> void:
	if canPlayLevel7:
		#assert(get_tree().change_scene_to_file(level7) ==OK)
		Global.game_controller.change_scene(level7)


func _on_back_pressed() -> void:
	#get_tree().root.set_input_as_handled()
	#await get_tree().create_timer(0.1).timeout
	#assert(get_tree().change_scene_to_file("res://Scenes/LevelScenes/StartScreen.tscn") == OK)
	Global.game_controller.change_scene(startScreen)
