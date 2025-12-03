extends Control
# level_0_1_alternate.gd - Green Dimension Controller for Level 0-1
# Waits for purple dimension to activate Wave 2

@onready var waveManager = $GameLayer/WaveManager
@onready var plantManager = $PlantManager

var waiting_for_wave_2: bool = true


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Keep waves disabled until purple dimension activates us
	waveManager.canStartGame = false
	print("[Level0-1 Alternate] Green dimension loaded, waiting for Wave 2 activation")


func start_wave_2():
	print("[Level0-1 Alternate] Wave 2 activated in green dimension")
	waiting_for_wave_2 = false
	waveManager.canStartGame = true
	waveManager.startSecondWave()


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)


func make_camera_current():
	$Camera2D.make_current()
