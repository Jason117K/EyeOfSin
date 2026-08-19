extends Demon
#SpinalOcculum.gd

# --- Exports ---

@export_category("Buffed Health")
@export var occulum_buffed_health := 850
@export var occulum_buffed_max_health := 800
@export var occulum_buffed_health_regen := 0.1
@export var wyrm_buffed_health := 850
@export var wyrm_buffed_max_health := 800
@export var wyrm_buffed_health_regen := 0.1
@export var maw_buffed_health := 850
@export var maw_buffed_max_health := 800
@export var maw_buffed_health_regen := 0.1


@export_category("Buff Parameters")
@export var lightning_damage := 10
@export var blood_spawn_time := 5
@export var spike_damage := 20

@export_category("Ultimate Parameters")
@export var mana_add_on_block_damage := 100 

# --- Preloads ---
var bloodScene := preload("res://_Entities/Demons/Blood/Blood.tscn")

# --- Component References ---
@onready var web := $Web
@onready var spike_rock := $SpikeRock
@onready var silence_field := $SilenceField
@onready var maw_lightning := $LightningCrackle
@onready var rib_buff_area := $RibBuffArea
@onready var blood_rib := $BloodRib

@onready var blood_rib_collision := $BloodRibCollision

# --- State ---
var can_damage_zombie := false
var is_lightning_maw_buff := false

signal spinal_occulum_buff_unlocked(buff_to_unlock:String)

# --- Lifecycle ---

func _ready() -> void:
	super()
	current_demon_type = Global.DEMON_TYPE.SPINAL_OCCULUM
	blood_rib.hide()
	spinal_occulum_buff_unlocked.connect(Global.unlock_buff)
	_init_collision_mask(rib_buff_area,false)

	
	hide_old_preview()
	
	all_synergies = Global.all_spinalocculum_synergies
	special_description_file = get_special_description_file(all_synergies,"Base")

func hide_old_preview()->void:
	$PreviewNodes/PreviewCard.visible = false 
	$PreviewNodes/PreviewCardSprite.visible = false 
	$PreviewNodes/PreviewCardShadow.visible = false 
	

# --- Getters ---

func get_demon_true_name() -> String:
	return "SpinalOcculum"

func get_demon_name() -> String:
	return "SPINAL OCCULUM"

func get_cost() -> float:
	return cost

func get_damage() -> String:
	return "NONE"

func get_lightning_damage() -> int:
	return lightning_damage


# --- Buff System ---
func baal_buff()->void:
	super()
	baal_halo.play("top_glow")
	
	
func receive_buff(bufferName:Demon) -> void:
	var demonName : String = (bufferName.get_demon_true_name())
	if !isBuffed:
		unlock_new_buff(demonName)
		super(demonName)
		match demonName:
			"Occulum":
				blood_rib.show()
				blood_rib_collision.disabled = false


			"Crawler":
				if self.is_in_group("Green"):
					web.add_to_group("Green")
				else:
					web.add_to_group("Purple")
				web.activate()
			"SpinalOcculum":
				pass
			"Wyrm":
				spike_rock.activate()
			"Hive":
				silence_field.activate()
			"Maw":
				lightning_maw_buff()

func debuff() -> void:
	super()
	silence_field.deactivate()
	spike_rock.deactivate()
	web.deactivate()
	undo_lightning_maw_buff()

func unlock_new_buff(demonName:String)->void:
	if isBuffed == false:
		if Global.game_controller.current_scenes.size()>1:
			if demonName != get_demon_true_name():
				spinal_occulum_buff_unlocked.emit(SynergyDefinition.make_id(demonName, get_demon_true_name()))



func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Global.ultimate_is_ready:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if spawn_done:
				trigger_ultimate()
	else:
		super(_viewport,event,_shape_idx)
			#add_ellipse(event.position)
	
func trigger_ultimate()->void:
	#print("Trigger Spine Ult")
	Global.un_ready_ultimate()
	for demon in rib_buff_area.get_overlapping_areas():
		if demon.is_in_group("Demons"):
			demon.rib_shield()


	

# --- Death ---

func _cleanup() -> void:
	# No extra cleanup beyond base buffNodes
	super()


# --- Lightning (Maw Buff) ---

func lightning_maw_buff() -> void:
	maw_lightning.play()
	maw_lightning.show()
	is_lightning_maw_buff = true

func undo_lightning_maw_buff() -> void:
	maw_lightning.stop()
	maw_lightning.hide()
	is_lightning_maw_buff = false
	
# --- Slow Field ---

func _on_area_2d_area_entered(this_area: Area2D) -> void:
	if this_area.is_in_group("Zombie"):
		this_area.slow()


# --- Preview ---

func _on_mouse_entered() -> void:
	super()
	#print(self.global_position)

func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false
