extends AnimatedSprite2D
#ZombieSpriteComp


@export_range(-180, 180) var hue_shift: float = -86.0: #25.0
	set(value):
		hue_shift = clamp(value, -180.0, 180.0)
		_apply_hue_shift()

var demon_hue_shift = preload("res://Scripts/Plants/Shaders/DemonHueShift.gdshader")
var thisMaterial

@export var targetColorString := "ff0013"
@export var targetColor : Color 
@export var targetGlowColor : Color
@export var replaceColor : Color = Color.BLACK

var is_attacking
var isSlow
var isInjured
@onready var zombie = 	get_parent()
@onready var attackComp = $"../AttackComponent"
@onready var attack_audio_player = $"../AttackAudioPlayer"
@onready var healthComp  =  $"../HealthComponent"

var specialMove = false 
#Allow Summons While Webbed?
#Maybe Give Zombies With Special Animations Own Sprite Comp Controller



func _ready() -> void:
	_apply_hue_shift()
	# Ensure updates on animation changes
	animation_changed.connect(_apply_hue_shift)
	frame_changed.connect(_apply_hue_shift)
	
	self.connect("animation_changed",_on_animation_changed)
	thisMaterial = material.duplicate()
	material = thisMaterial
	# Set initial shader parameters
	if thisMaterial:
		print("Made h")
		thisMaterial.set_shader_parameter("target_color", targetColor)
		thisMaterial.set_shader_parameter("replace_color",replaceColor)
		thisMaterial.set_shader_parameter("tolerance", 0.1)
		pass	
	
	
func setSpecialMoveTrue():
	specialMove = true
	
func setSpecialMoveFalse():
	specialMove = false
	
#Handles Animation 
func _process(_delta):
	if attackComp != null:
		# Predetermine the state of attacking, being injured, and being slowed 
		is_attacking = attackComp.getAttackState()
		isInjured = healthComp.getInjured()
		isSlow = zombie.getCompManager().getSlow()
		
		#Handle each combination of the above cases in the below block 
		if not specialMove:
			#Slow Webbed Block
			#--------------------------------------------------------------------------
			if isSlow > 0:
				#Dancer Specific 
				if(zombie.name == "DancerZombie"):
					if(self.animation == "Summon"):
						pass
					else:
						if(not is_attacking):
							self.play("WebWalk")     

				if isInjured: #Injured and Webbed 
					if not is_attacking:
						if sprite_frames.has_animation("InjuredWebWalk"):
							self.play("InjuredWebWalk")    #InjuredWebWalk
						else : 
							self.play("WebWalk") #InjuredWebWalk
					else:
						if sprite_frames.has_animation("InjuredWebAttack"):
							self.play("InjuredWebAttack")    #InjuredWebAttack
						else : 
							self.play("WebAttack") 
							
				else: #Not Injured, Are Webbed
					if not is_attacking:
						if sprite_frames.has_animation("WebWalk"):
							self.play("WebWalk")    #WebWalk
							#print("Playing WebWalk Right nw")
						else : 
							self.play("Walk") #WebWalk
					else:
						if sprite_frames.has_animation("WebAttack"):
							self.play("WebAttack")    #WebAttack
						else : 
							self.play("Attack") #WebAttack
			#--------------------------------------------------------------------------
				
			#Not Slow Block
			else: #isSlow <= 0
				#print("NOT SLOW")

				#Dancer Specific 
				if(zombie.name == "DancerZombie"):
					if(self.animation == "Summon"):
						pass
					else:
						if(not is_attacking):
							self.play("Walk")

				if isInjured: #Injured and NOT Webbed 
					if not is_attacking:
						self.play("Walk") #InjuredWalk
					else:
						self.play("Attack") #InjuredAttack
				else: #Not Injured, NOT Webbed
					if not is_attacking:
						#print("Walk Nw")
						self.play("Walk")
					else:
						self.play("Attack")
						
		else:
			pass

#Makes it so Pole Vaulters can only special move once 
func _on_AnimatedSprite_animation_finished():
	if("Vault" in self.animation):
		specialMove = false

#Handles Ticker Zombie Explosion Animation 
func _on_AnimatedSprite_frame_changed():
	if("Ticker" in zombie.name):
		if self.animation == "Attack" || self.animation == "WebAttack":
			if self.frame == 3:
				var AOEHit = $"../AOEHit"
				AOEHit.goBoom()
	else:
		pass

func _apply_hue_shift() -> void:
	# Create material if needed
	if material == null:
		material = ShaderMaterial.new()
		material.shader = demon_hue_shift #preload("res://Scripts/Plants/Shaders/DemonHueShift.gdshader")
	
	# Update shader parameter
	if material is ShaderMaterial:
		material.shader = demon_hue_shift
		material.set_shader_parameter("glow_color", targetGlowColor)
		material.set_shader_parameter("hue_shift_degrees", hue_shift)
		
		
		
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



	
