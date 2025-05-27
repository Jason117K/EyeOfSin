class_name AnimatedTextureRect extends TextureRect
#Tower Lore Scene Button

@export var sprites : SpriteFrames
@export var current_animation = "gif"
@export var frame_index := 0
@export_range(0.0, INF, 0.001) var speed_scale := 1.0 
@export var auto_play := false
@export var playing := false

@onready var textBox = $"../Text"
#@onready var damageTextBox =  $"../Damage"
#@onready var rangeTextBox =  $"../Range"
#@onready var speedTextBox =  $"../Speed"
#@onready var uniqueTextBox =  $"../Unique Properties"

var text : String
var damageText : String
var rangeText : String
var speedText : String 
var uniquePropertyText : String

var refresh_rate = 1.0
var fps = 30.0
var frame_delta = 0


func _ready() -> void:
	print("AnimatedTextureRect: _ready() called")
	get_tree().paused = false
	
	# Set initial sprites if none are set
	if sprites == null:
		pass
	
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

# Handle scene switching with _notification
func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		print("AnimatedTextureRect: Visibility changed, visible =", visible)
		if visible:
			call_deferred("_restart_animation")
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		print("AnimatedTextureRect: Window focus gained")
		call_deferred("_restart_animation")

# Restart animation (called after scene changes)
func _restart_animation():
	print("AnimatedTextureRect: Restarting animation")
	
	
	# Restart animation
	if sprites != null:
		play()

func _process(delta: float) -> void:
	if sprites == null or playing == false:
		return 
		
	if sprites.has_animation(current_animation) == false:
		playing = false
		print("AnimatedTextureRect: Animation doesn't exist:", current_animation)
		print("Available animations:", sprites.get_animation_names())
		return
		
	get_animation_data(current_animation)
	frame_delta += (speed_scale * delta)
	if frame_delta >= refresh_rate/fps:
		texture = get_next_frame()
		frame_delta = 0.0

func play(animation_name :String = current_animation):
	frame_index = 0
	frame_delta = 0.0
	current_animation = animation_name
	get_animation_data(current_animation)
	playing = true
	
func get_animation_data(animation):
#	print("Animation is ", animation)
#	print("Current Animation  is ", current_animation)
#	print("sprites is", sprites)
	fps = sprites.get_animation_speed(current_animation)
	refresh_rate = sprites.get_frame_duration(current_animation, frame_index)
	
func get_next_frame():
	frame_index += 1
	var frame_count = sprites.get_frame_count(current_animation)
	if frame_index >= frame_count:
		frame_index = 0
		if not sprites.get_animation_loop(current_animation):
			playing = false
	get_animation_data(current_animation)
	return sprites.get_frame_texture(current_animation, frame_index)
	
func resume():
	playing = true
	
func pause():
	playing = false

func stop():
	frame_index = 0
	playing = false
