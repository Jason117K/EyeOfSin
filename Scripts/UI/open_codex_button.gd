extends Button






func _on_pressed() -> void:
	get_tree().paused = true
	Global.game_controller.change_scene_with_pause_from_dual_scene("res://Scenes/Systems/lore_book_opener.tscn")


func _on_open_zombie_codex_button_pressed() -> void:
	get_tree().paused = true
	#Global.game_controller.change_scene_with_pause("res://Scenes/Systems/lore_book_opener.tscn")
	Global.game_controller.change_scene_with_pause("res://Scenes/Systems/zombie_lore_book.tscn")

#Just Codex Not Demon Codex
func _on_open_demon_codex_pressed() -> void:
	get_tree().paused = true
	Global.game_controller.change_scene_with_pause("res://Scenes/Systems/lore_book_opener.tscn")
	#Global.game_controller.change_scene_with_pause("res://Scenes/Systems/plant_lore_book.tscn")
