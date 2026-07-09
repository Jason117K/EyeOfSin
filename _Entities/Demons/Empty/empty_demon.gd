extends Demon

@export var blood_clone_respawn_time : int = 45
@onready var blood_clone_respawn_timer : Timer = $RespawnBloodCloneTimer
var demon_selection_menu : Control
var blood_clone

	
	
func die_fromClearSpace() -> void:
	queue_free()

func _ready() -> void:
	print("THIS EMPTY IS GREEN IS : ", is_green)
	disable_buff_nodes()
	demon_selection_menu = Global.get_demon_selection_menu(!is_green)
	demon_manager = Global.get_demon_manager(!is_green)
	
	blood_clone_respawn_timer.timeout.connect(summon_blood_clone)
	blood_clone_respawn_timer.wait_time = blood_clone_respawn_time

func set_demon_type(new_demon_type : Global.DEMON_TYPE)->void:
	current_demon_type = new_demon_type
	print("Current Demon Type Is : ", current_demon_type)

			
	

func summon_blood_clone()->void:
	print("2 Current Demon Type Is : ", current_demon_type)
	match current_demon_type:
		Global.DEMON_TYPE.CRAWLER:
			demon_selection_menu._on_CrawlerButton_pressed()
		Global.DEMON_TYPE.OCCULUM:
			demon_selection_menu._on_OcculumButton_pressed()
		Global.DEMON_TYPE.SPINAL_OCCULUM:
			demon_selection_menu._on_SpinalOcculumButton_pressed()
		Global.DEMON_TYPE.WYRM:
			demon_selection_menu._on_WyrmButton_pressed()
		Global.DEMON_TYPE.MAW:
			demon_selection_menu._on_MawButton_pressed()
		Global.DEMON_TYPE.HIVE:
			demon_selection_menu._on_HiveButton_pressed()
			
	blood_clone = await demon_manager.place_blood_demon(global_position)
	blood_clone.set_blood_empty_parent(self)
	hide()


func dispel_blood_clone(should_respawn : bool = false)->void:
	if blood_clone != null:
		if should_respawn:
			blood_clone_respawn_timer.start()
		blood_clone.queue_free()
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
