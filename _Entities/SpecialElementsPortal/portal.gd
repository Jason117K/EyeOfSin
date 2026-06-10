extends Area2D

@onready var animSprite := $PortalAnimSprite
@onready var cooldown_timer :Timer = $CooldownTimer

@export var cooldown_wait_time : float = 10 
@export var use_cooldown := true 
@export var omni_directional := false 

var portal_progress_bar : ProgressBar

var percent_left : float 

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

func free_portals()->void:
	if use_cooldown:
		Global.free_portals()
	else:
		pass
	
func start_cooldown()->void:
	portal_progress_bar = Global.get_portal_progress_bar(self)
	cooldown_timer.start()

func _process(_delta: float) -> void:
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


func finish_spawn() -> void:
	pass
