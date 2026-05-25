extends Demon

# --- Exports ---
@export var waitTime := 7.0
@export var buffedWaitTime := 4.0
@export var drone_attack_damage := 7
@export var spinalOcculumHealth := 800

@export var projectile_cooldown: float = 3
@export var projectile_auto_fire := false
@export var occulum_buff_cooldown: float = 0.9
@export var projectile_speed := 600
@export var projectile_damage := 20

@export var laser_color: Color = Color(1.0, 0.0, 0.0, 1.0)
@export var extension_speed: float = 1000.0
@export var max_length: float = 1000.0
@export var laser_width: float = 4.0
@export var laser_damage: float = 20
@export var maw_damage: float = 60
@export var duration: float = 0.5
@export var laser_auto_fire: bool = false
@export var laser_cooldown: float = 3
@export var blood_buff_cooldown: float = 0.9

# --- Constants ---
const SPINAL_OCCULUM_BUFF_MAX_DRONES = 4
const OCCULUM_BUFF_MAX_DRONES = 5

# --- State ---
var isWyrmBuffed := false
var isCrawlerBuffed := false
var isOcculumBuffed := false
var isMawBuffed := false
var thisBufferName: String
var is_demo := false
var buzz_audio: AudioStreamPlayer2D

# --- Component References ---
@onready var swarm := $Swarm
@onready var hive_laser_shoot_comp := $HiveLaserShootComp


# --- Lifecycle ---

func _ready() -> void:
	super()
	# --- Component init ---
	swarm.initialize(waitTime)
	swarm.set_damage(drone_attack_damage)
	# --- Audio ---
	buzz_audio = AudioManager.create_return_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.WASP_BUZZ)
	# --- Demon-specific collision ---
	_init_demon_collision()

func _init_demon_collision() -> void:
	if self.is_in_group("Green"):
		$DetectionComp.collision_mask = 3
		$DetectionComp.set_collision_mask_value(1, false)
		$DetectionComp.set_collision_mask_value(2, false)
		$DetectionComp.set_collision_mask_value(3, false)
		$DetectionComp.set_collision_mask_value(4, false)
		$DetectionComp.set_collision_mask_value(5, true)
	else:
		$DetectionComp.set_collision_mask_value(1, false)
		$DetectionComp.set_collision_mask_value(2, false)
		$DetectionComp.set_collision_mask_value(3, false)
		$DetectionComp.set_collision_mask_value(4, true)


# --- Getters ---

func get_demon_name() -> String:
	return "HIVE"

func get_demon_true_name() -> String:
	return "Hive"

func get_damage() -> int:
	return drone_attack_damage

func get_cost() -> float:
	return cost

func set_is_demo() -> void:
	$DetectionComp/CollisionShape2D.disabled = true
	$DetectionComp/CollisionShape2D2.disabled = false
	swarm.is_demo = true


# --- Buff System ---

func receive_buff(bufferName) -> void:
	var demonName : String = (bufferName.get_demon_true_name())
	if !isBuffed:
		super(demonName)
		for drone:Node in swarm.get_available_drones():
			drone.make_drone_glow()

		match demonName:
			"Occulum":
				swarm.set_respawn_wait_time(buffedWaitTime)
				swarm.set_max_drones(OCCULUM_BUFF_MAX_DRONES)
				swarm.kill_all_and_respawn()
				swarm.occulum_buff = true
			"Crawler":
				for drone:Node in swarm.get_available_drones():
					drone.crawler_buff()
				swarm.is_crawler_buffed = true
			"SpinalOcculum":
				swarm.set_max_drones(SPINAL_OCCULUM_BUFF_MAX_DRONES)
				swarm.is_spinal_occulum_buffed = true
				swarm.kill_all_and_respawn()
			"Wyrm":
				hive_laser_shoot_comp.isDisabled = false
				_activate_wyrm_buff()
			"Hive":
				pass
			"Maw":
				swarm.is_maw_buffed = true
				for drone:Area2D in swarm.get_all_drones():
					drone.maw_buff()
				if $"../Arm" != null:
					$"../Arm".visible = true 
					$"../Arm2".visible = true 

# Isolates async from receive_buff — laser re-init needs physics frames
func _activate_wyrm_buff() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	hive_laser_shoot_comp._ready()
	$ProjectileShootComponent.enable_auto_fire()

func debuff() -> void:
	super()


# --- Death ---

func _cleanup() -> void:
	# Kill drones and stop audio before base cleanup
	swarm.kill_all_drones()
	if buzz_audio and is_instance_valid(buzz_audio):
		buzz_audio.stop()
		buzz_audio.queue_free()
	super()

func get_demon_icon() -> CompressedTexture2D:
	return Global.hive_icon

func get_special_description() -> String:
	return Global.hive_special_description


# --- Preview ---

func _on_play_anim_timer_timeout() -> void:
	pass

func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSprite2D.visible = false
	$PreviewNodes.visible = true

func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false
