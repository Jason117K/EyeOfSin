extends CenterContainer

const DEMON_SCENES := {
	"Occulum": "res://_Entities/Demons/_Occulum/Occulum.tscn",
	"Crawler": "res://_Entities/Demons/_Crawler/Crawler.tscn",
	"SpinalOcculum": "res://_Entities/Demons/_CagedOculum/SpinalOcculum.tscn",
	"Wyrm": "res://_Entities/Demons/_Wyrm/Wyrm.tscn",
	"Hive": "res://_Entities/Demons/_Hive/Hive.tscn",
	"Maw": "res://_Entities/Demons/_Maw/Maw.tscn",
}

const PreviewZombieScene = preload("res://_UI/GameDemonstrations/SynergyPreview/preview_zombie.tscn")

@export var demon_a_name := "Occulum"
@export var demon_b_name := "Crawler"

var demon_a_instance: Node
var demon_b_instance: Node
var preview_zombie: Node

@onready var sub_viewport : SubViewport = $SubViewportContainer/SubViewport
@onready var preview_world : Node2D = $SubViewportContainer/SubViewport/PreviewWorld
@onready var demo_slot_a : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemoSlotA
@onready var demo_slot_b : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemoSlotB
@onready var zombie_spawn : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/ZombieSpawnPoint
@onready var buff_timer : Timer = $BuffTimer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	custom_minimum_size = Vector2(200, 200)
	buff_timer.wait_time = 0.5
	buff_timer.one_shot = true
	buff_timer.timeout.connect(_apply_buffs)
	_spawn_demons()
	_spawn_zombie()
	buff_timer.start()

func setup(a_name: String, b_name: String) -> void:
	demon_a_name = a_name
	demon_b_name = b_name

func _spawn_demons() -> void:
	if not DEMON_SCENES.has(demon_a_name) or not DEMON_SCENES.has(demon_b_name):
		return

	var scene_a = load(DEMON_SCENES[demon_a_name])
	var scene_b = load(DEMON_SCENES[demon_b_name])

	demon_a_instance = scene_a.instantiate()
	demon_b_instance = scene_b.instantiate()
	demon_a_instance.add_to_group("Purple")  
	demon_b_instance.add_to_group("Purple")   
	demo_slot_a.add_child(demon_a_instance)
	demo_slot_b.add_child(demon_b_instance)

	demon_a_instance.position = Vector2.ZERO
	demon_b_instance.position = Vector2.ZERO

func _spawn_zombie() -> void:
	preview_zombie = PreviewZombieScene.instantiate()
	preview_zombie.add_to_group("Purple")             
	#preview_zombie.set_collision_layer_value(4, true)   
	preview_world.add_child(preview_zombie)
	preview_zombie.position = zombie_spawn.position

func _apply_buffs() -> void:
	if demon_a_instance and demon_a_instance.has_method("receive_buff"):
		demon_a_instance.receive_buff(demon_b_instance)
	if demon_b_instance and demon_b_instance.has_method("receive_buff"):
		demon_b_instance.receive_buff(demon_a_instance)
