extends AnimatedTextureRect

#Button References
@onready var baseZombieButton := $"../../HBoxContainer/AllZombieRows/Row1/BaseZombie"
@onready var coneHeadZombieButton := $"../../HBoxContainer/AllZombieRows/Row1/ConeHeadZombie"
@onready var bucketHeadZombieButton := $"../../HBoxContainer/AllZombieRows/Row1/BucketHeadZombie"
@onready var dancerZombieButton := $"../../HBoxContainer/AllZombieRows/Row2/DancerZombie"
@onready var backUpDanceerZombieButton := $"../../HBoxContainer/AllZombieRows/Row2/BackUpDancerZombie"
@onready var tickerZombieButton := $"../../HBoxContainer/AllZombieRows/Row2/TickerZombie"
@onready var screenDoorZombieButton := $"../../HBoxContainer2/MarginContainer/AllZombieRows/Row3/AmalgamButton"
@onready var footBallZombieButton := $"../../AllZombieRows/Row3/FootballZombie"
@onready var poleVaultZombieButton := $"../../AllZombieRows/Row3/PoleVaultZombie"

@onready var currentZombieLabel := $"../../CurrentZombieLabel"
@onready var currentZombieTitle := $"../../CurrentZombieTitle"

@onready var tempFleshEaterAnimSprite := $"../../TEMPFlesheater"

@onready var current_zombie_animation := $"../../CurrentZombieAnim"

var baseZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/BaseZombieDescription.txt"
var coneheadZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/ConeHeadZombieDescription.txt"
var bucketHeadZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/bucketHeadZombieDescription.txt"
var dancerZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/dancerZombieDescription.txt"
var backUpDancerZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/backUpDancerDescription.txt"
var tickerZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/tickerZombieDescription.txt"
var screennDoorZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/ScreenDoorZombieDescription.txt"
var footBallZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/footBallZombieDescription.txt"
var poleVaultZombieDescription := "res://_Assets/Text/TextFiles/ZombieDescriptions/poleVaultZombieDescription.txt"

var baseZombieTitle := "Reborn"
var coneHeadZombieTitle := "Severed"
var bucketHeadZombieTitle := "Unhallower"
var dancerZombieTitle := "Reanimator"
var backUpDancerZombieTitle := "Wretch"
var tickerZombieTitle := "Erupter"
var screenDoorZombieTitle := "Amalgams"
var footballZombieTitle := "Flesheater"
var poleVaultZombieTitle := "Sundered"

var current_zobmie_texture : Texture2D

@onready var zombieBookVisual := $"../../InteractiveBook2D"
var current_page := 2

func _ready() -> void:
	#print("Zombie AnimatedTextureRect: _ready() called")
	zombieBookVisual.go_to_page(current_page)
	current_page = current_page + 1
	
		# Set default button textures based on current colors
	_update_button_textures()
	
	# Set initial sprites if none are set
	#if sprites == null:
	var zombie_type := GlobalResourceLoader.ZombieType.CONEHEAD
	sprites = GlobalResourceLoader.get_zombie_animation(zombie_type)
	
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
	set_text(coneheadZombieDescription)
	set_title(coneHeadZombieTitle)
	_on_cone_head_zombie_pressed()
# Update all button textures based on current color settings
func _update_button_textures() -> void:
	
	# Set
	if baseZombieButton != null:
		baseZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.BASEZOMBIE)
	if coneHeadZombieButton != null:
		coneHeadZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.CONEHEAD)
	if bucketHeadZombieButton != null:
		bucketHeadZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.BUCKETHEAD)
	
	# Set 
	if dancerZombieButton != null:
		dancerZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.DANCERZOMBIE)
	if backUpDanceerZombieButton != null:
		backUpDanceerZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.BACKUPDANCERZOMBIE)
	if tickerZombieButton != null:
		tickerZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.TICKER)
			
	#if screenDoorZombieButton != null:
		#screenDoorZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			#GlobalResourceLoader.ZombieType.SCREENDOORZOMBIE)
			#
	if footBallZombieButton != null:
		footBallZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.FOOTBALLZOMBIE)
			
	if poleVaultZombieButton != null:
		poleVaultZombieButton.texture_normal = GlobalResourceLoader.get_zombie_image(
			GlobalResourceLoader.ZombieType.POLEVAULTZOMBIE)
	_apply_hue_shift()
			
