extends Zombie
# herald_zombie.gd
#
# Argus's Herald (Act 3 boss). Spawned and owned by Argus (argus_boss.gd); one walks
# Green lane 2, the other Purple lane 7. While alive it is a normal walking/attacking
# zombie, and its dimension's Argus is immune to damage.
#
# At 0 HP it does not die: it goes DOWN (plays "death", holds the last frame, can't be
# hit) and tells Argus, which runs the timers and later calls revive() — full health,
# "death" played backwards, then it walks on from where it fell. It only dies for good
# through final_death(), when Argus dies (or if Argus is already gone).
# A Herald that reaches the house loses the level instead.
#
# "death" must be non-looping. The scene must NOT connect the sprite's
# animation_finished to ZombieSpriteComp, whose handler calls die() on "death".

enum State { ALIVE, DOWN, REVIVING, DEAD }

## The Argus that owns this fight; set by Argus before the Herald enters the tree.
var argus: Zombie = null

var _state: State = State.ALIVE


func _ready() -> void:
	super()
	animatedSprite.animation_finished.connect(_on_sprite_animation_finished)


func tick(delta: float) -> void:
	if _state == State.ALIVE:
		super(delta)
		return
	# Down / reviving / dead: only let a hit flash from the last blow wear off.
	if hit_flash_active:
		time_since_hit += delta
		if time_since_hit >= hit_flash_duration:
			hit_flash_active = false
			time_since_hit = 0
			_on_ResetThisColor_timeout()


func die() -> void:
	if _state != State.ALIVE:
		return
	if _in_house():
		Global.lose_game()
		return
	if _argus_alive():
		_go_down()
		argus.call(&"on_herald_down", self)
	else:
		final_death()


# Nothing lands while the Herald is down, getting up, or dead.
func take_damage(is_link_damage : bool = false, damage: float = 1.0, piercing: bool = false) -> void:
	if _state != State.ALIVE:
		return
	super(is_link_damage, damage, piercing)


func _go_down() -> void:
	_state = State.DOWN
	attackComp.stop_attack()
	hurtbox.set_deferred("disabled", true)
	animatedSprite.stop()
	animatedSprite.play(&"death")   # one-shot: holds the last frame when it ends


## Called by Argus when this Herald's down timer runs out.
func revive() -> void:
	if _state != State.DOWN:
		return
	_state = State.REVIVING
	healthComp.resetHealth()
	animatedSprite.play_backwards(&"death")


## Called by Argus when he dies (the level can then end).
func final_death() -> void:
	if _state == State.DEAD:
		return
	var was_alive := _state == State.ALIVE
	_state = State.DEAD
	if death_blood.animation_finished.is_connected(free_zombie):
		death_blood.animation_finished.disconnect(free_zombie)
	super.die()   # deregister, death signals, blood, and plays "death"
	if was_alive:
		return   # freed when "death" finishes
	# Already lying down: keep the fallen pose and fade out instead of dying twice.
	animatedSprite.frame = animatedSprite.sprite_frames.get_frame_count(&"death") - 1
	animatedSprite.pause()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)


func _on_sprite_animation_finished() -> void:
	if animatedSprite.animation != &"death":
		return
	match _state:
		State.REVIVING:
			_state = State.ALIVE
			hurtbox.set_deferred("disabled", false)
			animatedSprite.setSpecialMoveFalse()   # let the sprite component pick Walk/Attack again
		State.DEAD:
			queue_free()


func _argus_alive() -> bool:
	return is_instance_valid(argus) and not argus.is_dead


func _in_house() -> bool:
	var wave_manager := Global.get_wave_manager()
	if wave_manager == null:
		return false
	var house := wave_manager.get("take_damage_area") as Area2D
	return house != null and house.overlaps_area(self)


# Lucretia's grasp can't turn a Herald.
func switch_sides() -> void:
	pass


func silence() -> void:
	if is_silenced:
		return
	super()
	attackComp.silence()


func get_zombie_name() -> String:
	return " HERALD "


func get_special_description() -> String:
	return "*Argus is immune while it lives"


#Temporary Will Replace
func get_zombie_icon() -> CompressedTexture2D:
	return Global.rohan_icon
