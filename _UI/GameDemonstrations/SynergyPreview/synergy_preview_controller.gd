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
	6: 4,
	4: 6,
	2: 5,
	7: 5,
	1: 5,
}
# Slot index for demon_b_name (matches DemonPosition1–7). Tune per demon.
const DEMON_SLOT_B := {
	"Occulum": 6,
	"Crawler": 4,
	"SpinalOcculum": 2,
	"Wyrm": 4,
	"Hive": 1,
	"Maw": 7,
}

# Map Slot 5B to 4A, 4B to 5A, 3B to 6A, 7B to 6A, 1B to 5A 
#const PreviewZombieScene = preload("res://_UI/GameDemonstrations/SynergyPreview/preview_zombie.tscn")
#var AltPreviewZombieScene := preload("res://_Entities/Zombies/_RebornZombie/BasicZombie.tscn")

const LANE_Y := [68, 100, 132]
const SPAWN_X := 200

const DEFAULT_ZOMBIE_CONFIG := [{"type": "Unhallower", "lane": 1}]

const SYNERGY_ZOMBIE_CONFIGS := {
	"Occulum+Maw":            [{"type": "Unhallower", "lane": 1}],
	"Occulum+Hive":           [],
	"Occulum+Crawler":        [{"type": "Reborn", "lane": 1}, \
								{"type": "Unhallower", "lane": 1, "x_offset": 45}],
	"Occulum+SpinalOcculum":  [],
	"Occulum+Wyrm":           [{"type": "Reborn", "lane": 1}, \
								{"type": "Reborn", "lane": 1, "x_offset": 30}],

	"Crawler+Hive":           [{"type": "Reborn", "lane": 1}, 
								{"type": "Reborn", "lane": 2},
									{"type": "Reborn", "lane": 0}],
	"Crawler+Maw":            [{"type": "Unhallower", "lane": 1, "x_offset": 30}],
	"Crawler+Occulum":        [{"type": "Reborn", "lane": 1}],
	"Crawler+SpinalOcculum":  [{"type": "Unhallower", "lane": 1}],
	"Crawler+Wyrm":           [{"type": "Unhallower", "lane": 1, "x_offset": 55}, 
								{"type": "Reborn", "lane": 2, "x_offset": 60},
									{"type": "Reborn", "lane": 0,"x_offset": 55}],

	"SpinalOcculum+Occulum":  [{"type": "Unhallower", "lane": 1}],
	"SpinalOcculum+Hive":     [{"type": "Sundered", "lane": 1}],
	"SpinalOcculum+Maw":      [{"type": "Reborn", "lane": 1}],
	"SpinalOcculum+Crawler":  [{"type": "Unhallower", "lane": 1}, \
								{"type": "Reborn", "lane": 1, "x_offset": 32},
								{"type": "Reborn", "lane": 1, "x_offset": 64}],
	"SpinalOcculum+Wyrm":     [{"type": "Reborn", "lane": 1}, \
								{"type": "Reborn", "lane": 1, "x_offset": 25}, \
								{"type": "Reborn", "lane": 1, "x_offset": 50}],

	"Wyrm+Occulum":           [{"type": "Reborn", "lane": 1},
								{"type": "Reborn", "lane": 1, "x_offset": 16},
								{"type": "Reborn", "lane": 1, "x_offset": 32},
								{"type": "Reborn", "lane": 1, "x_offset": 48},
								{"type": "Reborn", "lane": 1, "x_offset": 64}],
								
	"Wyrm+Hive":              [{"type": "Reborn", "lane": 1, "x_offset": 150}, \
								{"type": "Reborn", "lane": 1, "x_offset": 180}, \
								{"type": "Unhallower", "lane": 1, "x_offset": 220}],
								
	"Wyrm+Maw":               [{"type": "Reborn", "lane": 1,  "x_offset": 64}, \
								{"type": "Reborn", "lane": 0,  "x_offset": 64}, \
								{"type": "Reborn", "lane": 2,  "x_offset": 64}, \
								{"type": "Reborn", "lane": 1,  "x_offset": 96}],
								
	"Wyrm+Crawler":           [{"type": "Reborn", "lane": 1},
								{"type": "Reborn", "lane": 1, "x_offset": 16},
								{"type": "Reborn", "lane": 1, "x_offset": 32},
								{"type": "Reborn", "lane": 1, "x_offset": 48},
								{"type": "Reborn", "lane": 1, "x_offset": 64}],
								
	"Wyrm+SpinalOcculum":     [{"type": "Reborn", "lane": 1},
								{"type": "Reborn", "lane": 1, "x_offset": 16},
								{"type": "Reborn", "lane": 1, "x_offset": 32},
								{"type": "Reborn", "lane": 1, "x_offset": 48},
								{"type": "Reborn", "lane": 1, "x_offset": 64}],

	"Hive+Maw":               [{"type": "Reborn", "lane": 1, "x_offset": 0} , 
								{"type": "Reborn", "lane": 1, "x_offset": 16}],
	"Hive+Crawler":           [{"type": "Unhallower", "lane": 1, "x_offset": 64} , \
								{"type": "Reborn", "lane": 1, "x_offset": 96} , \
								{"type": "Reborn", "lane": 1, "x_offset": 96}],
	"Hive+Occulum":           [{"type": "Unhallower", "lane": 1, "x_offset": 64}],
	"Hive+SpinalOcculum":     [{"type": "Unhallower", "lane": 1, "x_offset": 64}],
	"Hive+Wyrm":              [{"type": "Unhallower", "lane": 1, "x_offset": 64}],

	"Maw+Hive":               [{"type": "Unhallower", "lane": 1},
								{"type": "Reborn", "lane": 0, "x_offset": 64}, \
								{"type": "Reborn", "lane": 2, "x_offset": 64}, \
								{"type": "Reborn", "lane": 1, "x_offset": 96}, \
								{"type": "Reborn", "lane": 1, "x_offset": 106}, \
								{"type": "Reborn", "lane": 1, "x_offset": 116}],
								
	"Maw+Crawler":            [{"type": "Unhallower", "lane": 1}, \
								{"type": "Reborn", "lane": 0, "x_offset": 64}, \
								{"type": "Reborn", "lane": 1, "x_offset": 64}, \
								{"type": "Reborn", "lane": 2, "x_offset": 64}, \
								{"type": "Reborn", "lane": 0, "x_offset": 96}, \
								{"type": "Reborn", "lane": 1, "x_offset": 96}, \
								{"type": "Reborn", "lane": 2, "x_offset": 96}],
								
	"Maw+Occulum":            [{"type": "Unhallower", "lane": 1}],
	"Maw+SpinalOcculum":      [{"type": "Unhallower", "lane": 1}],
	"Maw+Wyrm":               [{"type": "Unhallower", "lane": 1},\
								{"type": "Reborn", "lane": 0, "x_offset": 64}, \
								{"type": "Reborn", "lane": 1, "x_offset": 64}, \
								{"type": "Reborn", "lane": 2, "x_offset": 64}, \
								{"type": "Reborn", "lane": 0, "x_offset": 96}, \
								{"type": "Reborn", "lane": 1, "x_offset": 96}, \
								{"type": "Reborn", "lane": 2, "x_offset": 96}],
}

