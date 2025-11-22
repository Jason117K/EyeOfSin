extends Control
#MainController.gd 

@onready var toolTips = $Main/ToolTips
@onready var altToolTips = $MainAlternate/ToolTips
@export var make_green := false 

var startingTutorialText = "res://Assets/Text/TextFiles/FirstTutorial.txt"
var sunFlowerText = "res://Assets/Text/TextFiles/SunflowerIntro.txt"
var placeSummonText = "res://Assets/Text/TextFiles/PlaceSummon.txt"
var spyderTutorialText = "res://Assets/Text/TextFiles/SpyderTutorial.txt"
var basicOffenseDefenseText = "res://Assets/Text/TextFiles/basicOffensiveDefense.txt"
var walnutTutorial = "res://Assets/Text/TextFiles/OccularSpineTutorial.txt"
var coneheadTutorial = "res://Assets/Text/TextFiles/ConeheadTutorial.txt"
var dancerTutorial = "res://Assets/Text/TextFiles/DancerTutorial.txt"
var bucketHeadTutorial = "res://Assets/Text/TextFiles/BucketHeadTutorial.txt"

var coneheadAnim = preload("res://Assets/Zombies/Animations/Spriteframes/Severed.tres")
var dancerAnim = preload("res://Assets/Zombies/Animations/Spriteframes/DancerAnim.tres")
var eyeAnim = preload("res://Assets/Zombies/Animations/Spriteframes/eyeFrames.tres")
var walnutAnim = preload("res://Assets/Zombies/Animations/Spriteframes/walnutFrames.tres")
var spyderAnim = preload("res://Assets/Zombies/Animations/Spriteframes/spyderFrames.tres")
var bucketHeadAnim = preload("res://Assets/Zombies/Animations/Spriteframes/BucketHead.tres")

var showNextTutuorial : bool = false
var sunflowerPlaced := false
var spyderPlaced := false
var walnutPlaced := false 

var count : int = 1

@onready var waveManager = $Main/GameLayer/WaveManager
@onready var plantManager = $Main/PlantManager

@onready var waveManagerAlt = $MainAlternate/GameLayer/WaveManager
@onready var plantManagerAlt = $MainAlternate/PlantManager
#Sets up Tilemap 
func _ready():
	attach_script_to_coral_children("res://Scripts/Environment/sway.gd")
	Global.resetSunflowerCount()
	process_mode = Node.PROCESS_MODE_ALWAYS

	print("Child is ", get_child(0))
	print("I am  ", self)
	#Sets the first tutorial popup
	toolTips.set_text(startingTutorialText)
	make_camera_current()
	
	
func _process(delta: float) -> void:
	if showNextTutuorial && count < 2:
		toolTips.set_text(sunFlowerText)
		$Main/PlantSelectionMenu.showEyeSummon()
		$MainAlternate/PlantSelectionMenu.showEyeSummon()
		count = count + 1
		toolTips.noButtonShow()

func _on_tool_tips_tool_tip_hid() -> void:
	if showNextTutuorial:
		$MainAlternate/GameLayer/WaveManager.canStartGame = true 
		#print("Let the games begin")
	showNextTutuorial = true 



func _on_plant_selection_menu_clicked_eye() -> void:
	
	if count < 3:
		
		toolTips.set_text(placeSummonText)
		toolTips.setAnim(eyeAnim)
		toolTips.noButtonShow()
		count = count + 1


func _on_plant_manager_plant_placed() -> void:
	if !sunflowerPlaced:
		toolTips.set_text(spyderTutorialText)
		toolTips.setAnim(spyderAnim)
		sunflowerPlaced = true 


func _on_plant_manager_spyder_placed() -> void:
	if !spyderPlaced:
		toolTips.set_text(basicOffenseDefenseText)
		toolTips.showButton()
		spyderPlaced = true 


func _on_wave_manager_wave_2_almost_start() -> void:
	toolTips.set_text(walnutTutorial)
	toolTips.setAnim(walnutAnim)
	toolTips.noButtonShow()
	pass


func _on_plant_manager_walnut_placed() -> void:
	if !walnutPlaced:
		toolTips.hide()
		print("Walnut Placed")
		waveManager.startSecondWave()
		walnutPlaced = true


func _on_wave_manager_wave_2_started() -> void:
	toolTips.set_text_pause(coneheadTutorial)
	toolTips.setAnim(coneheadAnim)
	toolTips.showButton()
	pass # Replace with function body.


func _on_wave_manager_wave_3_started() -> void:
	toolTips.set_text_pause(bucketHeadTutorial)
	toolTips.setAnim(bucketHeadAnim)
	toolTips.showButton()
	pass # Replace with function body.

func make_camera_current():
	$Main/Camera2D.make_current()
	if $MainAlternate/Camera2D != null:
			
		$MainAlternate/Camera2D.make_current()

func attach_script_to_coral_children(script_path: String) -> void:

	# Find the Coral node
	var coral_node = get_node("Environment/Coral")
	
	if coral_node == null:
		push_error("Coral node not found at Environment/Coral")
		return
	
	
	# Load the script to attach
	var script_to_attach = load(script_path)
	
	if script_to_attach == null:
		push_error("Failed to load script at: " + script_path)
		return
	
	# Iterate through all children and attach the script
	for child in coral_node.get_children():
		child.set_script(script_to_attach)
		if child.is_inside_tree() and child.has_method("_ready"):
			if make_green:
				child.make_green()
			child._ready()
		print("Script attached to: ", child.name)


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)
