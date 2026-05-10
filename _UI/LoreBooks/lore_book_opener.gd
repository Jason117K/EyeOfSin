extends Control



func _ready() -> void:
	Global.hideDemonSelectionMenu()
	#_on_demon_codex_button_pressed()
	
func _on_demon_codex_button_pressed() -> void:
	print("PAUSE GAME AND OPEN DEMON CODEX")
	get_tree().paused = true
	Global.game_controller.change_scene_with_pause("res://_UI/LoreBooks/demon_lore_book.tscn")
	

func _on_zombie_codex_button_pressed() -> void:
	Global.game_controller.change_scene_with_pause("res://_UI/LoreBooks/zombie_lore_book.tscn")


func _on_back_button_pressed() -> void:
	self.visible = false 
	print("BBack Button Pressed")
	Global.unHideDemonSelectionMenu()
	Global.game_controller.restore_dual_scenes()
