extends Zombie
# BufferZombie.gd
@onready var buff_zone := $BuffZone
@onready var buff_timer :Timer = $BuffTimer
@export var time_between_buff := 7

func _ready()->void:
	super()
	if Global.gameIsStarted && self.is_demo == false:
		Global.unlock_zombie("Buffer")
	_setup_zone_masks()
	buff_timer.wait_time = time_between_buff
	buff_timer.start()
	

func get_zombie_name() -> String:
	return " BUFFER "


func silence() -> void:
	super()
	attackComp.silence()

func get_special_description() -> String:
	return buffer_special_description

func get_zombie_icon() -> CompressedTexture2D:
	return Global.buffer_icon


func _on_buff_timer_timeout() -> void:
	animatedSprite.animation = "buff"
	speedComp.freeze()
	animatedSprite.play()

func _setup_zone_masks() -> void:
	# Masks are assigned in code per dimension (README convention): DashZone/PierceZone
	# detect enemy demons (Purple=2 / Green=3); BuffZone detects allied zombies (Purple=4 / Green=5).
	var demon_bit := 3 if is_in_group("Green") else 2
	var zombie_bit := 5 if is_in_group("Green") else 4
	_set_single_mask(buff_zone, zombie_bit)
	
	

func _set_single_mask(node, bit: int) -> void:
	for i in range(1, 6):
		node.set_collision_mask_value(i, false)
	node.set_collision_mask_value(bit, true)


func _on_animated_sprite_2d_animation_finished() -> void:
	if animatedSprite.animation == "buff":
		for area in buff_zone.get_overlapping_areas():
			if area != self and area.is_in_group("Zombie") and area.has_method("_buff_zombie"):
				area._buff_zombie()
		buff_timer.start()
		speedComp.setSpeed(speedComp.getOriginalSpeed())
		animatedSprite.animation = "Walk"
		animatedSprite.play()
