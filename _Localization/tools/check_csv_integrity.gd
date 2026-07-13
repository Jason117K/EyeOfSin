extends SceneTree
## Validates the translation CSVs: every row has the header's column count,
## and every locale cell keeps the same {placeholders} and BBCode-ish bracket
## count as the English source. Exit code = number of problems found.
## Run: <godot.exe> --headless --path . -s res://_Localization/tools/check_csv_integrity.gd

const CSVS: Array[String] = [
	"res://_Localization/ui.csv",
	"res://_Localization/names.csv",
	"res://_Localization/abilities.csv",
	"res://_Localization/tutorials.csv",
	"res://_Localization/descriptions.csv",
	"res://_Localization/synergies.csv",
	"res://_Localization/dialogic/dialogic_timeline_translations.csv",
	"res://_Localization/dialogic/dialogic_character_translations.csv",
]

var problems := 0


func _init() -> void:
	for path: String in CSVS:
		_check(path)
	print("check_csv_integrity: %d problems" % problems)
	quit(mini(problems, 100))


func _check(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_flag(path, "(file)", "cannot open")
		return
	var header := file.get_csv_line()
	var ncols := header.size()
	var en_col := header.find("en")
	var locale_cols := PackedInt32Array()
	for i: int in ncols:
		if i != 0 and i != en_col and not header[i].begins_with("_"):
			locale_cols.append(i)
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() == 1 and row[0].is_empty():
			continue # trailing blank line
		var key := row[0]
		if row.size() != ncols:
			_flag(path, key, "has %d columns, expected %d" % [row.size(), ncols])
			continue
		if en_col == -1:
			continue
		var en := row[en_col]
		var en_ph := _placeholders(en)
		for i: int in locale_cols:
			var cell := row[i]
			if cell.strip_edges().is_empty() and not en.strip_edges().is_empty():
				_flag(path, key, "empty %s cell" % header[i])
				continue
			if _placeholders(cell) != en_ph:
				_flag(path, key, "%s placeholders %s != en %s" % [header[i], _placeholders(cell), en_ph])
			if cell.count("[") != en.count("[") or cell.count("]") != en.count("]"):
				_flag(path, key, "%s bracket count differs from en (BBCode?)" % header[i])


func _placeholders(text: String) -> Array:
	var found := []
	var regex := RegEx.create_from_string("\\{[a-z_]+\\}")
	for m: RegExMatch in regex.search_all(text):
		found.append(m.get_string())
	found.sort()
	return found


func _flag(path: String, key: String, msg: String) -> void:
	print("PROBLEM %s [%s]: %s" % [path.get_file(), key, msg])
	problems += 1
