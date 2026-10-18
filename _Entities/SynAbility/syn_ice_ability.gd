extends Syn_Ability_Instance

@export var ice_bleed_amount := 7
@export var on_hit_damage := 25
# After erupting, a cast stays as a dimmed ice mark for ability_duration so the
# other dimension's cast can pair with it.
@export var ice_mark_alpha := 0.45
# Distance between eruption spikes along the line to the paired cast.
@export var spike_spacing := 32.0
# Delay between consecutive spikes, so the eruption runs along the line.
@export var spike_stagger := 0.05
@onready var blood_ice_anim := $Blood_Ice_Anim

# Eruption spike spawned by a paired cast: erupts once and frees itself. It
# doesn't register or touch the Syn charge.
var is_spike := false
var erupt_delay := 0.0
var has_erupted_pair := false

func _ready() -> void:
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,false)
		self.set_collision_mask_value(5,true)
	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,true)

	if is_spike:
		blood_ice_anim.hide()
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		if erupt_delay > 0.0:
			await get_tree().create_timer(erupt_delay, false).timeout
		blood_ice_anim.show()
		ice_attack()
		return
	# Base lifecycle: erupts (activate_ability) after the overlap-settling frames,
	# registers for pairing, and starts the mark's lifetime.
	super()


func activate_ability()->void:
	ice_attack()

func ice_attack()->void:
	blood_ice_anim.frame_changed.connect(ice_bleed_zombies)
	blood_ice_anim.animation_finished.connect(end_attack)
	blood_ice_anim.play()



func ice_bleed_zombies()->void:
	if blood_ice_anim.frame == 2:
		for zombie in get_overlapping_areas():
			if zombie.is_in_group("Zombie"):
				zombie.take_damage(false, on_hit_damage, false)
				zombie.bleed(ice_bleed_amount)



func end_attack()->void:
	if is_spike:
		queue_free()
		return
	# The last frame stays, dimmed, as the ice mark until the death timer ends.
	blood_ice_anim.modulate.a = ice_mark_alpha

# The other dimension's cast landed while this mark is up: erupt along the line
# between the two casts, in this dimension. Both halves do this, once.
func connect_ability(other_ice : Area2D)->void:
	if has_erupted_pair or is_spike:
		return
	has_erupted_pair = true
	var start := global_position
	var target := other_ice.global_position
	var steps := int(start.distance_to(target) / spike_spacing)
	for i in range(1, steps + 1):
		var spike : Node = load(scene_file_path).instantiate()
		spike.is_spike = true
		spike.erupt_delay = spike_stagger * i
		# Group before entering the tree: _ready picks the collision mask from it.
		spike.add_to_group("Green" if self.is_in_group("Green") else "Purple")
		spike.global_position = start.lerp(target, float(i) / steps)
		get_parent().add_child(spike)



func get_icon()->Texture:
	return Global.blood_ice_button_icon




	##
