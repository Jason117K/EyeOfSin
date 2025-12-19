extends Control


@onready var toolTips = $"../ToolTips"
@onready var plantManager = $PlantManager
@onready var plantSelectionMenu = $PlantSelectionMenu
@onready var waveManager = $GameLayer/WaveManager
@onready var levelSwitcher = 	$"../LevelSwitcher"
@onready var spotlight_overlay = $"../SpotlightOverlay"  # Reference to CanvasLayer


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)
