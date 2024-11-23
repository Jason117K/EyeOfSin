extends Control

var selected_plant = sunflower_scene  # Holds the currently selected plant scene

# Preload the plant scenes
var peashooter_scene = preload("res://Scenes/PlantScenes/Peashooter.tscn")
var sunflower_scene = preload("res://Scenes/PlantScenes/Sunflower.tscn")
var walnut_scene = preload("res://Scenes/PlantScenes/WalnutTree.tscn")
var maw_scene = preload("res://Scenes/PlantScenes/Maw.tscn")



func _ready():
	# Connect button signals to their respective functions
	var root = get_parent().get_parent().get_name()
	
	if root == "Main": #or root == "Level2":
		assert($HBoxContainer/PeashooterButton2.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert($HBoxContainer/SunflowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		$HBoxContainer/WalnutButton.visible = false
		$HBoxContainer/MawButton.visible = false
	elif root == "Level2":
		assert($HBoxContainer/PeashooterButton2.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert($HBoxContainer/SunflowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		$HBoxContainer/MawButton.visible = false
	else: #root = Level3
		assert($HBoxContainer/PeashooterButton2.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert($HBoxContainer/SunflowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		$HBoxContainer/MawButton.visible = false

	#print(root)
	
	
func _on_PeashooterButton_pressed():
	selected_plant = peashooter_scene
	("Peashooter selected")
	$UIClickAudio.play()
	
func _on_SunflowerButton_pressed():
	selected_plant = sunflower_scene
	print("Sunflower selected")
	$UIClickAudio.play()
	
func _on_WalnutButton_pressed():
	selected_plant = walnut_scene
	print("Walnut selected")
	$UIClickAudio.play()


func _on_MawButton_pressed():
	selected_plant = maw_scene
	print("Maw Selected")
	$UIClickAudio.play()
	pass # Replace with function body.
