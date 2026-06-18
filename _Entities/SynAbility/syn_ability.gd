extends Node

@export var syn_ability_instance :PackedScene = preload("res://_Entities/SynAbility/syn_lightning_ability_bolt.tscn")
@export var icon_texture := preload("res://_Entities/SynAbility/SynShieldCard.png")
@export var charge_boost_multipler := 4.0

@onready var syn_ability_cooldown := $SynAbilityCooldown
@onready var syn_ability_crosshair : AnimatedSprite2D = $SynAbilityCrosshair
@onready var syn_ability_button := $SynAbilityCooldown/SynAbilityPanelContainer/MarginContainer/HBoxContainer/SynAbilityButton

enum ChargeState { READY, ACTIVE, COOLDOWN }

# One charge per dimension ("Purple" / "Green"), sharing a single card + bar.
# Cooldown is driven by an accumulator advanced every frame in _process by
# (delta * rate). The recharge rate is recomputed fresh each frame from game
# state, so there is no stored "speed multiplier" to desync and no Timer being
# restarted to fake a variable clock rate.
#   READY    -> can cast
#   ACTIVE   -> an instance is deployed in the world (its own death_timer runs)
#   COOLDOWN -> instance gone, recharging; READY again when cooldown_left hits 0
var charges := {
	"Purple": {"state": ChargeState.READY, "instance": null, "cooldown_left": 0.0, "cooldown_duration": 0.0},
	"Green":  {"state": ChargeState.READY, "instance": null, "cooldown_left": 0.0, "cooldown_duration": 0.0},
}

var syn_crosshair_active := false

func _ready() -> void:
	syn_ability_cooldown.get_button().pressed.connect(set_ability_targeting_active)
	syn_ability_crosshair.hide()
	syn_ability_cooldown.set_icon(icon_texture)
	Global.register_syn_ability_manager(self)

func set_icon(new_texture:Texture2D)->void:
	icon_texture = new_texture
	syn_ability_cooldown.set_icon(icon_texture)
	syn_ability_cooldown.show()

func get_icon()->Texture:
	return icon_texture

func get_syn_button()->Control:
	return syn_ability_button

func set_syn_ability(new_syn_ability)->void:
	syn_ability_instance = new_syn_ability

func set_syn_ability_icon(new_icon_texture:CompressedTexture2D)->void:
	icon_texture = new_icon_texture

func set_ability_targeting_active()->void:
	syn_crosshair_active = true
	syn_ability_crosshair.show()

# --- Charge helpers -------------------------------------------------

func _current_color() -> String:
	return "Purple" if Global.is_on_purple_dimension() else "Green"

func _other_color(color: String) -> String:
	return "Green" if color == "Purple" else "Purple"

func can_cast(color: String) -> bool:
	return charges[color]["state"] == ChargeState.READY

# --- Per-frame (frozen automatically while the tree is paused) -------

func _process(delta: float) -> void:
	_update_crosshair()
	_tick_cooldowns(delta)
	syn_ability_cooldown.set_progress_bar(_bar_percent())

func _update_crosshair() -> void:
	if syn_crosshair_active:
		syn_ability_crosshair.global_position = get_viewport().get_mouse_position()
	else:
		syn_ability_crosshair.hide()

func _tick_cooldowns(delta: float) -> void:
	for color in charges:
		var charge = charges[color]
		if charge["state"] == ChargeState.ACTIVE:
			# Safety net: catch instances removed without routing through
			# deregister_ability_instance (e.g. a scene reset / forced free)
			# so the charge still goes on cooldown rather than locking forever.
			if not is_instance_valid(charge["instance"]):
				_begin_cooldown(color)
			continue
		if charge["state"] != ChargeState.COOLDOWN:
			continue
		# A charge recharges charge_boost_multipler-times faster while the OTHER
		# charge is deployed; otherwise at the normal 1x rate.
		var rate : float = charge_boost_multipler if charges[_other_color(color)]["state"] == ChargeState.ACTIVE else 1.0
		charge["cooldown_left"] = max(0.0, charge["cooldown_left"] - delta * rate)
		if charge["cooldown_left"] == 0.0:
			charge["state"] = ChargeState.READY

func _bar_percent() -> float:
	var charge = charges[_current_color()]
	match charge["state"]:
		ChargeState.ACTIVE:
			# While deployed the bar drains 100 -> 0 over the instance lifetime.
			var inst = charge["instance"]
			if is_instance_valid(inst) and inst.death_timer != null and inst.death_timer.wait_time > 0.0:
				return inst.death_timer.time_left / inst.death_timer.wait_time * 100.0
			return 0.0
		ChargeState.COOLDOWN:
			# While recharging the bar fills 0 -> 100.
			if charge["cooldown_duration"] > 0.0:
				return (1.0 - charge["cooldown_left"] / charge["cooldown_duration"]) * 100.0
			return 100.0
		_:
			return 100.0

# --- Input / casting ------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if syn_crosshair_active:
			var color := _current_color()
			if can_cast(color):
				print(color, " Syn Ability CLICK")
				activate_syn_ability(get_viewport().get_mouse_position())
			syn_crosshair_active = false

func activate_syn_ability(target_pos:Vector2)->void:
	var color := _current_color()
	var new_syn_ability_instance :Node = syn_ability_instance.instantiate()
	new_syn_ability_instance.global_position = target_pos
	new_syn_ability_instance.add_to_group(color)

	var charge = charges[color]
	charge["state"] = ChargeState.ACTIVE
	charge["instance"] = new_syn_ability_instance
	charge["cooldown_duration"] = new_syn_ability_instance.get_ability_cooldown_duration()

	get_parent().get_active_dimension().add_child(new_syn_ability_instance)
	new_syn_ability_instance.global_position = get_parent().get_active_dimension().get_global_mouse_position()
# Called by Global.deregister_syn_ability when an instance dies / is removed.
func deregister_ability_instance(old_ability:Area2D)->void:
	var color := "Purple" if old_ability.is_in_group("Purple") else "Green"
	# Prefer the dying instance's own cooldown duration (it is still valid here,
	# deregister runs before queue_free) so a charge that was registered without
	# going through activate_syn_ability still gets a correct cooldown.
	if is_instance_valid(old_ability) and old_ability.has_method("get_ability_cooldown_duration"):
		charges[color]["cooldown_duration"] = old_ability.get_ability_cooldown_duration()
	_begin_cooldown(color)

func _begin_cooldown(color: String) -> void:
	var charge = charges[color]
	charge["state"] = ChargeState.COOLDOWN
	charge["cooldown_left"] = charge["cooldown_duration"]
	charge["instance"] = null
