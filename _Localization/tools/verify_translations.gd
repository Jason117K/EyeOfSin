extends SceneTree
## Smoke check that the CSV translations are imported + registered and keys resolve.
## Run headless from the project root (exit code = number of unresolved keys):
##   <godot.exe> --headless --path . -s res://_Localization/tools/verify_translations.gd

const SAMPLE_KEYS: Array[String] = [
	"UI_START_GAME",
	"UI_LANGUAGE",
	"TXT_FIRSTTUTORIAL",
	"TXT_CRAWLERBASE",
	"TXT_OCCULUMDESCRIPTION",
	"TXT_OCCULUM_SPECIAL_DESCRIPTION",
	"TXT_WYRMQUEEN",
	"UI_PAUSED",
	"UI_CANNOT_AFFORD_DEMON",
	"UI_WAVE_LABEL",
	"UI_LEVEL_BTN_9",
	"UI_DEMON_UNLOCKED",
	"UI_BOOK_FLIP_HINT",
	"LORE_OCCULUM_INTRO",
	"LEVEL_TITLE_0_5",
	"TIP_TITLE_PORTALS",
	"ABILITY_BLOOD_RAIN_TITLE",
	"ABILITY_TORRENTIAL_BLOOD_TITLE",
	"POWER_OCCULUM_DESC_LONG",
	"NAME_REBORN",
	"NAME_SPINAL_OCCULUM",
]


const LOCALES: Array[String] = ["en", "es", "zh_CN", "ru", "pt_BR", "de", "ja", "fr", "pl", "ko"]


func _init() -> void:
	TranslationServer.set_locale("en")
	var en_values := {}
	for key: String in SAMPLE_KEYS:
		en_values[key] = TranslationServer.translate(key)

	var failures := 0
	for locale: String in LOCALES:
		TranslationServer.set_locale(locale)
		var unresolved := 0
		var same_as_en := 0
		for key: String in SAMPLE_KEYS:
			var value := TranslationServer.translate(key)
			if value == key:
				push_error("verify_translations: [%s] UNRESOLVED key %s" % [locale, key])
				unresolved += 1
			elif locale != "en" and value == en_values[key]:
				same_as_en += 1
		failures += unresolved
		print("%s: %d/%d resolved, %d identical to en" % [locale, SAMPLE_KEYS.size() - unresolved, SAMPLE_KEYS.size(), same_as_en])
	TranslationServer.set_locale("en")
	print("verify_translations: %d failures" % failures)
	quit(failures)
