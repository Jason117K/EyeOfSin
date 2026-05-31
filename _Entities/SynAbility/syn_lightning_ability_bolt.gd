extends Area2D

@export var damage := 100
@export var aftershock_dmg := 25 
@export var aftershock_interval := 3
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

var is_on_green := false 

func _ready() -> void:
	lightning_ball_anim.hide()
	lightning_aftershock_anim.hide()
	lightning_connector_line.hide()
	
	aftershock_duration_timer.wait_time = aftershock_duration
	aftershock_duration_timer.timeout.connect(end_ability)
	
	Global.register_lightning_ball(self)

	
	if self.is_in_group("Green"):
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,false)
		self.set_collision_mask_value(5,true)
		lightning_anim_current = "green"
		is_on_green = true 
	else:
		self.set_collision_mask_value(1,false)
		self.set_collision_mask_value(2,false)
		self.set_collision_mask_value(3,false)
		self.set_collision_mask_value(4,true)
		lightning_anim_current = "purple"
		is_on_green = false 
	
	shock_dmg_timer.timeout.connect(aftershock_damage)
	shock_dmg_timer.wait_time = aftershock_interval
	shock_dmg_timer.autostart = false 
	shock_dmg_timer.one_shot = false
		
	lightning_strike_anim.animation = lightning_anim_current
	lightning_strike_anim.frame_changed.connect(damage_zombies)
	lightning_strike_anim.show()
	lightning_strike_anim.play()

	
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
	for zombie in get_overlapping_areas():
		if zombie.is_in_group("Zombie"):
			zombie.take_damage(aftershock_dmg)
	
	
func connect_lightning(lightning_to_connect : Area2D)->void:
	print("Attempt Connect Lightning")
	lightning_connector_line.show()
	var target_local :Vector2 = lightning_connector_line.to_local(lightning_to_connect.global_position)
	if lightning_connector_line.get_point_count() < 2:
		lightning_connector_line.add_point(target_local)
	else:
		lightning_connector_line.set_point_position(1, target_local)
		
	lightning_connector_pivot.global_rotation =  lightning_connector_line.global_position.angle_to_point(lightning_to_connect.global_position)
	lightning_connector_anim.play()
		
func end_ability()->void:
	Global.deregister_lightning_ball(self)
	queue_free()
		
	
	
	
	
	
	
	
	
	
	
	
	
	##
	
		
