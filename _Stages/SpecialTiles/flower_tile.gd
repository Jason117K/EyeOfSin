extends Area2D

@export var is_alt := false 

@onready var green_bones := $GreenBones
@onready var purple_bones := $PurpleBones

func _ready() -> void:
	if is_alt:
		self.add_to_group("Green")
	else:
		self.add_to_group("Purple")
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,false)
		self.set_collision_mask_value(5,true)
		green_bones.show()
		purple_bones.hide()
	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,true)
		purple_bones.show()
		green_bones.hide()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		Global.lose_game()
		
