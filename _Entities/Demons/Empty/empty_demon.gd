extends Demon

@export var blood_clone_respawn_time : int = 45
@onready var blood_clone_respawn_timer : Timer = $RespawnBloodCloneTimer
var demon_selection_menu : Control
var blood_clone
# Set when the clone is dispelled while place_blood_demon is still awaiting it.
var pending_dispel := false
var is_summoning := false

	
	
func die_fromClearSpace() -> void:
	queue_free()

func _ready() -> void:
	#print("THIS EMPTY IS GREEN IS : ", is_green)
	#print("Empty Spawned, ", self)
	disable_buff_nodes()
	demon_selection_menu = Global.get_demon_selection_menu(!is_green)
	demon_manager = Global.get_demon_manager(!is_green)
	
	blood_clone_respawn_timer.timeout.connect(summon_blood_clone)
	blood_clone_respawn_timer.wait_time = blood_clone_respawn_time

func set_demon_type(new_demon_type : Global.DEMON_TYPE)->void:
	current_demon_type = new_demon_type
	#print("Current Demon Type Is : ", current_demon_type)

			
	

func summon_blood_clone()->void:
	#print("2 Current Demon Type Is : ", current_demon_type)
	# Take the scene straight from the menu's refs. Pressing the card handler here
	# played a UI click, bumped OcculumCost, showed a placement preview and then
	# cleared whatever card the player had selected.
	var clone_scene : PackedScene = _clone_scene()
	if clone_scene == null:
		return

	pending_dispel = false
	is_summoning = true
	var new_clone : Demon = await demon_manager.place_blood_demon(global_position, clone_scene)
	is_summoning = false
	if pending_dispel:
		# Dispelled while the clone was still being placed.
		pending_dispel = false
		new_clone.dispel_blood_clone_instance()
		return
	blood_clone = new_clone
	blood_clone.set_blood_empty_parent(self)
	hide()


func _clone_scene() -> PackedScene:
	match current_demon_type:
		Global.DEMON_TYPE.CRAWLER:
			return demon_selection_menu.crawler_scene
		Global.DEMON_TYPE.OCCULUM:
			return demon_selection_menu.occulum_scene
		Global.DEMON_TYPE.SPINAL_OCCULUM:
			return demon_selection_menu.spinalOcculum_scene
		Global.DEMON_TYPE.WYRM:
			return demon_selection_menu.wyrm_scene
		Global.DEMON_TYPE.MAW:
			return demon_selection_menu.maw_scene
		Global.DEMON_TYPE.HIVE:
			return demon_selection_menu.hive_scene
	return null


func dispel_blood_clone(should_respawn : bool = false)->void:
	if is_summoning:
		pending_dispel = true
	if not should_respawn:
		# The hero is gone: a clone killed earlier must not respawn later.
		blood_clone_respawn_timer.stop()
	if is_instance_valid(blood_clone):
		if should_respawn:
			blood_clone_respawn_timer.start()
		blood_clone.dispel_blood_clone_instance()
	blood_clone = null
	show()

	


func on_demon_area_entered(_new_area: Area2D) -> void:
	pass

func on_demon_area_exited(_old_area: Area2D) -> void:
	pass

func receive_buff(_newDemon:String) -> void:
	pass


func truncate_string(_input_string: String) -> String:
	pass
	return ""

func receive_heart_buff() -> void:
	pass

func remove_heart_buff() -> void:
	pass
