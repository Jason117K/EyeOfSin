extends SceneTree
## Smoke check that the game fonts (with their Noto fallbacks baked in at import)
## can supply glyphs for every target script: Cyrillic, Polish, CJK.
## Run: <godot.exe> --headless --path . -s res://_Localization/tools/verify_fonts.gd

const SAMPLES := {
	"ru:я": 0x044F,
	"pl:ą": 0x0105,
	"zh:中": 0x4E2D,
	"ja:あ": 0x3042,
	"ko:한": 0xD55C,
}

const FONTS: Array[String] = [
	"res://_Assets/Fonts/Cormorant-Bold.ttf",
	"res://_Assets/Fonts/Cormorant-Italic-VariableFont_wght.ttf",
	"res://_Assets/Fonts/cormorant.semi.otf",
	"res://_Assets/Fonts/Fleshandblood-MVA5x.ttf",
	"res://_Assets/Fonts/Mantinia Regular.otf",
	"res://_Assets/Fonts/Minecraft.ttf",
	"res://_Assets/Fonts/VCR_OSD_MONO_1.001.ttf",
]


func _init() -> void:
	var failures := 0
	for fpath: String in FONTS:
		var font: Font = load(fpath)
		if font == null:
			push_error("verify_fonts: cannot load " + fpath)
			failures += 1
			continue
		var missing := PackedStringArray()
		for label: String in SAMPLES:
			if not font.has_char(SAMPLES[label]):
				missing.append(label)
		if missing.is_empty():
			print(fpath.get_file() + ": all scripts covered")
		else:
			print(fpath.get_file() + ": MISSING " + ", ".join(missing))
			failures += 1
	print("verify_fonts: %d fonts with gaps" % failures)
	quit(failures)
