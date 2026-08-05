extends Area2D

@export var lightning_damage := 100 
@onready var syn_lightning_animation := $SynLightning
@onready var all_aftershocks := $AfterShocks

func _ready() -> void:
	#print("SYN LIGHTNING STRIKE!")
	syn_lightning_animation.animation_finished.connect(_on_animation_finished)
	syn_lightning_animation.frame_changed.connect(_on_syn_lightning_frame_changed)
	
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
		
	syn_lightning_animation.play()


func _on_animation_finished() -> void:
	#for area in self.get_overlapping_areas():
		#if area.is_in_group("Zombie"):
			#area.take_damage(lightning_damage)
	queue_free()
		
		
func _on_syn_lightning_frame_changed()->void:
	#print("Syn Lightning Animation Frame Changed Checking Loop ", syn_lightning_animation.frame)
	if syn_lightning_animation.frame == 1:
		for area in self.get_overlapping_areas():
			if area.is_in_group("Zombie"):
				area.take_damage(false,lightning_damage,false)
				
	if syn_lightning_animation.frame == 2:
		for shock in all_aftershocks.get_children():
			#print("Loop setting: ", shock.sprite_frames.get_animation_loop(shock.animation))
			#print("Animation: ", shock.animation)
			shock.play()
			
