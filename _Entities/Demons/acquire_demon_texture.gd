extends TextureButton

@onready var anim_player := $AcquireDemonAnimPlayer

signal unlock_done

func _ready() -> void:
	pass

func activate()->void:
	show()
	anim_player.play("appear")
	Global.add_pulsing_button_highlight(self)
	


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
