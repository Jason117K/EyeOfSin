extends Node2D
#Wave Preview.gd


var spawner

var currentBaseZombies
var currentConeZombies
var currentBucketZombies
@onready var previewText = $Node2D/Control/EnemyPreviewText
@onready var visibility = true
var numWave 
var currentZombieDict :Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	spawner = get_parent()
	

func _on_Area2D_mouse_entered():
	
	numWave = spawner.get_numWave() + 1
	if numWave == 0:
		numWave = 1
	print("SSNumwave is ", numWave)
	match numWave:
		1:

			currentZombieDict = spawner.Round1_Zombies
		2:
			currentZombieDict = spawner.Round2_Zombies
		3:
			currentZombieDict = spawner.Round3_Zombies
			
			
	if $PreviewSprite.visible == true:
		print("SS: ", currentZombieDict)
		for key in currentZombieDict:
			#var line = "[b]" + str(key) + "[/b]: " + str(spawner.Round1_Zombies[key]) + "\n"
			if currentZombieDict[key] == 0:
				pass
			else:
				var line =  str(key) + " : "+ str(currentZombieDict[key]) + "\n"
				previewText.append_text(line)
				print("SSLine is ", line)

		$Node2D/Control.visible = true



func _on_Area2D_mouse_exited():
	$Node2D/Control.visible = false
	previewText.clear()


#TODO Fix Vis
func _on_ToggleVisibility_timeout():
	print("Swap Vis")
	swap_Visibility()
	
func swap_Visibility():
	$PreviewSprite.visible = !visibility
	visibility = !visibility
