extends Demon
#SpinalOcculum.gd

# --- Exports ---
@export var lightning_damage := 10

@export var blood_spawn_time := 5
@export var occulum_buffed_health := 850
@export var occulum_buffed_max_health := 800
@export var occulum_buffed_health_regen := 0.1
@export var maw_buffed_health := 850
@export var maw_buffed_max_health := 800
@export var maw_buffed_health_regen := 0.1

@export var spike_damage := 20

# --- Preloads ---
var bloodScene := preload("res://_Entities/Demons/Blood/Blood.tscn")

# --- Component References ---
@onready var web := $Web
@onready var spike_rock := $SpikeRock
@onready var silence_field := $SilenceField
@onready var maw_lightning := $LightningCrackle

# --- State ---
var can_damage_zombie := false
var is_lightning_maw_buff := false


# --- Lifecycle ---

func _ready() -> void:
	super()


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
	
	
func receive_buff(bufferName) -> void:
	var demonName : String = (bufferName.get_demon_true_name())
	if !isBuffed:
		super(demonName)
		match demonName:
			"Occulum":
				pass
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
	healthComp.debuff()
	super()

func get_demon_icon() -> CompressedTexture2D:
	return Global.spinal_occulum_icon

func get_special_description() -> String:
	return Global.spinal_occulum_special_description


# --- Death ---

func _cleanup() -> void:
	# No extra cleanup beyond base buffNodes
	super()


# --- Lightning (Maw Buff) ---

func lightning_maw_buff() -> void:
	maw_lightning.play()
	maw_lightning.show()
	is_lightning_maw_buff = true


# --- Slow Field ---

func _on_area_2d_area_entered(this_area: Area2D) -> void:
	if this_area.is_in_group("Zombie"):
		this_area.slow()


# --- Preview ---

func _on_mouse_entered() -> void:
	$PreviewNodes/AnimatedSpriteComponent2.visible = false
	$PreviewNodes.visible = true

func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false
