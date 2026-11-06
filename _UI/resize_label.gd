@tool
class_name ShrinkToFitLabel
extends RichTextLabel

const WRAP_FLAGS := TextServer.BREAK_WORD_BOUND \
		| TextServer.BREAK_TRIM_START_EDGE_SPACES \
		| TextServer.BREAK_TRIM_END_EDGE_SPACES

@export var max_font_size: int = 32:
	set(v):
		max_font_size = v
		_fit()
@export var min_font_size: int = 8:
	set(v):
		min_font_size = v
		_fit()
# Explicit line breaks don't count. Needs autowrap_mode on, and text can exceed this at min_font_size.
@export_range(0, 8, 1, "or_greater") var max_allowed_autowraps: int = 0:
	set(v):
		max_allowed_autowraps = v
		_fit()

var _last_text := ""

func _ready() -> void:
	resized.connect(_fit)
	_fit()

# Catches text being set from anywhere (code, editor, translations).
#func _process(_delta: float) -> void:
	#if text != _last_text:
		#_fit()

func _fit() -> void:
	if not is_inside_tree():
		return
	_last_text = text

	var font := get_theme_font("normal_font")
	var style := get_theme_stylebox("normal")
	var available := size.x - style.get_margin(SIDE_LEFT) - style.get_margin(SIDE_RIGHT)
	if available <= 0.0:
		return

	#var s := text.to_upper() if uppercase else text
	var s :=  text 
	var fs := max_font_size
	while fs > min_font_size and not _fits(font, s, fs, available):
		fs -= 1

	add_theme_font_size_override("normal_font_size", fs)

func _fits(font: Font, s: String, fs: int, available: float) -> bool:
	var autowraps := 0
	for line in s.split("\n"):  # respects explicit line breaks
		var paragraph := TextParagraph.new()
		paragraph.width = available
		paragraph.break_flags = WRAP_FLAGS
		paragraph.add_string(line, font, fs)
		var line_count := paragraph.get_line_count()
		autowraps += maxi(line_count - 1, 0)
		if autowraps > max_allowed_autowraps:
			return false
		# Word-bound breaking leaves an over-wide word on its own line instead of splitting it.
		for i in line_count:
			if paragraph.get_line_width(i) > available:
				return false
	return true
