extends Demon
#Wyrm.gd

# --- Exports: Health Buff Values ---
@export var spinalOcculumBuffed_health := 650
@export var mawBuffed_health := 350

# --- Exports: Projectile ---
@export var projectile_cooldown: float = 3
@export var projectile_auto_fire := true
@export var occulum_buff_cooldown: float = 0.9
@export var projectile_speed := 600
@export var projectile_damage := 20
@export var bleed_damage_increase := 2

# --- Exports: Laser ---
@export var laser_color: Color = Color(1.0, 0.0, 0.0, 1.0)
@export var extension_speed: float = 1000.0
@export var max_length: float = 1000.0
@export var laser_width: float = 4.0
@export var laser_damage: float = 20
@export var maw_damage: float = 60
@export var duration: float = 0.5
@export var laser_auto_fire: bool = false
@export var laser_cooldown: float = 3
@export var blood_buff_cooldown: float = 0.9


# --- Component References ---
@onready var laserShootComp1 := $LaserShootComponent
@onready var laserShootComp2 := $LaserShootComponent2
@onready var projectile_shoot_component := $ProjectileShootComponent
@onready var attack_ray := $DMG_RayCast2D


@onready var range_line_indicator := $PreviewNodes/RangeIndicatorLine2D
@onready var og_target_position :Vector2 = attack_ray.target_position
@export var mana_add_on_laser := 100

# --- State ---
var isCrawlerBuffed := false
var isSpineBuffed := false
var isOcculumBuffed := false
var spawnAnimDone := false

# Animation state
var time := 0.0
var current_squash := 0.0
var current_stretch := 0.0
var target_squash := 0.0
var target_stretch := 0.0
var velocity := 0.0
var prev_y := 0.0
var initial_sprite_scale: Vector2
var initial_sprite_position: Vector2
var bufferName: String

signal wyrm_buff_unlocked(buff_to_unlock:String)

# --- Lifecycle ---

func _ready() -> void:
	super()
	special_description_file = Global.wyrm_queen_special_description
	# --- Demon-specific collision ---
	_init_demon_collision()
		
	var scale_x :float= laserShootComp2.line2D.global_transform.x.length()   # world px per local px, along local X
	laserShootComp2.max_length =  attack_ray.target_position.x / scale_x
	laserShootComp1.max_length =  attack_ray.target_position.x / scale_x
	
	hide_old_preview()

	all_synergies = Global.all_wyrm_synergies
	#special_description_file = get_special_description_file(all_synergies,"Base")
	spawn_done = true
	can_show_preview = true 
	

func hide_old_preview()->void:
	preview_nodes.hide()
	#$PreviewNodes/PreviewCard.visible = false 
	#$PreviewNodes/PreviewCardSprite.visible = false 
	#$PreviewNodes/PreviewCardShadow.visible = false 
	
func _init_demon_collision() -> void:
	if self.is_in_group("Green"):
		$DMG_RayCast2D.set_collision_mask_value(1, false)
		$DMG_RayCast2D.set_collision_mask_value(2, false)
		$DMG_RayCast2D.set_collision_mask_value(3, false)
		$DMG_RayCast2D.set_collision_mask_value(4, false)
		$DMG_RayCast2D.set_collision_mask_value(5, true)
	else:
		$DMG_RayCast2D.set_collision_mask_value(1, false)
		$DMG_RayCast2D.set_collision_mask_value(2, false)
		$DMG_RayCast2D.set_collision_mask_value(3, false)
		$DMG_RayCast2D.set_collision_mask_value(4, true)

# --- Getters ---

func get_demon_true_name() -> String:
	return "Wyrm"

func get_demon_name() -> String:
	return "WYRMQUEEN"

func get_damage() -> int:
	return projectile_shoot_component.projectile_damage

func get_cost() -> float:
	return cost


# --- Buff System ---

func receive_buff(_demon) -> void:
	pass

func debuff() -> void:
	pass

func unlock_new_buff(_demonName:String)->void:
	pass



# --- Damage ---

func take_damage(damage: float) -> void:
	healthComp.take_damage(damage)




	
func baal_buff()->void:
	super()
	baal_halo.play("top_glow")	

# --- Preview ---



func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false
