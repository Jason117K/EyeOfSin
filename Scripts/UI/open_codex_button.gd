extends Button






func _on_pressed() -> void:
	get_tree().paused = true
	Global.game_controller.change_scene("res://Scenes/Systems/lore_book_opener.tscn",false,true)
