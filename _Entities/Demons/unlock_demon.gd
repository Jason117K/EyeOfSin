extends Control


func _on_next_level_button_pressed() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UI_CLICK)
	Global.game_controller.change_from_dual_scenes("res://_Stages/LevelSelect/LevelSelect_Map.tscn")
	self.visible = false
