extends Control


var startScreen := ("res://_Stages/StartScreen/StartScreen.tscn")
var level_select := "res://_Stages/LevelSelect/act_select.tscn"


var ability_screen := "res://_UI/ability_control_panel.tscn"

var all_panel_containers : Array = []
var show_green := false

@onready var swap_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/AbilitiesVbox/SwapPanelContainer/SwapMarginContainer/SwapSorcery
@onready var syn_icon := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/AbilitiesVbox/SynPanelContainer/SynMarginContainer/SynSorcery

@onready var demon_grid := $Acts_MarginContainer/Acts_Hbox/Loadout_Vbox/MarginContainer/DemonPanelContainer/MarginContainer/LoadOutVboxes/DemonVbox/DemonGridContainer

@onready var green_earth := $GreenEarth
@onready var purple_earth := $PurpleEarth

@onready var act_panel_container : PanelContainer = $Acts_MarginContainer/Acts_Hbox/ScrollContainer/Acts_Vbox/Act_2_PanelContainer

@onready var purple_bg := $BG_Purple
@onready var green_bg := $BG_Green


var level_15 := ("res://_Stages/Level15/Level15.tscn")
var level_15_alt := ("res://_Stages/Level15/Level15_Alternate.tscn")

var level_16 := ("res://_Stages/Level16/Level16.tscn")
var level_16_alt := ("res://_Stages/Level16/Level16_Alternate.tscn")

var level_17 := ("res://_Stages/Level17/Level17.tscn")
var level_17_alt := ("res://_Stages/Level17/Level17_Alternate.tscn")




func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	Global.hideDemonSelectionMenu()
	swap_icon.texture = Global.get_swap_icon()
	syn_icon.texture = Global.get_syn_icon()
	
	Global.swap_scenes_signal.connect(swap_textures)
	
	assemble_panel_containers(self)
	DemonLoadout.connect_grid(demon_grid, func() -> bool: return show_green)
	refresh_locks() # level locks + demon grid


# Also called by GameController after the Ctrl+U debug unlock.
func refresh_locks() -> void:
	Progress.apply_level_locks(self, 3)
	set_demon_unlocks()


func set_demon_unlocks()->void:
	# Hidden = locked; darkened = unlocked but not in this dimension's loadout.
	DemonLoadout.refresh_grid(demon_grid, show_green)
	

func assemble_panel_containers(given_node : Node)->void:
	for node in given_node.get_children():
		if node.name == "LevelPanelContainer":
			all_panel_containers.append(node)
		assemble_panel_containers(node)
		
	
	
func swap_textures()->void:
	show_green = !show_green
	
	for panel_container:PanelContainer in all_panel_containers:
		if show_green:
			panel_container.get_child(0).show()
			panel_container.get_child(1).hide()
			green_earth.visible = true 
			purple_earth.visible = false
			act_panel_container.get_theme_stylebox("panel").bg_color = Color("00240ab5")
			purple_bg.hide()
			green_bg.show()
		elif !show_green:
			panel_container.get_child(0).hide()
			panel_container.get_child(1).show()
			green_earth.visible = false 
			purple_earth.visible = true
			act_panel_container.get_theme_stylebox("panel").bg_color = Color("2400309b")
			purple_bg.show()
			green_bg.hide()
	# Y flips which dimension's loadout the demon grid shows and edits.
	set_demon_unlocks()


func _on_back_pressed() -> void:
	Global.game_controller.change_scene(startScreen)


func _on_current_sorcery_button_pressed() -> void:
	Global.game_controller.change_scene(ability_screen)


func _on_back_button_pressed() -> void:
	Global.game_controller.change_scene(level_select)


func _on_level_1_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_15,level_15_alt)


func _on_level_2_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_16,level_16_alt)


func _on_level_3_button_pressed() -> void:
	Global.game_controller.change_dual_scenes(level_17,level_17_alt)
