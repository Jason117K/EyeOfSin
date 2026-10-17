extends Control

@export var mana_per_charge := 1000
# Gap between the last demon card and the bar.
const CARD_ROW_GAP := 4.0
@onready var empty_charge_texture := load("res://_UI/UltCharge_Empty.png")
@onready var full_charge_texture := load("res://_UI/UltCharge_Full.png")
@onready var charge_progress_bar : ProgressBar = $UltimateMarginContainer/UltimateVboxContainer/UltimateChargeProgressBar
@onready var all_charges_panel_container := $UltimateMarginContainer/UltimateVboxContainer/AllChargesPanelContainer
@onready var charge_1 := $UltimateMarginContainer/UltimateVboxContainer/AllChargesPanelContainer/MarginContainer/AllChargeHboxContainer/Charge1
@onready var charge_2 := $UltimateMarginContainer/UltimateVboxContainer/AllChargesPanelContainer/MarginContainer/AllChargeHboxContainer/Charge2
@onready var charge_3 := $UltimateMarginContainer/UltimateVboxContainer/AllChargesPanelContainer/MarginContainer/AllChargeHboxContainer/Charge3
@onready var charge_4 := $UltimateMarginContainer/UltimateVboxContainer/AllChargesPanelContainer/MarginContainer/AllChargeHboxContainer/Charge4
@onready var ultimate_vbox_container := $UltimateMarginContainer/UltimateVboxContainer
@onready var ultimate_margin_container : MarginContainer = $UltimateMarginContainer
var current_mana := 0
var charges := 0
var max_charges := 4
var is_enabled := true

# Clicking a charge arms the ult (Global.ultimate_is_ready); the charge is only
# spent when a demon actually fires it (Global.un_ready_ultimate).
signal ultimate_bar_clicked

@onready var all_charges :Array[TextureButton]= [charge_1,charge_2,charge_3,charge_4]

func _ready() -> void:
	#disable_ult()
	self.hide()
	set_process(false)
	all_charges_panel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	charge_progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ultimate_margin_container.remove_theme_constant_override("margin_left")
	Global.ultimate_charge_container = self
	for charge in all_charges:
		charge.pressed.connect(ready_ultimate)
	refresh_charges()
	set_progress_bar_value(current_mana)

# The card row changes width as levels and tutorials show cards, and on a
# dimension swap, so the bar follows it every frame while shown.
func _process(_delta: float) -> void:
	set_margin()

# Cancel an armed ult without spending the charge.
func _input(event: InputEvent) -> void:
	if not Global.ultimate_is_ready:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		disarm_ultimate()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		disarm_ultimate()
		get_viewport().set_input_as_handled()

func add_mana(mana_to_add : float)->void:
	#print("GLOBAL Add Mana : ", mana_to_add)
	if is_enabled:

		current_mana = current_mana + mana_to_add
		#print("GLOBAL Ult Is Enabled Should Add, Current Mana : ", current_mana)
		#print("GLOBAL Ult Is Enabled Should Add, mana_per_charge : ", mana_per_charge)
		if current_mana >= mana_per_charge:
			#print("GLOBAL Current Mana is ", current_mana)
			if charges < max_charges:
				#print("GLOBAL Increasing Ultimate Charge")
				increase_ultimate_charges()
				current_mana = 0
		set_progress_bar_value(current_mana)

func increase_ultimate_charges()->void:
	if is_enabled and charges < max_charges:
		charges = charges + 1
		refresh_charges()

# Full textures for the charges held, empty for the rest.
func refresh_charges()->void:
	for i in all_charges.size():
		all_charges[i].texture_normal = full_charge_texture if i < charges else empty_charge_texture

func ready_ultimate()->void:
	if not is_enabled:
		return
	if Global.ultimate_is_ready:
		# Clicking the bar again while armed cancels.
		disarm_ultimate()
		return
	if charges > 0:
		Global.ultimate_is_ready = true
		UiFx.add_pulsing_button_highlight(all_charges_panel_container)
		ultimate_bar_clicked.emit()

func disarm_ultimate()->void:
	Global.ultimate_is_ready = false
	UiFx.remove_pulsing_button_highlight(all_charges_panel_container)

# Called through Global.un_ready_ultimate() when a demon fires the ult.
func un_ready_ultimate()->void:
	UiFx.remove_pulsing_button_highlight(all_charges_panel_container)
	charges = maxi(charges - 1, 0)
	refresh_charges()

# Every level starts with no charges and an empty bar.
func reset_charges()->void:
	disarm_ultimate()
	charges = 0
	current_mana = 0
	refresh_charges()
	set_progress_bar_value(current_mana)

func set_progress_bar_value(new_progress_bar_value : float)->void:
	charge_progress_bar.value = (new_progress_bar_value / mana_per_charge) * 100
	#print("GLOBAL Charge Progress Value is ", charge_progress_bar.value )

# Hidden, not faded: a transparent bar still took clicks meant for the cards.
func disable_ult()->void:
	#print("GLOBAL-Ult Ult Disabled")
	is_enabled = false
	disarm_ultimate()
	hide()
	set_process(false)
	for charge in all_charges:
		charge.mouse_filter = Control.MOUSE_FILTER_IGNORE

func enable_ult()->void:
	#print("GLOBAL-Ult Ult Enabled")
	is_enabled = true
	modulate = Color(1,1,1,1)
	show()
	set_process(true)
	set_margin()
	for charge in all_charges:
		charge.mouse_filter = Control.MOUSE_FILTER_STOP

# Places the bar just right of the active dimension's last visible demon card,
# top-aligned with the card row. Only positions; enable/disable_ult own visibility.
func set_margin()->void:
	var menu = _get_active_menu()
	if menu == null:
		return
	var row : Rect2 = menu.get_card_row_rect()
	if row.size == Vector2.ZERO:
		return
	var canvas_target := Vector2(row.end.x + CARD_ROW_GAP, row.position.y)
	var target := get_global_transform_with_canvas().affine_inverse() * canvas_target
	if not ultimate_margin_container.position.is_equal_approx(target):
		ultimate_margin_container.position = target

# The visible menu belongs to the active dimension (swap hides the other one).
func _get_active_menu() -> Control:
	for menu in Global.demon_selection_menus:
		if is_instance_valid(menu) and menu.is_visible_in_tree():
			return menu
	return null
