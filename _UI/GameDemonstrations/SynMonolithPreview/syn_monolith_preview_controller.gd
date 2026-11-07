extends CenterContainer
## Codex demo of the Syn Monolith on an Occulum, with a Spinal Occulum one tile right.
## Each loop: Reborn kill the Spinal Occulum, Beat of Death kills them, a second group
## dies to Lightning Strike, then Revive raises the Spinal Occulum. The abilities'
## own detection zones would fire Lightning first, so this script fires each one.

## Waits resume on this node's own signal, so a coroutine still waiting when the codex
## closes is dropped with the node instead of resuming on a freed instance.
signal _frame_ticked

const OCCULUM_SCENE := preload("res://_Entities/Demons/_Occulum/Occulum.tscn")
const SPINAL_OCCULUM_SCENE := preload("res://_Entities/Demons/_CagedOculum/SpinalOcculum.tscn")
const HERO_DEMON_SCENE := preload("res://_Entities/Demons/_Hero_Demon/hero_demon.tscn")

const LANE_Y := 100.0
const FIRST_WAVE_X: Array[float] = [165.0, 181.0, 197.0]
const SECOND_WAVE_X: Array[float] = [175.0, 191.0]
## Lightning Strike's bolts start 52 px right of the Monolith and fly right, so the second
## wave must still be right of the Occulum's slot + 52 when it fires.
const LIGHTNING_FIRE_X := 150.0
const SPINAL_OCCULUM_DEMO_HEALTH := 60.0
const LOOP_PAUSE := 2.0
const STEP_TIMEOUT := 20.0
const PURPLE_HUE_SHIFT := -86.0
const GREEN_HUE_SHIFT := 125.0

var _run_id := 0
var _hero: HeroDemon
var _spinal_occulum: Demon
var _spinal_occulum_dead := false
## Untyped: dead demo zombies free themselves, and reading a freed instance through a
## typed variable is a runtime error.
var _first_wave: Array = []
var _second_wave: Array = []
var _zombie_layer := Node2D.new()

@onready var _preview_world: Node2D = $Stage/SubViewportContainer/SubViewport/PreviewWorld
@onready var _occulum_slot: Node2D = $Stage/SubViewportContainer/SubViewport/PreviewWorld/DemonPosition5
@onready var _spinal_occulum_slot: Node2D = $Stage/SubViewportContainer/SubViewport/PreviewWorld/DemonPosition6


## A dying zombie looks for DemonManager on its grandparent, which is PreviewWorld from here.
func _ready() -> void:
	_zombie_layer.name = "Zombies"
	_preview_world.add_child(_zombie_layer)


func _process(_delta: float) -> void:
	_frame_ticked.emit()


func start() -> void:
	stop()
	_play_loop(_run_id)


func stop() -> void:
	_run_id += 1
	for zombie in _first_wave + _second_wave:
		if is_instance_valid(zombie):
			zombie.queue_free()
	_first_wave.clear()
	_second_wave.clear()
	for slot: Node2D in [_occulum_slot, _spinal_occulum_slot]:
		for child in slot.get_children():
			child.queue_free()
	_hero = null
	_spinal_occulum = null


func _play_loop(run: int) -> void:
	_spawn_occulum_with_monolith()
	_spawn_spinal_occulum()
	_first_wave = _spawn_reborn(FIRST_WAVE_X)

	if not await _wait_until(func() -> bool: return _spinal_occulum_dead, run):
		_restart_if_current(run)
		return

	var beat_of_death := _hero.beat_of_death_controller
	_fire(beat_of_death)
	_second_wave = _spawn_reborn(SECOND_WAVE_X)
	if not await _wait_until(func() -> bool: return not beat_of_death.is_active, run):
		_restart_if_current(run)
		return

	if not await _wait_until(_second_wave_in_lightning_range, run):
		_restart_if_current(run)
		return
	_fire(_hero.lightning_strike_controller)
	if not await _wait_until(_all_reborn_dead, run):
		_restart_if_current(run)
		return

	var revive_point := _find_revive_point()
	if revive_point == null:
		_restart_if_current(run)
		return
	revive_point.position = Vector2.ZERO
	revive_point.demo_revive = _spawn_spinal_occulum
	_hero.revive_controller.reset_cooldown()
	_hero.revive_controller.add_to_revive_array(revive_point)
	if not await _wait_until(func() -> bool: return is_instance_valid(_spinal_occulum), run):
		_restart_if_current(run)
		return

	if await _wait_seconds(LOOP_PAUSE, run):
		start()


