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
	print("========== GREEN DIMENSION START_WAVE_2 CALLED ==========")
	print("[GREEN] Current time: ", Time.get_ticks_msec())
	print("[GREEN] waiting_for_wave_2 BEFORE: ", waiting_for_wave_2)
	print("[GREEN] waveManager.numWave BEFORE: ", waveManager.numWave)
	print("[GREEN] waveManager.canStartGame BEFORE: ", waveManager.canStartGame)
	print("[GREEN] waveManager.wave_active BEFORE: ", waveManager.wave_active)

	waiting_for_wave_2 = false
	waveManager.numWave = 1             # Initialize wave state for Wave 2

	print("[GREEN] waveManager.numWave SET TO: ", waveManager.numWave)
	print("[GREEN] About to call startSecondWave()...")

	waveManager.startSecondWave()       # This increments numWave to 2

	print("[GREEN] waveManager.numWave AFTER startSecondWave: ", waveManager.numWave)
	print("[GREEN] waveManager.$Wave2.is_stopped(): ", waveManager.get_node("Wave2").is_stopped())
	print("[GREEN] waveManager.$Wave2.wait_time: ", waveManager.get_node("Wave2").wait_time)
	print("[GREEN] Number of spawners: ", waveManager.spawners.size())
	print("========== GREEN DIMENSION START_WAVE_2 COMPLETED ==========")


func place_empty_blocker_plant(grid_pos):
	plantManager.place_empty_blocker_plant(grid_pos)


func make_camera_current():
	$Camera2D.make_current()
