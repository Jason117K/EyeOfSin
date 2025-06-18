extends AnimatedTextureRect

#Button References
@onready var sunflowerButton = $"../AllPlantRows/Row1/Sunflower"
@onready var peashooterButton = $"../AllPlantRows/Row1/Peashooter"
@onready var walnutButton = $"../AllPlantRows/Row1/Walnut"
@onready var eyeBombButton = $"../AllPlantRows/Row2/EyeBomb"
@onready var eggWyrmButton = $"../AllPlantRows/Row2/EggWrym" 
@onready var hiveButton = $"../AllPlantRows/Row2/Hive" 
@onready var mawButton = $"../AllPlantRows/Row3/Maw"

@onready var currentPlantLabel = $"../../../CurrentPlantLabel"

#Plant Text Descriptions
var sunflowerDescription := "res://Assets/Text/TextFiles/PlantDescriptions/SunflowerDescription.txt"
var peashooterDescription := "res://Assets/Text/TextFiles/PlantDescriptions/PeashooterDescription.txt"
var walnutDescription := "res://Assets/Text/TextFiles/PlantDescriptions/WalnutDescription.txt"
var eyeBombDescription := "res://Assets/Text/TextFiles/PlantDescriptions/EyeBombDescription.txt"
var eggWyrmDescription := "res://Assets/Text/TextFiles/PlantDescriptions/EggWyrmDescription.txt"
var hiveDescription := "res://Assets/Text/TextFiles/PlantDescriptions/HiveDescription.txt"
var mawDescription := "res://Assets/Text/TextFiles/PlantDescriptions/MawDescription.txt"

func _ready() -> void:
	print("Plant AnimatedTextureRect: _ready() called")
	
		# Set default button textures based on current colors
	_update_button_textures()
	
	# Set initial sprites if none are set
	if sprites == null:
		var plant_type = GlobalResourceLoader.PlantType.SUNFLOWER
		sprites = GlobalResourceLoader.get_plant_animation(plant_type)
	
	# Initialize animation data
	if sprites != null:
		if not sprites.has_animation(current_animation):
			var animations = sprites.get_animation_names()
			if animations.size() > 0:
				current_animation = animations[0]
		
		fps = sprites.get_animation_speed(current_animation)
		refresh_rate = sprites.get_frame_duration(current_animation, frame_index)
		if auto_play:
			play()

# Update all button textures based on current color settings
func _update_button_textures():
	
	# Set Melee Alien buttons
	if sunflowerButton != null:
		sunflowerButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.SUNFLOWER)
	if peashooterButton != null:
		peashooterButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.PEASHOOTER)
	if walnutButton != null:
		walnutButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.WALNUT)
	
	# Set Ranged Alien buttons
	if eyeBombButton != null:
		eyeBombButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.BOMBPLANT)
	if eggWyrmButton != null:
		eggWyrmButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.EGGWYRM)
	if hiveButton != null:
		hiveButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.HIVE)
			
	if mawButton != null:
		mawButton.texture_normal = GlobalResourceLoader.get_plant_image(
			GlobalResourceLoader.PlantType.MAW)
			
			
			
			
			
#Sets the current Plant Description Text
func set_text(newFile : String):
	var file = FileAccess.open(newFile, FileAccess.READ)
	var newText = file.get_as_text()
	file.close()
	currentPlantLabel.text = newText

func _on_sunflower_pressed() -> void:
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.SUNFLOWER)
	play()
	set_text(sunflowerDescription)



func _on_peashooter_pressed() -> void:
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.PEASHOOTER)
	play()
	set_text(peashooterDescription)


func _on_walnut_pressed() -> void:
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.WALNUT)
	play()
	set_text(walnutDescription)


func _on_eye_bomb_pressed() -> void:
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.BOMBPLANT)
	play()
	set_text(eyeBombDescription)


func _on_egg_wrym_pressed() -> void:
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.EGGWYRM)
	play()
	set_text(eggWyrmDescription)


func _on_hive_pressed() -> void:
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.HIVE)
	play()
	set_text(hiveDescription)


func _on_maw_pressed() -> void:
	sprites = GlobalResourceLoader.get_plant_animation(
		GlobalResourceLoader.PlantType.MAW)
	play()
	set_text(mawDescription)
	
