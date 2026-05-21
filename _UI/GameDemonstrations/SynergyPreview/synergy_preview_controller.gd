extends CenterContainer

const DEMON_SCENES := {
	"Occulum": "res://_Entities/Demons/_Occulum/Occulum.tscn",
	"Crawler": "res://_Entities/Demons/_Crawler/Crawler.tscn",
	"SpinalOcculum": "res://_Entities/Demons/_CagedOculum/SpinalOcculum.tscn",
	"Wyrm": "res://_Entities/Demons/_Wyrm/Wyrm.tscn",
	"Hive": "res://_Entities/Demons/_Hive/Hive.tscn",
	"Maw": "res://_Entities/Demons/_Maw/Maw.tscn",
}

# Slot index for demon_a_name (matches DemonPosition1–7). Tune per demon.
#const DEMON_SLOT_A := {
	#"Occulum": 1,
	#"Crawler": 1,
	#"SpinalOcculum": 1,
	#"Wyrm": 1,
	#"Hive": 1,
	#"Maw": 1,
#}
const SLOT_B_TO_SLOT_A := {
	5: 4,
	4: 5,
	2: 5,
	7: 6,
	1: 5,
}
# Slot index for demon_b_name (matches DemonPosition1–7). Tune per demon.
const DEMON_SLOT_B := {
	"Occulum": 5,
	"Crawler": 4,
	"SpinalOcculum": 2,
	"Wyrm": 4,
	"Hive": 1,
	"Maw": 7,
}

# Map Slot 5B to 4A, 4B to 5A, 3B to 6A, 7B to 6A, 1B to 5A 
#const PreviewZombieScene = preload("res://_UI/GameDemonstrations/SynergyPreview/preview_zombie.tscn")
#var AltPreviewZombieScene := preload("res://_Entities/Zombies/_RebornZombie/BasicZombie.tscn")

var current_zombie_scene: PackedScene = ZombieRegistry.SCENES["Unhallower"]

@export var demon_a_name := "Occulum"
@export var demon_b_name := "Crawler"

var demon_a_instance: Node
var demon_b_instance: Node
var preview_zombie: Node

@onready var sub_viewport : SubViewport = $SubViewportContainer/SubViewport
@onready var preview_world : Node2D = $SubViewportContainer/SubViewport/PreviewWorld
@onready var demon_receiving_buff_slot_a : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonReceivingBuffSlot
@onready var demon_giving_buff_slot_b : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonGivingBuffSlot
@onready var demon_slot_1 : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition1
@onready var demon_slot_2 : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition2
@onready var demon_slot_3 : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition3
@onready var demon_slot_4 : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition4
@onready var demon_slot_5 : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition5
@onready var demon_slot_6 : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition6
@onready var demon_slot_7 : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition7
@onready var demon_slot_8 : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition8
@onready var demon_slot_9 : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition9

@onready var all_demon_slots := [demon_slot_1,demon_slot_2,demon_slot_3,demon_slot_4,demon_slot_5,demon_slot_6,demon_slot_7]

@onready var zombie_spawn : Node2D = $SubViewportContainer/SubViewport/PreviewWorld/ZombieSpawnPoint
@onready var buff_timer : Timer = $BuffTimer

@onready var slot_b = demon_slot_1
@onready var slot_a = demon_slot_1

@onready var respawn_zombie_timer := $RespawnZombieTimer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	#custom_minimum_size = Vector2(200, 200)
	buff_timer.wait_time = 0.5
	buff_timer.one_shot = true
	buff_timer.timeout.connect(_apply_buffs)
	respawn_zombie_timer.one_shot = true 
	respawn_zombie_timer.timeout.connect(reset_scene)



func setup(a_name: String, b_name: String) -> void:
	clear_preview()
	demon_a_name = a_name
	demon_b_name = b_name
	_spawn_demons()
	_spawn_zombie()
	buff_timer.start()

