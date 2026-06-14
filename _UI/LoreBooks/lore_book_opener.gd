extends Control

@onready var demon_codex_panel := $HBoxContainer/PanelContainer
@onready var zombie_codex_panel := $HBoxContainer/PanelContainer2

@onready var normal_demon_style_box := load("res://_UI/LoreBooks/demon_style_box_texture.tres")
@onready var normal_zombie_style_box := load("res://_UI/LoreBooks/zombie_style_box_texture.tres")
@onready var hover_style_box := load("res://_UI/bordered_button_hover.tres")

func _ready() -> void:
	Global.hideDemonSelectionMenu()
	#_on_demon_codex_button_pressed()
	
func _on_demon_codex_button_pressed() -> void:
	print("PAUSE GAME AND OPEN DEMON CODEX")
	#get_tree().paused = true
	Global.game_controller.change_scene_with_pause("res://_UI/LoreBooks/demon_lore_book.tscn")
	

func _on_zombie_codex_button_pressed() -> void:
	Global.game_controller.change_scene_with_pause("res://_UI/LoreBooks/zombie_lore_book.tscn")


func _on_back_button_pressed() -> void:
	self.visible = false
	print("BBack Button Pressed")
	#Global.unHideDemonSelectionMenu()
	Global.game_controller.restore_dual_scenes()


func _on_zombie_codex_button_mouse_entered() -> void:
	zombie_codex_panel.add_theme_stylebox_override("panel",hover_style_box) # Replace with function body.


func _on_demon_codex_button_mouse_entered() -> void:
	demon_codex_panel.add_theme_stylebox_override("panel",hover_style_box) 


func _on_demon_codex_button_mouse_exited() -> void:
	demon_codex_panel.add_theme_stylebox_override("panel",normal_demon_style_box) 


func _on_zombie_codex_button_mouse_exited() -> void:
	zombie_codex_panel.add_theme_stylebox_override("panel",normal_zombie_style_box) 