@export var demon_a_name := "Occulum"
@export var demon_b_name := "Crawler"
@export var respawn_timer_wait_time := 6.0

var demon_a_instance: Node
var demon_b_instance: Node
var preview_zombies: Array = []
var zombies_alive: int = 0

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var preview_world: Node2D = $SubViewportContainer/SubViewport/PreviewWorld
@onready var demon_receiving_buff_slot_a: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonReceivingBuffSlot
@onready var demon_giving_buff_slot_b: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonGivingBuffSlot
@onready var demon_slot_1: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition1
@onready var demon_slot_2: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition2
@onready var demon_slot_3: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition3
@onready var demon_slot_4: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition4
@onready var demon_slot_5: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition5
@onready var demon_slot_6: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition6
@onready var demon_slot_7: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition7
@onready var demon_slot_8: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition8
@onready var demon_slot_9: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/DemonPosition9

@onready var all_demon_slots := [demon_slot_1,demon_slot_2,demon_slot_3,demon_slot_4,demon_slot_5,demon_slot_6,demon_slot_7]

@onready var zombie_spawn: Node2D = $SubViewportContainer/SubViewport/PreviewWorld/ZombieSpawnPoint
@onready var buff_timer: Timer = $BuffTimer

@onready var slot_b := demon_slot_1
@onready var slot_a := demon_slot_1

@onready var respawn_zombie_timer := $RespawnZombieTimer

var maw_adjust_offset := Vector2(0,0)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	#custom_minimum_size = Vector2(200, 200)
	buff_timer.wait_time = 0.5
	buff_timer.one_shot = true
	buff_timer.timeout.connect(_apply_buffs)
	respawn_zombie_timer.one_shot = true
	respawn_zombie_timer.wait_time = respawn_timer_wait_time
	respawn_zombie_timer.timeout.connect(reset_scene)



func setup(a_name: String, b_name: String) -> void:
	clear_preview()
	demon_a_name = a_name
	demon_b_name = b_name
	_spawn_demons()
	_spawn_zombies()
	buff_timer.start()

