extends Area2D

class_name Demon 

#Handle Area Detection for Buffs, Buffs, Storing Cost, Showing Preview Nodes

var area : Area2D
var isBuffed := false

@export var wyrmBuff = false
@export var hiveBuff = false 
@export var spinalOcculumBuff = false
@export var mawBuff = false
@export var crawlerBuff = false
@export var occulumBuff = false 

@onready var animSpriteComp := $AnimatedSpriteComponent
@onready var healthComp := $HealthComponent

func _ready() -> void:
	pass
	await get_tree().physics_frame
	#self.set_process(false)
	input_event.connect(_on_input_event)
	print(self, " Heart Connect")
	for new_area in get_overlapping_areas():
		print("New Area is ", new_area)
		if new_area.is_in_group("HeartBuff"):
			receive_heart_buff()
	self.area_entered.connect(on_demon_area_entered)
	self.area_exited.connect(on_demon_area_exited)
	
func on_demon_area_entered(new_area: Area2D):
	#print(self, "New Area Heart is ", new_area)
	if new_area.is_in_group("HeartBuff"):
		#print(self, "will now receive heart buff")
		pass
		#receive_heart_buff()
		
func on_demon_area_exited(old_area: Area2D):
	if old_area.is_in_group("HeartBuff"):
		remove_heart_buff()		

func get_animSpriteComp():
	return animSpriteComp
	
#TODO Call receive_buff On ALL Components Here
#TODO Set All isDemonBuffed Variables Here As Well
func receive_buff(newDemon):
	#print("Buff Name is ", newDemon.name)
	#var demonName = truncate_string(newDemon.name)
	if !isBuffed :
		print(self.name, " Received Buff from ", newDemon)
		healthComp.receive_buff(newDemon)
		animSpriteComp.receive_buff(newDemon)
		isBuffed = true 
		match newDemon:
			"Occulum":
				print("Change to Occulum")
				occulumBuff = true
			"Crawler":
				print("Change to Crawler")
				crawlerBuff = true 
			"SpinalOcculum" :
				print("Change to SpinalOcculum")
				spinalOcculumBuff = true
			"Wyrm":
				print("Change to Wyrm")
				wyrmBuff = true
			"Hive":
				print("Change to Hive")
				hiveBuff = true
			"Maw":
				print("Change to Maw")
				mawBuff = true 
		#animSpriteComp.make_buff_glow()

func truncate_string(input_string: String) -> String:
	for i in range(input_string.length()):
		var character = input_string[i]
		if character.is_valid_int():
			return input_string.substr(0, i)
	return input_string
	
func receive_heart_buff():
	print(self.name , " receive Heart Buff")
	$BuffNodesComponent.get_child(0).visible = true 
	increase_max_health(400)
	increase_health(400)
	pass
	
func remove_heart_buff():
	print(self.name , " remove Heart Buff")
	$BuffNodesComponent.get_child(0).visible = false 
	pass
	
func finish_spawn():
	animSpriteComp.visible = true		
	animSpriteComp.animation = animSpriteComp.currentAnim
	animSpriteComp.play()

func get_is_buffed():
	return isBuffed

func increase_health(added_health_amount):
	if healthComp.is_node_ready():
		healthComp.increase_health(added_health_amount)

func increase_max_health(added_health_amount):
	healthComp.increase_max_health(added_health_amount)

func take_damage(damage):
	#print(self, " is now taking damage : ", damage)
	healthComp.take_damage(damage)

func get_health():
	#print(self, " now getting the health, should return ",  healthComp.get_health())
	return healthComp.get_health()
	
func get_max_health():
	return healthComp.get_max_health()
	
func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + 1)
	
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print(self, " was clicked ")
		Global.set_demon_info_bar(self)
		pass
#
	#
