extends Control


func _on_plant_codex_button_pressed() -> void:
	Global.game_controller.change_scene_with_pause("res://Scenes/Systems/plant_lore_book.tscn")
	

func _on_zombie_codex_button_pressed() -> void:
	Global.game_controller.change_scene_with_pause("res://Scenes/Systems/zombie_lore_book.tscn")


func _on_back_button_pressed() -> void:
	self.visible = false 
	print("BBack Button Pressed")
	Global.game_controller.restore_previous_scene()
