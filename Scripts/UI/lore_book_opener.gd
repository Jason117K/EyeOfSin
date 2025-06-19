extends Control


func _on_plant_codex_button_pressed() -> void:
	Global.game_controller.change_scene("res://Scenes/Systems/plant_lore_book.tscn",false,true)
	

func _on_zombie_codex_button_pressed() -> void:
	Global.game_controller.change_scene("res://Scenes/Systems/zombie_lore_book.tscn",false,true)
