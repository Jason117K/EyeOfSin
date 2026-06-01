extends Syn_Ability_Instance

@export var damage := 100
@export var aftershock_dmg := 25 
@export var aftershock_interval := 1.2
@export var aftershock_duration := 10

@onready var lightning_strike_anim := $AnimatedSprite2D
@onready var lightning_aftershock_anim := $Aftershock
@onready var lightning_ball_anim := $LightningBall
@onready var lightning_anim_current := "purple"
@onready var shock_dmg_timer := $ShockDMGTimer
@onready var aftershock_duration_timer := $AftershockDurationTimer
@onready var ball_origin :Vector2 = $LightningBall.global_position
@onready var lightning_connector_line := $LightningConnectorLine2D
@onready var lightning_connector_anim := $LightningPivot/LightningConnector
@onready var lightning_connector_pivot := $LightningPivot
@onready var shadow_orb := $ShadowOrb
@onready var default_connector_length : float = lightning_connector_line.points[1].length()
@onready var lightning_connector_area : Area2D = $LightningPivot/LightningConnectorArea


var is_on_green := false 
var is_lightning_connected := false

func _ready() -> void:
	detect_zombies = true 
	lightning_ball_anim.hide()
	lightning_aftershock_anim.hide()
	lightning_connector_line.hide()
	
	aftershock_duration_timer.wait_time = aftershock_duration
	aftershock_duration_timer.timeout.connect(end_ability)
	
	grid_pos = mouse_pos_to_grid(global_position)
	self.global_position = grid_pos	
		
	set_detect_zombies(lightning_connector_area)

	
	if self.is_in_group("Green"):
		lightning_anim_current = "green"
		is_on_green = true 
	else:
		lightning_anim_current = "purple"
		is_on_green = false 
	
	lightning_connector_anim.animation = lightning_anim_current
	shadow_orb.animation = lightning_anim_current
	
	shock_dmg_timer.timeout.connect(aftershock_damage)
	shock_dmg_timer.wait_time = aftershock_interval
	shock_dmg_timer.autostart = false 
	shock_dmg_timer.one_shot = false
		
	lightning_strike_anim.animation = lightning_anim_current
	lightning_strike_anim.frame_changed.connect(damage_zombies)
	lightning_strike_anim.show()
	lightning_strike_anim.play()
	
	super()

	
func damage_zombies()->void:
	print("Lightning Frame is ", lightning_strike_anim.frame)
	if lightning_strike_anim.frame == 2:
		for zombie in self.get_overlapping_areas():
			if zombie.is_in_group("Zombie"):
				zombie.take_damage(false,damage,false)
		spawn_aftershock()
		
func spawn_aftershock()->void:
	lightning_ball_anim.animation = lightning_anim_current
	lightning_aftershock_anim.animation = lightning_anim_current
	lightning_ball_anim.show()
	lightning_aftershock_anim.show()
	lightning_ball_anim.play()
	lightning_aftershock_anim.play()
	aftershock_duration_timer.start()
	shock_dmg_timer.start()

func aftershock_damage()->void:
	print("Aftershock Damage Called ", aftershock_dmg)
	for zombie in get_overlapping_areas():
		if zombie.is_in_group("Zombie"):
			zombie.take_damage(false,aftershock_dmg,false)
	if is_lightning_connected:
		for zombie in lightning_connector_area.get_overlapping_areas():
			if zombie.is_in_group("Zombie"):
				zombie.take_damage(false,aftershock_dmg,false)
	
func connect_ability(lightning_to_connect : Area2D)->void:
	print("Attempt Connect Lightning")
	lightning_connector_line.hide()
	var target_local :Vector2 = lightning_connector_line.to_local(lightning_to_connect.global_position)
	if lightning_connector_line.get_point_count() < 2:
		lightning_connector_line.add_point(target_local)
	else:
		lightning_connector_line.set_point_position(1, target_local)
	
	var angle = lightning_connector_pivot.global_position.angle_to_point(lightning_to_connect.global_position)
	lightning_connector_pivot.global_rotation = angle - PI / 2.0
	
	var distance = lightning_connector_pivot.global_position.distance_to(lightning_to_connect.global_position)
	lightning_connector_pivot.scale.y = distance / default_connector_length
	
	place_shadow_orb(lightning_to_connect.global_position)
	
	lightning_connector_anim.play()
	
	is_lightning_connected = true 

func place_shadow_orb(new_position:Vector2)->void:
	shadow_orb.global_position = new_position
	shadow_orb.show()
	shadow_orb.play()

		
func end_ability()->void:
	Global.deregister_syn_ability(self)
	queue_free()
		
	
	
	
	
	
func mouse_pos_to_grid(mouse_pos: Vector2) -> Vector2:
	return Vector2(floor(mouse_pos.x / grid_size), floor(mouse_pos.y / grid_size)) * grid_size
	
	
func get_icon()->Texture:
	return Global.lightning_strike_button_icon	
	
	
	
	
	
	##
	
		