func clear_preview():
	if preview_zombie != null:
		preview_zombie.queue_free()
	for child in slot_b.get_children():
		child.queue_free()
	for child in slot_a.get_children():
		child.queue_free()
		
func get_slot_b_number(demon_name: String) -> int:
	if not DEMON_SLOT_B.has(demon_name):
		push_warning("SynergyPreview: no B slot for '%s'" % demon_name)
		return -1
	return DEMON_SLOT_B[demon_name]
	
func get_slot_a_number_from_b(slot_b: int) -> int:
	if not SLOT_B_TO_SLOT_A.has(slot_b):
		push_warning("SynergyPreview: no A slot derived from B slot %d" % slot_b)
		return -1
	return SLOT_B_TO_SLOT_A[slot_b]
	
func get_slot_node(slot_number: int) -> Node2D:
	var index := slot_number - 1
	if index < 0 or index >= all_demon_slots.size():
		push_warning("SynergyPreview: invalid slot %d" % slot_number)
		return null
	return all_demon_slots[index]

func _spawn_demons() -> void:
	if not DEMON_SCENES.has(demon_a_name) or not DEMON_SCENES.has(demon_b_name):
		return
	var scene_a = load(DEMON_SCENES[demon_a_name])
	var scene_b = load(DEMON_SCENES[demon_b_name])
	demon_a_instance = scene_a.instantiate()
	demon_b_instance = scene_b.instantiate()
	demon_a_instance.add_to_group("Purple")
	demon_b_instance.add_to_group("Purple")
	print(demon_b_instance , " Demon B is ", demon_b_name)

	# B: from demon name → slot number → node
	var slot_b_number := get_slot_b_number(demon_b_name)
	slot_b = get_slot_node(slot_b_number)
	# A: from B's slot number → paired A slot → node
	var slot_a_number := get_slot_a_number_from_b(slot_b_number)
	slot_a = get_slot_node(slot_a_number)

	if slot_b:
		slot_b.add_child(demon_b_instance)
	if slot_a:
		slot_a.add_child(demon_a_instance)
	demon_a_instance.position = Vector2.ZERO
	demon_b_instance.position = Vector2.ZERO
	demon_a_instance.set_anim_spawn_speed_mult(2)
	demon_b_instance.set_anim_spawn_speed_mult(2)
	if demon_b_name == "Maw":
		demon_b_instance.animSpriteComp.position = demon_b_instance.animSpriteComp.position - Vector2(256,256)
		demon_b_instance.get_preview_nodes().position = demon_b_instance.get_preview_nodes().position- Vector2(256,256)

	if demon_a_name == "Maw":
		demon_a_instance.animSpriteComp.position = demon_a_instance.animSpriteComp.position - Vector2(256,256)
		demon_a_instance.get_preview_nodes().position = demon_a_instance.get_preview_nodes().position- Vector2(256,256)
		
func _spawn_zombie() -> void:
	preview_zombie = current_zombie_scene.instantiate()
	preview_zombie.add_to_group("Purple")      

	preview_zombie.make_demo() 
	preview_zombie.zombie_death.connect(_respawn_zombie)
	#preview_zombie.set_collision_layer_value(4, true)   
	preview_world.add_child(preview_zombie)
	if Global.is_on_purple_dimension():
		preview_zombie.set_hue_shift(-86)
	else:
		preview_zombie.set_hue_shift(125)
	
	preview_zombie.position = zombie_spawn.position

func reset_scene():
	#clear_preview()
	setup(demon_a_name,demon_b_name)


func _respawn_zombie():
	respawn_zombie_timer.start()

func _apply_buffs() -> void:
	if demon_a_instance and demon_a_instance.has_method("receive_buff"):
		demon_a_instance.receive_buff(demon_b_instance)
	if demon_b_instance and demon_b_instance.has_method("receive_buff"):
		demon_b_instance.receive_buff(demon_a_instance)
