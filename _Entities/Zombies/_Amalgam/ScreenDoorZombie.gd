extends Zombie
#ScreenDoorZombie.gd

# Handles ScreenDoor Zombie specific behavior

# Health of the second form it transforms into on its first death
@export var second_form_health := 150.0

@onready var anim_sprite_comp: AnimatedSprite2D = $AnimatedSprite2D
@onready var extra_blood_hit := $BloodHit2

# Stores death count for transformation purposes
var deathCount := 0

func _ready() -> void:
	super()
	healthComp = AmalgamHealthRefCounted.new(self)
	Global.unlock_zombie("Amalgam")

func silence() -> void:
	super()
	deathCount = 2
	silence_field.position = silence_field_position
	append_blood_hit(extra_blood_hit)


# First transforms zombie 'death' 1, then kills zombie 'death' 2
func die() -> void:
	if deathCount > 1:
		super()
	else:
		deathCount = deathCount+1
		transform()

func true_death()->void:
	deathCount = 2
	die()
	
	
	
# Switches visible sprite to transform zombie
func transform() -> void:
	anim_sprite_comp.sprite_frames = Global.get_severed_spriteframes()
	anim_sprite_comp.flip_h = true
	anim_sprite_comp._ready()
	anim_sprite_comp.play()
	attack_ray.target_position = Vector2(-11,0)
	#compManager.setMaterial(altSprite)
	erase_blood_hit(extra_blood_hit)
	healthComp.resetHealth(second_form_health)

func check_for_maw(damage: float) -> void:
	if damage > 9000:
		deathCount = 2


func get_zombie_name() -> String:
	return " AMALGAM "


func get_special_description() -> String:
	return amalgam_special_description


func get_zombie_icon() -> CompressedTexture2D:
	return Global.amalgam_icon
