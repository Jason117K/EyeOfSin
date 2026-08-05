extends Area2D

@onready var death_timer := $DeathTimer

var current_demon_type : Global.DEMON_TYPE
var demon_location : Vector2
var demon_selection_menu : Control
var demon_manager : Node 
var is_green : bool 

func _ready() -> void:
	demon_selection_menu = Global.get_demon_selection_menu(is_green)
	demon_manager = Global.get_demon_manager(is_green)

func set_current_demon_type(new_demon_type:Global.DEMON_TYPE)->void:
	current_demon_type = new_demon_type
	
func set_is_green(new_is_green : bool)->void:
	is_green = new_is_green 
	
	
func revive_summon()->void:
	#print("[HERO_REVIVE]: Calling Revive SUMMON ")
	match current_demon_type:
		Global.DEMON_TYPE.CRAWLER:
			demon_selection_menu._on_CrawlerButton_pressed()
		Global.DEMON_TYPE.OCCULUM:
			demon_selection_menu._on_OcculumButton_pressed()
		Global.DEMON_TYPE.SPINAL_OCCULUM:
			demon_selection_menu._on_SpinalOcculumButton_pressed()
		Global.DEMON_TYPE.WYRM:
			demon_selection_menu._on_WyrmButton_pressed()
		Global.DEMON_TYPE.MAW:
			demon_selection_menu._on_MawButton_pressed()
		Global.DEMON_TYPE.HIVE:
			demon_selection_menu._on_HiveButton_pressed()
			
	demon_manager.place_demon(demon_location)
	self.hide()
	death_timer.start()


func _on_death_timer_timeout() -> void:
	queue_free()