func clear_preview() -> void:
	for zombie in preview_zombies:
		if is_instance_valid(zombie):
			zombie.queue_free()
	preview_zombies.clear()
	zombies_alive = 0
	if slot_b != null:
		for child in slot_b.get_children():
			if child.has_method("die"):
				child.die()
			else:
				child.queue_free()
	if slot_a != null:
		for child in slot_a.get_children():
			if child.has_method("die"):
				child.die()
			else:
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
	var scene_a := load(DEMON_SCENES[demon_a_name])
	var scene_b := load(DEMON_SCENES[demon_b_name])
	demon_a_instance = scene_a.instantiate()
	demon_b_instance = scene_b.instantiate()
	demon_a_instance.add_to_group("Purple")
	demon_b_instance.add_to_group("Purple")
	print(demon_b_instance , " Demon B is ", demon_b_name)
	print(demon_a_instance , " Demon A is ", demon_a_name)

	# B: from demon name → slot number → node
	var slot_b_number := get_slot_b_number(demon_b_name)
	slot_b = get_slot_node(slot_b_number)
	# A: from B's slot number → paired A slot → node
	var slot_a_number := get_slot_a_number_from_b(slot_b_number)
	slot_a = get_slot_node(slot_a_number)

	demon_a_instance.hide_preview()
	demon_b_instance.hide_preview()
	
	if slot_b:
		slot_b.add_child(demon_b_instance)
	if slot_a:
		slot_a.add_child(demon_a_instance)
	demon_a_instance.position = Vector2.ZERO
	demon_b_instance.position = Vector2.ZERO
	demon_a_instance.set_spawn_anim_speed(20)
	demon_b_instance.set_spawn_anim_speed(20)
	if demon_b_name == "Maw":
		demon_b_instance.animSpriteComp.position = demon_b_instance.animSpriteComp.position - Vector2(256,256)
		for node in demon_b_instance.get_out_of_place_nodes():
			node.position = node.position - Vector2(256,256)
		for tentacle in demon_b_instance.get_tentacles():
			tentacle.position = tentacle.position - Vector2(256,256)

	if demon_a_name == "Maw":
		demon_a_instance.set_demo_digest()
		if demon_b_name == "Occulum":
			maw_adjust_offset = Vector2(16,0)
		demon_a_instance.animSpriteComp.position = demon_a_instance.animSpriteComp.position - Vector2(256,256) + maw_adjust_offset
		for node in demon_a_instance.get_out_of_place_nodes():
			node.position = node.position - Vector2(256,256) + maw_adjust_offset 
		for tentacle in demon_a_instance.get_tentacles():
			tentacle.position = tentacle.position - Vector2(256,256) + maw_adjust_offset
	
	if demon_a_name == "Hive":
		demon_a_instance.set_is_demo()

	
	if demon_a_name == "Occulum":
		demon_a_instance.demo_blood_pickup()
		
func _get_zombie_config() -> Array:
	var key := demon_a_name + "+" + demon_b_name
	if SYNERGY_ZOMBIE_CONFIGS.has(key):
		return SYNERGY_ZOMBIE_CONFIGS[key]
	return DEFAULT_ZOMBIE_CONFIG

func _spawn_zombies() -> void:
	var config := _get_zombie_config()
	zombies_alive = config.size()
	for entry in config:
		var zombie_type: String = entry.get("type", "Unhallower")
		var lane: int = entry.get("lane", 1)
		var x_offset: int = entry.get("x_offset", 0)

		if not ZombieRegistry.SCENES.has(zombie_type):
			push_warning("SynergyPreview: unknown zombie type '%s'" % zombie_type)
			zombies_alive -= 1
			continue

		var zombie = ZombieRegistry.SCENES[zombie_type].instantiate()
		zombie.add_to_group("Purple")
		zombie.make_demo()
		zombie.zombie_death.connect(_on_zombie_died)
		preview_world.add_child(zombie)

		if Global.is_on_purple_dimension():
			zombie.set_hue_shift(-86)
		else:
			zombie.set_hue_shift(125)

		zombie.position = Vector2(SPAWN_X + x_offset, LANE_Y[lane])
		preview_zombies.append(zombie)

func reset_scene() -> void:
	#clear_preview()
	setup(demon_a_name,demon_b_name)


func _on_zombie_died() -> void:
	zombies_alive -= 1
	if zombies_alive <= 0:
		respawn_zombie_timer.start()

func _apply_buffs() -> void:
	pass
	if demon_a_instance and demon_a_instance.has_method("receive_buff"):
		demon_a_instance.receive_buff(demon_b_instance)
	#if demon_b_instance and demon_b_instance.has_method("receive_buff"):
		#demon_b_instance.receive_buff(demon_a_instance)
