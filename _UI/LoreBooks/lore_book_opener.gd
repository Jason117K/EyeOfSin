extends Control



func _ready() -> void:
	Global.hideDemonSelectionMenu()
	_on_plant_codex_button_pressed()
	
func _on_plant_codex_button_pressed() -> void:
	print("PAUSE GAME")
	get_tree().paused = true
	Global.game_controller.change_scene_with_pause("res://Scenes/Systems/plant_lore_book.tscn")
	

func _on_zombie_codex_button_pressed() -> void:
	Global.game_controller.change_scene_with_pause("res://Scenes/Systems/zombie_lore_book.tscn")


func _on_back_button_pressed() -> void:
	self.visible = false 
	print("BBack Button Pressed")
	Global.unHideDemonSelectionMenu()
	Global.game_controller.restore_dual_scenes()
