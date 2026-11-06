extends TextureButton


@onready var anim_player := $AcquireDemonAnimPlayer
@onready var new_power_texture := $NewPowerTextVbox/MarginContainer/TextureContainer/New_Power_Texture
@onready var title_label := $NewPowerTextVbox/TitleContainer/TitleLabel
@onready var description_label := $NewPowerTextVbox/TextContainer/DescriptionLabel


signal unlock_done


func _ready() -> void:
	pass


func activate()->void:
	#print("Activating Demon Texture")
	show()
	anim_player.play("appear")
	UiFx.add_pulsing_button_highlight(self)
	

func _on_acquire_demon_anim_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "appear":
		self.disabled = false 
	elif anim_name == "pickup":
		anim_player.play("cover_bg")
	elif anim_name == "cover_bg":
		unlock_done.emit()
		hide()
		
		
func _on_pressed() -> void:
	anim_player.play("pickup")


func set_new_power_texture(new_texture : Texture)->void:
	new_power_texture.texture = new_texture
	

func set_new_power_title(new_title:String)->void:
	title_label.text = tr(new_title)
	title_label._fit()
	

func set_new_power_description(new_description:String)->void:
	description_label.text = tr(new_description)
	description_label._fit()
	
	
	
	
	
	
	
	
	
	
	
	
	
	##
	
	
	
	
	
