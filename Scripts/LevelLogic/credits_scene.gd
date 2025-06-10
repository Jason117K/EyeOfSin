extends Control

@onready var creditsText := $CenterContainer/VBoxContainer/RichTextLabel

func _ready() -> void:
	creditsText.append_text("Creative Director : Jason King")
	creditsText.append_text("Art : Jason King,Admurin, and Penusbmic")
	creditsText.append_text("SFX : Sourced from Zapsplat")