func _spawn_occulum_with_monolith() -> void:
	var occulum := _spawn_demon(OCCULUM_SCENE, _occulum_slot)
	occulum.demo_blood_pickup()
	_hero = HERO_DEMON_SCENE.instantiate()
	_hero.make_demo()
	occulum.add_child(_hero)
	_hero.assign_parent_demon(occulum)


func _spawn_spinal_occulum() -> void:
	_spinal_occulum = _spawn_demon(SPINAL_OCCULUM_SCENE, _spinal_occulum_slot)
	_spinal_occulum.healthComp.health = SPINAL_OCCULUM_DEMO_HEALTH
	_spinal_occulum.healthComp.maxHealth = SPINAL_OCCULUM_DEMO_HEALTH
	_spinal_occulum_dead = false
	_spinal_occulum.demon_die.connect(func() -> void: _spinal_occulum_dead = true)


## Buff nodes are disabled so the two demons never buff each other, which would change
## the Spinal Occulum's health and could discover a synergy from inside the codex.
func _spawn_demon(scene: PackedScene, slot: Node2D) -> Demon:
	var demon: Demon = scene.instantiate()
	demon.add_to_group(Dim.PURPLE)
	demon.hide_preview()
	slot.add_child(demon)
	demon.set_spawn_anim_speed(20)
	demon.disable_buff_nodes()
	return demon


func _spawn_reborn(spawn_xs: Array[float]) -> Array:
	var hue_shift := PURPLE_HUE_SHIFT if Global.is_on_purple_dimension() else GREEN_HUE_SHIFT
	var wave: Array = []
	for spawn_x in spawn_xs:
		var zombie: Node2D = ZombieRegistry.SCENES["Reborn"].instantiate()
		zombie.add_to_group(Dim.PURPLE)
		zombie.make_demo()
		zombie.position = Vector2(spawn_x, LANE_Y)
		_zombie_layer.add_child(zombie)
		zombie.set_hue_shift(hue_shift)
		wave.append(zombie)
	return wave


func _fire(ability: HeroAbilityComponent) -> void:
	ability.reset_cooldown()
	ability.begin()


func _second_wave_in_lightning_range() -> bool:
	for zombie in _second_wave:
		if _is_alive(zombie) and zombie.position.x <= LIGHTNING_FIRE_X:
			return true
	return false


func _all_reborn_dead() -> bool:
	for zombie in _first_wave + _second_wave:
		if _is_alive(zombie):
			return false
	return true


func _is_alive(zombie) -> bool:
	return is_instance_valid(zombie) and not zombie.is_dead


func _find_revive_point() -> DemonRevivePoint:
	for child in _spinal_occulum_slot.get_children():
		if child is DemonRevivePoint:
			return child
	return null


## False when the step timed out or stop() cancelled this run.
func _wait_until(condition: Callable, run: int) -> bool:
	var time_left := STEP_TIMEOUT
	while not condition.call():
		await _frame_ticked
		if run != _run_id:
			return false
		time_left -= get_process_delta_time()
		if time_left <= 0.0:
			push_warning("Syn Monolith preview: a step timed out, restarting the loop")
			return false
	return run == _run_id


func _wait_seconds(seconds: float, run: int) -> bool:
	var time_left := seconds
	while time_left > 0.0:
		await _frame_ticked
		if run != _run_id:
			return false
		time_left -= get_process_delta_time()
	return true


func _restart_if_current(run: int) -> void:
	if run == _run_id:
		start()
