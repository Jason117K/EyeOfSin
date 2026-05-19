class_name ZombieSpriteComp extends AnimatedSprite2D
#ZombieSpriteComp

var count = 1

@export_range(-180, 180) var hue_shift: float = -86.0: #25.0
	set(value):
		hue_shift = clamp(value, -180.0, 180.0)
		#print(hue_shift,"Apply HUE Shift ", count)
		_apply_hue_shift()

var demon_hue_shift = preload("res://_Common/Shaders/DemonHueShift.gdshader")
var thisMaterial
var original_hue_shift := -86

@export var targetColorString := "ff0013"
@export var targetColor : Color 
@export var targetGlowColor : Color
@export var replaceColor : Color = Color.BLACK

var is_attacking
var isSlow
var isInjured
@onready var zombie = 	get_parent()
@onready var attackComp = $"../AttackComponent"
#@onready var attack_audio_player = $"../AttackAudioPlayer"
@onready var healthComp  =  $"../HealthComponent"

var isDead = false
var specialMove = false
var set_hue := false
var _current_target_anim: StringName = &""

#Allow Summons While Webbed?
#Maybe Give Zombies With Special Animations Own Sprite Comp Controller



func _ready() -> void:
	
	self.connect("animation_changed",_on_animation_changed)
	thisMaterial = material.duplicate()
	material = thisMaterial
	# Set initial shader parameters
	if thisMaterial:
		#print("Made h")
		thisMaterial.set_shader_parameter("target_color", targetColor)
		thisMaterial.set_shader_parameter("replace_color",replaceColor)
		thisMaterial.set_shader_parameter("tolerance", 0.1)
		pass
	set_process(false)
	
	
func setSpecialMoveTrue():
	specialMove = true
	_current_target_anim = &""

func setSpecialMoveFalse():
	specialMove = false
	_current_target_anim = &""
	
func _play_if_changed(anim_name: StringName) -> void:
	if anim_name != _current_target_anim:
		_current_target_anim = anim_name
		play(anim_name)

func tick(_delta):
	if attackComp == null or isDead:
		return
	is_attacking = attackComp.is_attacking
	isInjured = healthComp.injured
	isSlow = zombie.isSlow

	if specialMove:
		return

	if isSlow > 0:
		if zombie.name == "DancerZombie":
			if self.animation == "Summon":
				pass
			else:
				if not is_attacking:
					_play_if_changed(&"WebWalk")

		if isInjured:
			if not is_attacking:
				if sprite_frames.has_animation("InjuredWebWalk"):
					_play_if_changed(&"InjuredWebWalk")
				else:
					_play_if_changed(&"WebWalk")
			else:
				if sprite_frames.has_animation("InjuredWebAttack"):
					_play_if_changed(&"InjuredWebAttack")
				else:
					_play_if_changed(&"WebAttack")
		else:
			if not is_attacking:
				if sprite_frames.has_animation("WebWalk"):
					_play_if_changed(&"WebWalk")
				else:
					_play_if_changed(&"Walk")
			else:
				if sprite_frames.has_animation("WebAttack"):
					_play_if_changed(&"WebAttack")
				else:
					_play_if_changed(&"Attack")
	else:
		if zombie.name == "DancerZombie":
			if self.animation == "Summon":
				pass
			else:
				if not is_attacking:
					_play_if_changed(&"Walk")

		if isInjured:
			if not is_attacking:
				_play_if_changed(&"Walk")
			else:
				_play_if_changed(&"Attack")
		else:
			if not is_attacking:
				_play_if_changed(&"Walk")
			else:
				_play_if_changed(&"Attack")

#Makes it so Pole Vaulters can only special move once 
func _on_AnimatedSprite_animation_finished():
	if("Vault" in self.animation):
		specialMove = false
	if("death" in self.animation):
		zombie.die()


func _apply_hue_shift() -> void:
	#print("Apply Hue Shift ", count)
	
	# Create material if needed
	if material == null:
		material = ShaderMaterial.new()
		material.shader = demon_hue_shift #preload("res://Scripts/Demons/Shaders/DemonHueShift.gdshader")
	
	# Update shader parameter
	if material is ShaderMaterial:
		material.shader = demon_hue_shift
		material.set_shader_parameter("glow_color", targetGlowColor)
		material.set_shader_parameter("hue_shift_degrees", hue_shift)
		if set_hue == false && hue_shift != 0:
			original_hue_shift = hue_shift
			set_hue = true 
			#print(original_hue_shift, "Apply Hue Shift First ", count)
	count += 1 
		
		
		
# Public API methods
func set_hue_shift(degrees: float) -> void:
	hue_shift = clamp(degrees, -180.0, 180.0)
	_apply_hue_shift()
	
func shift_hue(degrees: float) -> void:
	hue_shift = fmod(hue_shift + degrees, 360.0)
	if hue_shift > 180: hue_shift -= 360
	if hue_shift < -180: hue_shift += 360



func _on_animation_changed() -> void:
	if thisMaterial:
		#print("Made PPInk")
		thisMaterial.set_shader_parameter("target_color", Color(targetColorString))
		thisMaterial.set_shader_parameter("replace_color", Color.DEEP_PINK)
		thisMaterial.set_shader_parameter("tolerance", 0.3)



	
