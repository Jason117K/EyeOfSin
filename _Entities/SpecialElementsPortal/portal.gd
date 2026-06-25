extends Area2D

@onready var animSprite := $PortalAnimSprite
@onready var cooldown_timer :Timer = $CooldownTimer

@export var cooldown_wait_time : float = 10 
@export var use_cooldown := true 
@export var omni_directional := false 

var portal_progress_bar : ProgressBar
var percent_left : float 

var demon_manager : Node
var grid_map_cell_pos : Vector2

	

#Make Place Other Portal
func _ready() -> void:
	if omni_directional:
		self.add_to_group("EntrancePortal")
	cooldown_timer.wait_time = cooldown_wait_time
	cooldown_timer.timeout.connect(free_portals)
	
	if self.is_in_group("Green"):
		Global.register_green_portal(self)
		self.set_collision_mask_value(5,true)
		animSprite.animation = "Purple"
	elif self.is_in_group("Purple"):
		Global.register_purple_portal(self)
		self.set_collision_mask_value(4,true)
		animSprite.animation = "Green"
	_init_demon_manager()

func free_portals()->void:
	if use_cooldown:
		Global.free_portals()
	else:
		pass

func free_portal()->void:
	if demon_manager != null:
		print("DM IS ", demon_manager)
		# Remove the blocker relative to THIS portal's dimension, not the active one —
		# free_portals() frees both portals in one frame, so the active flag is wrong for one of them.
		demon_manager.clear_space_for_source(grid_map_cell_pos, is_in_group("Purple"))
	queue_free()
	
	
func start_cooldown()->void:
	portal_progress_bar = Global.get_portal_progress_bar(self)
	cooldown_timer.start()

func _process(_delta: float) -> void:
	if !use_cooldown:
		portal_progress_bar.hide()
		return
	elif !cooldown_timer.is_stopped():
		if portal_progress_bar != null:
			portal_progress_bar.show()
		percent_left = (cooldown_timer.time_left / cooldown_timer.wait_time) * 100
		if portal_progress_bar != null:
			portal_progress_bar.value = percent_left
			
	
		
 

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Zombie"):
		print("Swap Portal Area Entered")
		if area.is_in_group("HasTeleported"):
			pass
		else:
			if self.is_in_group("EntrancePortal"):
				if self.is_in_group("Purple") && area.is_in_group("Purple"):
					print("SWAP ZOMBIE DIMENSION PURPLE->GREEN")
					area.add_to_group("HasTeleported")
					area.change_dimensions(Global.get_green_portal_location())
					
				elif self.is_in_group("Green") && area.is_in_group("Green"):
					print("SWAP ZOMBIE DIMENSION GREEN->PURPLE")
					area.add_to_group("HasTeleported")
					area.change_dimensions(Global.get_purple_portal_location())


func _on_area_exited(_area: Area2D) -> void:
	pass # Replace with function body.

func get_cost() -> int:
	return 0


func _on_lightning_spawn_animation_finished() -> void:
	$LightningSpawn.hide()





func _init_demon_manager() -> void:
	var _dm_parent: Node = get_parent()
	if _dm_parent:
		var _dm_grandparent: Node = _dm_parent.get_parent()
		if _dm_grandparent and _dm_grandparent.has_node("DemonManager"):
			demon_manager = _dm_grandparent.get_node("DemonManager")
	print("Portal Demon Manager is ", demon_manager)

func finish_spawn() -> void:
	pass

func demon_deselected()->void:
	pass
	
func demon_selected()->void:
	pass
