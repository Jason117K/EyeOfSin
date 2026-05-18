extends Zombie
#ScreenDoorZombie.gd

# Handles ScreenDoor Zombie specific behavior 

@onready var healthCom = compManager.getHealthComponent()
@onready var anim_sprite_comp : AnimatedSprite2D = $AnimatedSprite2D
@onready var extra_blood_hit := $BloodHit2

# Stores death count for transformation purposes 
var deathCount = 0 

func silence():
	super()
	deathCount = 2
	silence_field.position = silence_field_position
	compManager.append_blood_hit(extra_blood_hit)

	
# First transforms zombie 'death' 1, then kills zombie 'death' 2
func die():
	if deathCount > 1:
		super()
	else:
		deathCount = deathCount+1
		transform()


# Switches visible sprite to transform zombie 
func transform():
	anim_sprite_comp.sprite_frames = Global.get_severed_spriteframes() 
	anim_sprite_comp.flip_h = true
	anim_sprite_comp._ready()
	anim_sprite_comp.play()
	#compManager.setMaterial(altSprite)
	compManager.erase_blood_hit(extra_blood_hit)
	healthCom.resetHealth()

func check_for_maw(damage):
	if damage > 9000:
		deathCount = 2
	
	
func get_zombie_name():
	return " AMALGAM "
	
	
	
	
