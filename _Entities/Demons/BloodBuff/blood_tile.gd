extends Area2D

var area_birth_time : float 
var buff_active : bool = true 


func _ready() -> void:
	area_birth_time = Time.get_ticks_msec() / 1000.0

func get_area_birth_time()->float:
	return area_birth_time

func set_buff_active()->void:
	print(self, get_parent().get_parent()," set buff active")
	buff_active = true

func set_buff_inactive()->void:
	print(self, get_parent().get_parent(), " set buff not active")
	buff_active = false

func show_preview_square()->void:
	for child in self.get_children():
		if child is Sprite2D:
			child.show()
		if child is CollisionShape2D:
			child.debug_color = Color.BLUE
			
				
func hide_preview_square()->void:
	for child in self.get_children():
		if child is Sprite2D:
			child.hide()
		if child is CollisionShape2D:
			child.debug_color = Color.RED
			
