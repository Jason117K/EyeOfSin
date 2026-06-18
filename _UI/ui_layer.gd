extends Control

@export var make_green := false

@onready var blood_label := $HUD_Panel/MarginContainer/HUD_HBox/Blood_VBox/BloodAmountLabel
@onready var health_label := $HUD_Panel/MarginContainer/HUD_HBox/Health_VBox/HealthAmountLabel
@onready var health_icon :TextureRect = $HUD_Panel/MarginContainer/HUD_HBox/Health_VBox/Health_Icon

@onready var new_zombie_unlocked_button : Button = $ZombieUnlockedButton
@onready var new_zombie_icon : TextureRect = $ZombieUnlockedButton/NewUnlock_Panel/MarginContainer/NewUnlock_Vbox/ZombieUnlockedIcon

@onready var new_demon_unlocked_button : Button = $DemonUnlockedButton
@onready var new_demon_icon := $DemonUnlockedButton/NewUnlock_Panel/MarginContainer/NewUnlock_Vbox/DemonUnlockedIcon

@onready var demon_selection_menu := $"../DemonSelectionMenu"

var unlocked_zombies : Array 
var zombie_count := 0 

var all_zombie_types :Dictionary 

var _blood_pulse_id := 0
var current_demon_synergies : Array 
var all_demon_types :Dictionary = {"Occulum":0 ,"Crawler" : 1, "Hive":2, "Maw":3,"Spinalocculum":4,"Wyrm":5}
var synergy_split : Array

var blood_amount: float = 50
var rect_region : Rect2 

signal blood_set(blood_val:int)

func _ready() -> void:
	build_zombie_types_array()
	
	new_zombie_unlocked_button.hide()
	new_demon_unlocked_button.hide()
	Global.register_ui_layer(self)
	if blood_label != null:
		blood_label.text = str(blood_amount)
	
	if make_green:
		rect_region = Rect2(0,0,32,32)
		health_icon.texture.region = rect_region
		
	self.blood_set.connect(demon_selection_menu.adjust_highlights)

func build_zombie_types_array()->void:
	for key in ZombieRegistry.SCENES.keys():
		all_zombie_types.set(key,zombie_count)
		zombie_count += 1
	pass
	

func get_blood_panel()->Control:
	return $HUD_Panel/MarginContainer/HUD_HBox/Blood_VBox/Blood_Icon

func get_health_panel()->Control:
	return $HUD_Panel/MarginContainer/HUD_HBox/Health_VBox/Health_Icon

func get_the_health() -> Node:
	return health_label

func set_blood(new_blood_amount: float) -> void:
	_blood_pulse_id += 1
	var my_id := _blood_pulse_id
	if new_blood_amount < blood_amount:
		blood_label.text = "[wave amp=40 freq=8][pulse freq=4 color=#ffffff40]%s[/pulse][/wave]" % str(new_blood_amount)
	else:
		blood_label.text = "[wave amp=-40 freq=8][pulse freq=4 color=#ff0000]%s[/pulse][/wave]" % str(new_blood_amount)
	
	await get_tree().create_timer(0.8).timeout
	if my_id == _blood_pulse_id:  # only reset if no newer call happened
		blood_label.text = str(new_blood_amount)

	blood_amount = new_blood_amount
	blood_set.emit(new_blood_amount)
	
	
func set_initial_blood(new_blood_amount: float) -> void:
	#print("SETTING NEW BLOOD ", new_blood_amount)
	blood_set.emit(new_blood_amount)
	blood_amount = new_blood_amount
	if blood_label != null:
		blood_label.text = str(blood_amount)
		
func set_zombie_unlock_notif(unlocked_zombie : String)->void:
	print("Set Zombie Unlock Notif For ", unlocked_zombie)
	if unlocked_zombies.has(unlocked_zombie):
		return 
	unlocked_zombies.append(unlocked_zombie)
	new_zombie_unlocked_button.show()
	set_zombie_icon_texture(unlocked_zombie)

func set_zombie_icon_texture(unlocked_zombie:String)->void:
	for zombie_icon in Global.all_zombie_notif_icons:
		if zombie_icon.get_name().containsn(unlocked_zombie):
			new_zombie_icon.texture = zombie_icon
			
#	new_zombie_icon.texture = GlobalResourceLoader.get_zombie_image(all_zombie_types[unlocked_zombie])


func set_unlock_notif(synergy : String)->void:
	print("Set Unlock Notif For ", synergy)
	if current_demon_synergies.has(synergy):
		return 
	current_demon_synergies.append(synergy)
	new_demon_unlocked_button.show()
	set_icon_texture(synergy)

	
func set_icon_texture(synergy:String)->void:
	synergy_split = split_capitals(synergy)
	new_demon_icon.texture = GlobalResourceLoader.get_demon_synergy_icon(synergy_split[0],synergy_split[1], all_demon_types[synergy_split[1]])
	
func split_capitals(s: String) -> Array:
	var result: Array = []
	var current: String = ""
	for c in s:
		if c == c.to_upper() and c != c.to_lower() and current != "":
			result.append(current)
			current = ""
		current += c
	if current != "":
		result.append(current)
	return result


func _on_demon_unlocked_button_pressed() -> void:
	print("Demon Unlock Button Pressed")
	print("Current Demon Synergies was ",current_demon_synergies )
	Global.navigate_to_buff(current_demon_synergies.pop_back())
	print("Current Demon Synergies is now ",current_demon_synergies )
	if current_demon_synergies.size() > 0:
		set_icon_texture(current_demon_synergies[0])
		return
		
	new_demon_unlocked_button.hide()
	
	


func _on_zombie_unlocked_button_pressed() -> void:
	print("Zombie Unlocked Button Pressed")
	new_zombie_unlocked_button.hide()
	get_parent().show_zombie_tutorial()
	
	
	
	
	
	
	
	
	
	
	##
