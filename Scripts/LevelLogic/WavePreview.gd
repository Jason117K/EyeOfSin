extends Node2D
#Wave Preview.gd


var spawner

var currentBaseZombies
var currentConeZombies
var currentBucketZombies

onready var visibility = true

# Called when the node enters the scene tree for the first time.
func _ready():
	spawner = get_parent()
	

func _on_Area2D_mouse_entered():
	if $PreviewSprite.visible == true:
		var currentText1 = "Base Zombies : " + str(spawner.r1_BaseZombies)
		var currentText2 = "Cone Zombies : " + str(spawner.r1_ConeheadZombies)
		var currentText3 = "Bucket Zombies : " + str(spawner.r1_BucketheadZombies)
		
		$Node2D/Control.visible = true
		$Node2D/Control/Label.text = currentText1
		$Node2D/Control/Label2.text = currentText2
		$Node2D/Control/Label3.text = currentText3


func _on_Area2D_mouse_exited():
	$Node2D/Control.visible = false
	$Node2D/Control/Label.text = ""
	$Node2D/Control/Label2.text = ""
	$Node2D/Control/Label3.text = ""


func _on_ToggleVisibility_timeout():
	swap_Visibility()
	
func swap_Visibility():
	$PreviewSprite.visible = !visibility
	visibility = !visibility
