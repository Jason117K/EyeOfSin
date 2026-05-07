extends RichTextLabel

@export var max_font_size: int = 48
@export var min_font_size: int = 8

var _base_text: String = ""


func _ready() -> void:
	# Disable scroll so content doesn't just overflow silently
	scroll_active = false
	clip_contents = true
	fit_content = false
	resized.connect(_on_resized)


func set_auto_text(bbcode: String) -> void:
	_base_text = bbcode
	_fit_font_size()


func _on_resized() -> void:
	if _base_text != "":
		_fit_font_size()


func _fit_font_size() -> void:
	var lo := min_font_size
	var hi := max_font_size

	# Binary search for the largest font size that fits
	while lo < hi:
		var mid := (lo + hi + 1) / 2
		_apply_size(mid)

		# Wait a frame so the layout updates
		await get_tree().process_frame

		if _content_fits():
			lo = mid
		else:
			hi = mid - 1

	_apply_size(lo)


func _apply_size(size: int) -> void:
	# Override the default font size theme property
	add_theme_font_size_override("normal_font_size", size)
	add_theme_font_size_override("bold_font_size", size)
	add_theme_font_size_override("italics_font_size", size)
	add_theme_font_size_override("bold_italics_font_size", size)
	text = _base_text


func _content_fits() -> bool:
	# get_content_height() returns the total height the text wants
	return get_content_height() <= size.y
