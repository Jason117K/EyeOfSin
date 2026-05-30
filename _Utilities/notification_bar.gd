extends MarginContainer

@onready var notifLabel := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/NameSpecialHbox/NotifNameLabel
@onready var speed_label := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer/SpeedPanel/SpeedContainer/SpeedLabel
@onready var special_label := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/NameSpecialHbox/SpecialMarginContainer/SpecialLabel
#@onready var health_label := $NotificationPanel/NotificationHbox/StatsContainer/HealthPanel/HealthContainer/HealthLabel

@onready var health_progress_bar_label := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer/HealthPanel/HealthContainer/HealthProgressBar/HealthProgressBarLabel
@onready var health_progress_bar := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer/HealthPanel/HealthContainer/HealthProgressBar
@onready var damage_label := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer/DamagePanel/DamageContainer/DamageLabel

@onready var speed_amount_label := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer/SpeedPanel/SpeedContainer/SpeedAmountLabel
@onready var damage_amount_label := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer/DamagePanel/DamageContainer/DamageAmountLabel
@onready var stats_container := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer
#@onready var stat_container_2 := $NotificationPanel/MarginContainer/NotificationHbox/StatsContainer2


@onready var health_panel := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer/HealthPanel
@onready var speed_panel := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer/SpeedPanel
@onready var damage_panel := $NotificationPanel/NotifMarginContainer/NotificationHbox/NameHealthVboxContainer/StatsHboxContainer/DamagePanel
@onready var icon_panel := $NotificationPanel/NotifMarginContainer/NotificationHbox/IconPanel

@onready var notif_icon := $NotificationPanel/NotifMarginContainer/NotificationHbox/IconPanel/NotifTextureIcon

@export var cannot_afford_label_disappear_time := 2.0
@export var info_disappear_time := 5.0

var hide_bar_timer: Timer
var current_zombie: Zombie
var current_demon: Demon
var should_hide := false
var fill_style: StyleBoxFlat

func _ready() -> void:
	#print_scene_tree()
	hide()
	Global.register_notification_bar(self)
	hide_bar_timer = Timer.new()
	hide_bar_timer.one_shot = true
	hide_bar_timer.autostart = false
	hide_bar_timer.timeout.connect(_on_hide_bar_timer_timeout)
	add_child(hide_bar_timer)
	
func _physics_process(_delta: float) -> void:
	if self.visible == true :
		if current_zombie != null:
			if current_zombie.get_health() > 0:
				#print("Setting Current Zombie Health to ", current_zombie.get_health())
				health_progress_bar.value = current_zombie.get_health()
				health_progress_bar.max_value = current_zombie.get_max_health()
				health_progress_bar_label.text = str(current_zombie.get_health()) + " / " + str(current_zombie.get_max_health())
			else:
				should_hide = true
		if current_demon != null:
			if current_demon.get_health() > 0:
				health_progress_bar.max_value = int(current_demon.get_max_health())
				health_progress_bar.value = int(current_demon.get_health())
				health_progress_bar_label.text = str(int(current_demon.get_health())) + " / " + str(int(current_demon.get_max_health()))
	pass
	
	
func set_panel_border_color(panel: PanelContainer, color: Color) -> void:
	var stylebox := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	stylebox.border_color = color
	panel.add_theme_stylebox_override("panel", stylebox)	
	
func set_label_border_color(label: RichTextLabel, color: Color) -> void:
	var stylebox := label.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	#print("Label Is ", label, " StyleBox Is : ",stylebox)
	stylebox.border_color = color
	label.add_theme_stylebox_override("normal", stylebox)

func set_text(new_text: String) -> void:
	hide_bar_timer.wait_time = cannot_afford_label_disappear_time
	show_main_notification_only()
	notifLabel.text = new_text
	notifLabel.shake()
	hide_bar_timer.start()
	
func show_main_notification_only() -> void:
	show()
	stats_container.hide()

	set_label_border_color(notifLabel, Color.RED)
	notifLabel.add_theme_color_override("default_color",Color.RED)
	notifLabel.show()
	
	
func _on_hide_bar_timer_timeout() -> void:
	hide()
	current_demon = null
	current_zombie = null
	
	
func print_scene_tree(node: Node = self, indent: int = 0) -> void:
	var prefix := "\t".repeat(indent)
	print(prefix + node.name + "(" + node.get_class() + ")")
	for child in node.get_children():
		pass
		print_scene_tree(child, indent + 1)
		
		
