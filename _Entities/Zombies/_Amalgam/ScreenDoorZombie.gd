extends Zombie
#ScreenDoorZombie.gd

# Handles ScreenDoor Zombie specific behavior

@onready var anim_sprite_comp: AnimatedSprite2D = $AnimatedSprite2D
@onready var extra_blood_hit := $BloodHit2

# Stores death count for transformation purposes
var deathCount := 0

func _ready() -> void:
	super()
	healthComp = AmalgamHealthRefCounted.new(self)

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


# Switches visible sprite to transform zombie
func transform() -> void:
	anim_sprite_comp.sprite_frames = Global.get_severed_spriteframes()
	anim_sprite_comp.flip_h = true
	anim_sprite_comp._ready()
	anim_sprite_comp.play()
	#compManager.setMaterial(altSprite)
	erase_blood_hit(extra_blood_hit)
	healthComp.resetHealth()

func check_for_maw(damage: float) -> void:
	if damage > 9000:
		deathCount = 2


func get_zombie_name() -> String:
	return " AMALGAM "


func get_special_description() -> String:
	return amalgam_special_description


func get_zombie_icon() -> CompressedTexture2D:
	return Global.amalgam_icon
