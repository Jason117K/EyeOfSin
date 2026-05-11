extends Demon

@export var cost = 25
@export var waitTime := 7.0
@export var buffedWaitTime := 4.0

var isEggWyrmBuffed := false
var isSpyderBuffed := false
var isSunflowerBuffed := false
var isMawBuffed := false
var PlantManager
var thisBufferName: String

@onready var buffNodes = $BuffNodesComponent
@onready var swarm = $Swarm

const WALNUT_BUFF_MAX_DRONES = 4
const SUN_BUFF_MAX_DRONES = 5


func _ready():
	super()
	swarm.initialize(waitTime)
	PlantManager = get_parent().get_parent().get_node("PlantManager")
	AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.WASP_BUZZ)

	if self.is_in_group("Green"):
		$DetectionComp.collision_mask = 3
		$DetectionComp.set_collision_mask_value(1, false)
		$DetectionComp.set_collision_mask_value(2, false)
		$DetectionComp.set_collision_mask_value(3, true)
	else:
		$DetectionComp.set_collision_mask_value(1, false)
		$DetectionComp.set_collision_mask_value(2, true)
		$DetectionComp.set_collision_mask_value(3, false)


func get_cost():
	return cost


func receiveBuff(bufferName):
	if !isBuffed:
		super(bufferName)
		for drone in swarm.get_available_drones():
			drone.make_drone_glow()
		if("EggWorm" in bufferName.name):
			$HiveLaserShootComp.isDisabled = false
			$HiveLaserShootComp._ready()
			isEggWyrmBuffed = true
		if("Peashooter" in bufferName.name) && !isSpyderBuffed:
			for drone in swarm.get_available_drones():
				drone.makeExplode()
				drone.isSpyderBuffed = true
			isSpyderBuffed = true
		if("Sun" in bufferName.name):
			swarm.set_respawn_wait_time(buffedWaitTime)
			isSunflowerBuffed = true
			swarm.set_max_drones(SUN_BUFF_MAX_DRONES)
			swarm.kill_all_and_respawn()
		if("Walnut" in bufferName.name):
			swarm.set_max_drones(WALNUT_BUFF_MAX_DRONES)
			swarm.kill_all_and_respawn()
		if("Maw" in bufferName.name):
			isMawBuffed = true
			swarm.set_maw_buffed(true)
			swarm.kill_all_and_respawn()
		isBuffed = true
		thisBufferName = bufferName.name


func debuff():
	if("EggWorm" in thisBufferName):
		for drone in swarm.get_available_drones():
			drone.regularDamage()
	if("Peashooter" in thisBufferName):
		for drone in swarm.get_available_drones():
			drone.makeNotExplode()
	if("Sunflower" in thisBufferName):
		swarm.set_respawn_wait_time(waitTime)
	isBuffed = false


func die():
	swarm.kill_all_drones()
	PlantManager.clear_space(self.global_position)
	buffNodes.clearBuffs()
	queue_free()


func die_fromClearSpace():
	swarm.kill_all_drones()
	buffNodes.clearBuffs()
	queue_free()


func _on_play_anim_timer_timeout() -> void:
	pass


func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSprite2D.visible = false
	$PreviewNodes.visible = true


func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false