func set_demon_info(demon: Demon) -> void:
	current_zombie = null
	hide_bar_timer.wait_time = info_disappear_time
	current_demon = demon
	show_demon_notification()
	notifLabel.text = demon.get_demon_name()
	#print("Getting Demon Health, it is ",demon.get_health() )
	health_progress_bar.max_value = int(demon.get_max_health())
	health_progress_bar.value = int(demon.get_health())
	health_progress_bar_label.text = str(int(demon.get_health())) + " / " + str(int(demon.get_max_health()))
	damage_amount_label.text = str(demon.get_damage())
	
	notif_icon.texture = demon.get_demon_icon()
	notif_icon.hue_shift = 0.0
	notif_icon._apply_hue_shift()
	special_label.text = demon.get_special_description()
	
	health_progress_bar.add_theme_color_override("default_color",Color.RED)
	damage_amount_label.add_theme_color_override("default_color",Color.RED)
	damage_label.add_theme_color_override("default_color",Color.RED)
	special_label.add_theme_color_override("default_color",Color.RED)
	notifLabel.add_theme_color_override("default_color",Color.RED)

	set_panel_border_color(health_panel,Color.RED)
	set_panel_border_color(speed_panel,Color.RED)
	set_panel_border_color(damage_panel,Color.RED)
	set_panel_border_color(icon_panel,Color.RED)

	set_label_border_color(notifLabel, Color.RED)	
	fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color.RED
	health_progress_bar.add_theme_stylebox_override("fill", fill_style)
					
		
func set_zombie_info(zombie: Zombie) -> void:
	current_demon = null
	#print("Setting Bar For ", zombie)
	hide_bar_timer.wait_time = info_disappear_time
	current_zombie = zombie
	show_zombie_notification()
	notifLabel.text = zombie.get_zombie_name()
	#health_amount_label.text = str(zombie.get_health())
	health_progress_bar.value = zombie.get_health()
	health_progress_bar.max_value = zombie.get_max_health()
	health_progress_bar_label.text = str(zombie.get_health()) + " / " + str(zombie.get_max_health())
	speed_amount_label.text = str(zombie.get_speed())
	damage_amount_label.text = str(zombie.get_damage())
	
	notif_icon.texture = zombie.get_zombie_icon()
	special_label.text = zombie.get_special_description()
	
	fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color.WEB_PURPLE         
	
	if Global.game_controller.on_purple_scene():
		health_progress_bar.add_theme_color_override("default_color",Color.WEB_PURPLE)
		speed_amount_label.add_theme_color_override("default_color",Color.WEB_PURPLE)
		damage_amount_label.add_theme_color_override("default_color",Color.WEB_PURPLE)
		#health_label.add_theme_color_override("default_color",Color.WEB_PURPLE)
		speed_label.add_theme_color_override("default_color",Color.WEB_PURPLE)
		damage_label.add_theme_color_override("default_color",Color.WEB_PURPLE)
		special_label.add_theme_color_override("default_color",Color.WEB_PURPLE)
		notifLabel.add_theme_color_override("default_color",Color.WEB_PURPLE)
		
		set_panel_border_color(health_panel,Color.WEB_PURPLE)
		set_panel_border_color(speed_panel,Color.WEB_PURPLE)
		set_panel_border_color(damage_panel,Color.WEB_PURPLE)
		set_panel_border_color(icon_panel,Color.WEB_PURPLE)
		
		set_label_border_color(notifLabel, Color.WEB_PURPLE)
		
		fill_style.bg_color = Color.WEB_PURPLE
		health_progress_bar.add_theme_stylebox_override("fill", fill_style)
		
		notif_icon.hue_shift = 0.0
		notif_icon._apply_hue_shift()
		

		
	else:
		health_progress_bar.add_theme_color_override("default_color",Color.DARK_GREEN)
		speed_amount_label.add_theme_color_override("default_color",Color.DARK_GREEN)
		damage_amount_label.add_theme_color_override("default_color",Color.DARK_GREEN)
		#health_label.add_theme_color_override("default_color",Color.DARK_GREEN)
		speed_label.add_theme_color_override("default_color",Color.DARK_GREEN)
		damage_label.add_theme_color_override("default_color",Color.DARK_GREEN)
		notifLabel.add_theme_color_override("default_color",Color.DARK_GREEN)
		special_label.add_theme_color_override("default_color",Color.DARK_GREEN)	
		set_panel_border_color(health_panel,Color.DARK_GREEN)
		set_panel_border_color(speed_panel,Color.DARK_GREEN)
		set_panel_border_color(damage_panel,Color.DARK_GREEN)
		set_panel_border_color(icon_panel,Color.DARK_GREEN)
		
		set_label_border_color(notifLabel, Color.DARK_GREEN)
		
		fill_style.bg_color = Color.DARK_GREEN
		health_progress_bar.add_theme_stylebox_override("fill", fill_style)


		notif_icon.hue_shift = -125.0
		notif_icon._apply_hue_shift()
		
		
func show_zombie_notification() -> void:
	show()
	stats_container.show()
	speed_panel.show()
	notifLabel.show()	
	hide_bar_timer.start()
	
	
func show_demon_notification() -> void:
	show()
	stats_container.show()
	speed_panel.hide()
	notifLabel.show()	
	hide_bar_timer.start()	
	
			
	
	
	
	
	
