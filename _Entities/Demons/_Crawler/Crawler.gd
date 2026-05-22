extends Demon
#Crawler.gd

# --- Exports ---
@export var spiderling_wait_time := 2
@export var spinalOcculumHealth = 375

@export var damage := 60
@export var attack_speed_mult := 1.0
@export var projectile_spawn_offest: Vector2 = Vector2(32, 0)
@export var blood_worth_to_add := 10.0

# --- Preloads ---
var projectile_scene = preload("res://_Entities/Demons/_Crawler/DemonProjectile.tscn")
var spiderling_scene = preload("res://_Entities/Demons/_Crawler/spiderling.tscn")

# --- State ---
var canAttack = false
var second_shot_timer : Timer
var spiderling_timer : Timer
var canAttackSetTrueOnce = false

# --- Component References ---
@onready var attack_ray = $DMG_RayCast2D
@onready var projectile_shoot_component := $ProjectileShootComponent


# --- Lifecycle ---

func _ready():
	super()


# --- Getters ---

func get_damage():
	return projectile_shoot_component.damage

func get_cost():
	return cost

func get_demon_true_name():
	return "Crawler"

func get_demon_name():
	return "CRAWLER"

func get_can_attack():
	return projectile_shoot_component.canAttack


# --- Buff System ---

func receive_buff(newDemon):
	var demonName = (newDemon.get_demon_true_name())
	if !isBuffed:
		super(demonName)
		projectile_shoot_component.receive_buff(demonName)
		match demonName:
			"Occulum":
				pass
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

func debuff():
	animSpriteComp.debuff()
	super()


# --- Death ---

func _cleanup():
	# No demon-specific cleanup needed beyond base
	super()


# --- Spiderling Spawning (Maw Buff) ---

func _on_spawn_spiderling_timeout() -> void:
	if mawBuff:
		var spiderling = spiderling_scene.instantiate()
		spiderling.position = position + Vector2(8, -4)
		if self.is_in_group("Green"):
			spiderling.add_to_group("Green")
		else:
			spiderling.add_to_group("Purple")
		get_parent().add_child(spiderling)


# --- Preview ---

func _on_mouse_entered() -> void:
	$PreviewNodes/Spider.visible = false
	$PreviewNodes.visible = true

func _on_mouse_exited() -> void:
	$PreviewNodes.visible = false
