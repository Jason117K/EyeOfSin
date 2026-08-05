class_name ZombieSpriteComp extends AnimatedSprite2D
#ZombieSpriteComp

var count := 1

@export_range(-180, 180) var hue_shift: float = -86.0: #25.0
	set(value):
		hue_shift = clamp(value, -180.0, 180.0)
		##print(hue_shift,"Apply HUE Shift ", count)
		_apply_hue_shift()

var demon_hue_shift := preload("res://_Common/Shaders/DemonHueShift.gdshader")
var original_hue_shift : float = -86
var _original_material: ShaderMaterial = null
static var _material_cache: Dictionary = {}

@export var targetColorString := "ff0013"
@export var targetColor: Color
@export var targetGlowColor: Color
@export var replaceColor: Color = Color.BLACK

var is_attacking : bool 
var slow_amount : float 
var isInjured : bool 
@onready var zombie := get_parent()
@onready var attackComp :ZombieAttackRefCountedComponent #= zombie.get_attack_comp()  #$"../AttackComponent"
#@onready var attack_audio_player = $"../AttackAudioPlayer"
#@onready var healthComp := $"../HealthComponent"

var isDead := false
var specialMove := false
var set_hue := false
var _current_target_anim: StringName = &""
var _sprite_frame_counter: int = 0
var _is_dancer: bool = false
var _has_web_walk: bool = false
var _has_web_attack: bool = false
var _has_injured_web_walk: bool = false
var _has_injured_web_attack: bool = false
var is_slow := false 
var previous_hue_shift : int 

#Allow Summons While Webbed?
#Maybe Give Zombies With Special Animations Own Sprite Comp Controller



func _ready() -> void:
	set_process(false)
	_sprite_frame_counter = randi() % 5
	_is_dancer = zombie.name == "DancerZombie"
	_has_web_walk = sprite_frames.has_animation("WebWalk")
	_has_web_attack = sprite_frames.has_animation("WebAttack")
	_has_injured_web_walk = sprite_frames.has_animation("InjuredWebWalk")
	_has_injured_web_attack = sprite_frames.has_animation("InjuredWebAttack")
	
	
func setSpecialMoveTrue() -> void:
	specialMove = true
	_current_target_anim = &""

func setSpecialMoveFalse() -> void:
	specialMove = false
	_current_target_anim = &""
	
func _play_if_changed(anim_name: StringName) -> void:
	if anim_name != _current_target_anim:
		_current_target_anim = anim_name
		play(anim_name)

func slow()->void:
	is_slow = true 
	
func tick(_delta: float) -> void:
	if attackComp == null or isDead:
		return
	_sprite_frame_counter += 1
	if _sprite_frame_counter % 5 != 0:
		return
	is_attacking = attackComp.is_attacking
	isInjured = zombie.get_is_injured()
	#slow_amount = zombie.slow_amount

	if specialMove:
		return

	if is_slow :
		if _is_dancer:
			if self.animation == "Summon":
				return
			elif not is_attacking:
				_play_if_changed(&"WebWalk")
				return

		if isInjured:
			if not is_attacking:
				if _has_injured_web_walk:
					_play_if_changed(&"InjuredWebWalk")
				else:
					_play_if_changed(&"WebWalk")
			else:
				if _has_injured_web_attack:
					_play_if_changed(&"InjuredWebAttack")
				else:
					_play_if_changed(&"WebAttack")
		else:
			if not is_attacking:
				if _has_web_walk:
					_play_if_changed(&"WebWalk")
				else:
					_play_if_changed(&"Walk")
			else:
				if _has_web_attack:
					_play_if_changed(&"WebAttack")
				else:
					_play_if_changed(&"Attack")
	else:
		if _is_dancer:
			if self.animation == "Summon":
				return
			elif not is_attacking:
				_play_if_changed(&"Walk")
				return

		if not is_attacking:
			_play_if_changed(&"Walk")
		else:
			_play_if_changed(&"Attack")

#Makes it so Pole Vaulters can only special move once
func _on_AnimatedSprite_animation_finished() -> void:
	if("Vault" in self.animation):
		specialMove = false
	if("death" in self.animation):
		zombie.die()


func _apply_hue_shift() -> void:
	if _original_material == null:
		_original_material = material as ShaderMaterial
		if _original_material == null:
			_original_material = ShaderMaterial.new()
			_original_material.shader = demon_hue_shift

	var key := "%d_%.0f" % [_original_material.get_instance_id(), hue_shift]
	if _material_cache.has(key):
		material = _material_cache[key]
	else:
		var mat := _original_material.duplicate() as ShaderMaterial
		mat.shader = demon_hue_shift
		mat.set_shader_parameter("hue_shift_degrees", hue_shift)
		mat.set_shader_parameter("glow_color", targetGlowColor)
		_material_cache[key] = mat
		material = mat

	if set_hue == false && hue_shift != 0:
		original_hue_shift = hue_shift
		set_hue = true
	count += 1
		
		
		
# Public API methods
func set_hue_shift(degrees: float) -> void:
	if degrees == 1:
		await get_tree().physics_frame
		if self.is_in_group("Green"):
			degrees = 125
		else:
			degrees = -86
	
	hue_shift = clamp(degrees, -180.0, 180.0)
	_apply_hue_shift()
	
func shift_hue(degrees: float) -> void:
	hue_shift = fmod(hue_shift + degrees, 360.0)
	if hue_shift > 180: hue_shift -= 360
	if hue_shift < -180: hue_shift += 360

func lucretia_hue_shift()->void:
	#previous_hue_shift = hue_shift
	set_hue_shift(0)

func undo_lucretia_hue_shift()->void:
	set_hue_shift(original_hue_shift)

func blood_slow()->void:
	slow()
	lucretia_hue_shift()
	material.set_shader_parameter("target_color", Color("ffffff"))
	material.set_shader_parameter("replace_color", Color.RED)
	material.set_shader_parameter("tolerance", 0.1)

func undo_blood_slow()->void:
	undo_lucretia_hue_shift()
	material.set_shader_parameter("target_color", Color("000000"))
	material.set_shader_parameter("replace_color", Color("000000"))
	material.set_shader_parameter("tolerance", 0.0)


	
