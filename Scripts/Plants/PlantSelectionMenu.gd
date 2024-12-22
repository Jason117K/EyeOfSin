extends Control

var selected_plant = sunflower_scene  # Holds the currently selected plant scene

# Preload the plant scenes
var peashooter_scene = preload("res://Scenes/PlantScenes/Peashooter.tscn")
var sunflower_scene = preload("res://Scenes/PlantScenes/Sunflower.tscn")
var walnut_scene = preload("res://Scenes/PlantScenes/WalnutTree.tscn")
var maw_scene = preload("res://Scenes/PlantScenes/Maw.tscn")
var egg_scene = preload("res://Scenes/PlantScenes/EggWorm.tscn")
var bomb_scene = preload("res://Scenes/PlantScenes/EyeBomb.tscn")



func _ready():
	# Connect button signals to their respective functions
	var root = get_parent().get_parent().get_name()
	
	if root == "Main": #or root == "Level2":
		assert($HBoxContainer/PeashooterButton2.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert($HBoxContainer/SunflowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		$HBoxContainer/WalnutButton.visible = true
		$HBoxContainer/MawButton.visible = false
		$HBoxContainer/EggButton.visible = false
		$HBoxContainer/EyeButton.visible = false
		
	elif root == "Level2":
		assert($HBoxContainer/PeashooterButton2.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert($HBoxContainer/SunflowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		#assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		$HBoxContainer/MawButton.visible = false
	else: #root = Level3
		assert($HBoxContainer/PeashooterButton2.connect("pressed", self, "_on_PeashooterButton_pressed")== OK)
		assert($HBoxContainer/SunflowerButton.connect("pressed", self, "_on_SunflowerButton_pressed")== OK)
		#assert($HBoxContainer/WalnutButton.connect("pressed", self, "_on_WalnutButton_pressed")== OK)
		$HBoxContainer/MawButton.visible = true

	#print(root)
	I want to enhance this script. Make it so that, when a button is clicked, a preview of the sprite will
	now follow around the players cursor. When the player clicks to place 
	
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



func _on_EggButton_pressed():
	selected_plant = egg_scene
	print("EggWorm Selected")
	$UIClickAudio.play()



func _on_EyeButton_pressed():
	selected_plant = bomb_scene
	print("EyeBomb Selected")
	$UIClickAudio.play()