#Sets the current Zombie Description Text
func set_text(newFile: String) -> void:
	var file := FileAccess.open(newFile, FileAccess.READ)
	var newText := file.get_as_text()
	file.close()
	currentZombieLabel.text = newText

func set_title(newTitle: String) -> void:
	currentZombieTitle.text = newTitle

func _on_base_zombie_pressed() -> void:
	current_zombie_animation.show()
	#current_zombie_animation.hide()
	tempFleshEaterAnimSprite.visible = false
	get_parent().visible = false
	#get_parent().position = Vector2(431,-25)
	get_parent().show()
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BASEZOMBIE)
	current_zombie_animation.flip_h = true 
	play()


	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BASEZOMBIE)
	current_zombie_animation.play()
	
	
	set_text(baseZombieDescription)
	set_title(baseZombieTitle)
	self.flip_h = true


func _on_cone_head_zombie_pressed() -> void:
	current_zombie_animation.show()
	
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	#
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.CONEHEAD)
	print("Sprites was ",sprites )
	sprites = load("res://_Entities/Zombies/_Severed/Severed.tres")
	play("Attack")
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.CONEHEAD)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	set_text(coneheadZombieDescription)
	set_title(coneHeadZombieTitle)
	self.flip_h = true

func _on_bucket_head_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BUCKETHEAD)
	play()
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BUCKETHEAD)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	set_text(bucketHeadZombieDescription)
	set_title(bucketHeadZombieTitle)
	_apply_hue_shift()
	self.flip_h = true

#was 431.0
func _on_dancer_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(475,-25)
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.DANCERZOMBIE)
	play()

	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.DANCERZOMBIE)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	
	set_text(dancerZombieDescription)
	set_title(dancerZombieTitle)
	self.flip_h = true

func _on_back_up_dancer_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BACKUPDANCERZOMBIE)
	play()

	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.BACKUPDANCERZOMBIE)
	current_zombie_animation.play()
	
	current_zombie_animation.flip_h = true 
	
	set_text(backUpDancerZombieDescription)
	set_title(backUpDancerZombieTitle)
	self.flip_h = true


func _on_ticker_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(450,1)

	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.TICKER)
	play()
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.TICKER)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	
	set_text(tickerZombieDescription)
	set_title(tickerZombieTitle)
	self.flip_h = true


func _on_screen_door_zombie_pressed() -> void:
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	sprites = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.SCREENDOORZOMBIE)
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.SCREENDOORZOMBIE)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = false
	#current_zobmie_texture = GlobalResourceLoader.
	play()
	set_text(screennDoorZombieDescription)
	set_title(screenDoorZombieTitle)
	self.flip_h = false


func _on_football_zombie_pressed() -> void:
	current_zombie_animation.show()
	#get_parent().position = Vector2(431,-25)
	#tempFleshEaterAnimSprite.visible = true
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	#sprites = GlobalResourceLoader.get_zombie_animation(
		#GlobalResourceLoader.ZombieType.FOOTBALLZOMBIE)
	sprites = GlobalResourceLoader.get_empty()
	play()
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.FOOTBALLZOMBIE)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = false 
	
	
	set_text(footBallZombieDescription)
	set_title(footballZombieTitle)
	self.flip_h = false


func _on_pole_vault_zombie_pressed() -> void:
	current_zombie_animation.show()
	current_zombie_animation.show()
	tempFleshEaterAnimSprite.visible = false
	#get_parent().position = Vector2(431,-25)
	#
	current_page = current_page + 1
	zombieBookVisual.go_to_page(current_page)
	#sprites = GlobalResourceLoader.get_zombie_animation(
		#GlobalResourceLoader.ZombieType.POLEVAULTZOMBIE)
	sprites = GlobalResourceLoader.get_empty()
	play()
	
	current_zombie_animation.sprite_frames = GlobalResourceLoader.get_zombie_animation(
		GlobalResourceLoader.ZombieType.POLEVAULTZOMBIE)
	current_zombie_animation.play()
	current_zombie_animation.flip_h = true 
	
	
	set_text(poleVaultZombieDescription)
	set_title(poleVaultZombieTitle)
	self.flip_h = true


func _on_back_button_pressed() -> void:
	tempFleshEaterAnimSprite.visible = false
	current_page = current_page - 1
	zombieBookVisual.go_to_page(current_page)
	get_parent().get_parent().visible = false
	print("BBack Button Pressed")
	Global.game_controller.restore_previous_scene()
