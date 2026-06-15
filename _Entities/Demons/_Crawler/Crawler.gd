extends Demon
#Crawler.gd

# --- Exports ---
@export var spiderling_wait_time := 2
@export var spinalOcculumHealth: float = 375

@export var damage: float = 10
@export var general_damage_increase := 10.0
@export var attack_speed_mult := 1.0
@export var projectile_spawn_offest: Vector2 = Vector2(32, 0)
@export var blood_worth_to_add := 10.0
@export var shoot_interval := 2.0 #Fire time is this val + anim time, currently +0.6
@export var buffed_range_target_pos := Vector2(375.0,0)

# --- Preloads ---
var projectile_scene: PackedScene = preload("res://_Entities/Demons/_Crawler/DemonProjectile.tscn")
var spiderling_scene: PackedScene = preload("res://_Entities/Demons/_Crawler/spiderling.tscn")

# --- State ---
var canAttack: bool = false
var second_shot_timer: Timer
var spiderling_timer: Timer
var canAttackSetTrueOnce: bool = false

# --- Component References ---
@onready var attack_ray: ShapeCast2D = $DMG_RayCast2D
@onready var projectile_shoot_component := $ProjectileShootComponent

@onready var range_line_indicator := $PreviewNodes/RangeIndicatorLine2D

signal crawler_buff_unlocked(buff_to_unlock:String)
signal is_hovering

# --- Lifecycle ---

func _ready() -> void:
	super()
	crawler_buff_unlocked.connect(Global.unlock_buff)
	hide_old_preview()
	
	if "Level0-1" in Global.game_controller.get_active_dimension().name:
		$PreviewNodes/BloodTileFront.modulate = Color(1,1,1,0)
		$PreviewNodes/BloodTileBack1.modulate = Color(1,1,1,0)
		$PreviewNodes/BloodTileBack2.modulate = Color(1,1,1,0)

func hide_old_preview()->void:
	$PreviewNodes/PreviewCard.visible = false 
	$PreviewNodes/PreviewCardSprite.visible = false 
	$PreviewNodes/PreviewCardShadow.visible = false 
	

func update_range_preview()->void:
	var global_target := attack_ray.to_global(attack_ray.target_position)
	range_line_indicator.set_point_position(1, Vector2(attack_ray.target_position.x,range_line_indicator.get_point_position(1).y))
	
# --- Getters ---

func get_damage()->float:
	return projectile_shoot_component.damage

func get_cost() -> float:
	return cost

func get_demon_true_name() -> String:
	return "Crawler"

func get_demon_name() -> String:
	return "CRAWLER"

func get_can_attack() -> bool:
	return projectile_shoot_component.canAttack


# --- Buff System ---

func baal_buff()->void:
	super()
	baal_halo.play("top_glow")
	
	
func receive_buff(newDemon) -> void:
	var demonName: String = (newDemon.get_demon_true_name())
	if !isBuffed:
		super(demonName)
		unlock_new_buff(demonName)
		projectile_shoot_component.receive_buff(demonName)
		match demonName:
			"Occulum":
				_increase_range()
			"Crawler":
				pass
			"SpinalOcculum":
				pass
			"Wyrm":
				pass
			"Hive":
				pass
			"Maw":
				spiderling_timer = Timer.new()
				spiderling_timer.wait_time = spiderling_wait_time
				spiderling_timer.one_shot = false
				spiderling_timer.timeout.connect(_on_spawn_spiderling_timeout)
				add_child(spiderling_timer)
				spiderling_timer.start()
				if $"../Arm" != null:
					$"../Arm".visible = true 
					$"../Arm2".visible = true 
		

func debuff() -> void:
	#animSpriteComp.debuff()
	super()


func unlock_new_buff(demonName)->void:
		if Global.game_controller.current_scenes.size()>1:
			match demonName:
				"Occulum":
					crawler_buff_unlocked.emit(Global.occulum_crawler_synergy)
				"Crawler":
					pass
				"SpinalOcculum":
					crawler_buff_unlocked.emit(Global.spinal_occulum_crawler_synergy)
				"Wyrm":
					crawler_buff_unlocked.emit(Global.wyrm_crawler_synergy)
				"Hive":
					crawler_buff_unlocked.emit(Global.hive_crawler_synergy)
				"Maw":
					crawler_buff_unlocked.emit(Global.maw_crawler_synergy)
					
					
					
# --- Death ---

func _cleanup() -> void:
	# No demon-specific cleanup needed beyond base
	super()


# --- Spiderling Spawning (Maw Buff) ---

func _on_spawn_spiderling_timeout() -> void:
	if mawBuff:
		var spiderling: Node2D = spiderling_scene.instantiate()
		spiderling.position = position + Vector2(8, -4)
		if self.is_in_group("Green"):
			spiderling.add_to_group("Green")
		else:
			spiderling.add_to_group("Purple")
		get_parent().add_child(spiderling)


# --- Preview ---

func _on_mouse_entered() -> void:
	#$PreviewNodes/Spider.visible = false

	Global.game_controller.get_active_dimension().demon_hover()
	$PreviewNodes.visible = true

func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false

	
func get_demon_icon()->CompressedTexture2D:
	return Global.crawler_icon
	
func get_special_description()->String:
	var file := FileAccess.open(Global.crawler_special_description, FileAccess.READ)
	var newText :String = file.get_as_text()
	return newText
	
	
	
func _increase_range()->void:
	#print("Old Target Pos ",attack_ray.target_position )
	attack_ray.target_position = buffed_range_target_pos
	#print("New Target Pos ",attack_ray.target_position )
	update_range_preview()
	pass
		
	
	
	
	
	
