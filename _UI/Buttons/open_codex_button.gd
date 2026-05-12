extends Button






func _on_pressed() -> void:
	print("PAUSE GAME")
	get_tree().paused = true
	Global.game_controller.change_scene_with_pause_from_dual_scene("res://_UI/LoreBooks/lore_book_opener.tscn")


func _on_open_zombie_codex_button_pressed() -> void:
	print("PAUSE GAME")
	get_tree().paused = true
	Global.game_controller.change_scene_with_pause("res://_UI/LoreBooks/zombie_lore_book.tscn")

#Just Codex Not Demon Codex
func _on_open_demon_codex_pressed() -> void:
	print("PAUSE GAME")
	get_tree().paused = true
	Global.game_controller.change_scene_with_pause("res://_UI/LoreBooks/lore_book_opener.tscn")
