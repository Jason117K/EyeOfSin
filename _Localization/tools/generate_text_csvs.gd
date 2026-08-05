extends SceneTree
## MERGE-MODE generator: syncs the game's .txt files into the translation CSVs
## without losing existing translations. Safe to re-run any time.
##
##   - .txt file NEW      -> row added (en filled, locale cells empty -> English fallback in-game)
##   - .txt file CHANGED  -> en cell updated, locale cells CLEARED (stale translations would
##                           otherwise keep showing the old text; cleared cells fall back to
##                           English until retranslated) — reported at the end
##   - .txt file SAME     -> row untouched, translations preserved
##   - row with no .txt   -> kept as-is, reported as orphaned (delete manually if intended)
##
## Keys are derived from filenames via Loc.key_from_path (the .txt path is the identity).
## Run headless from the project root:
##   <godot.exe> --headless --path . -s res://_Localization/tools/generate_text_csvs.gd

const LocScript := preload("res://_Utilities/loc.gd")

const DEFAULT_HEADER: PackedStringArray = ["keys", "en", "_notes"]

const JOBS: Array[Dictionary] = [
	{
		"out": "res://_Localization/tutorials.csv",
		"roots": ["res://_Assets/Text/TextFiles"],
	},
	{
		"out": "res://_Localization/descriptions.csv",
		"roots": [
			"res://_Assets/Text/TextFiles/DemonDescriptions",
			"res://_Assets/Text/TextFiles/ZombieDescriptions",
			"res://_Assets/Text/TextFiles/ZombieSpecialDescriptions",
			"res://_Entities/Demons/SpecialDescriptions",
		],
	},
	{
		"out": "res://_Localization/synergies.csv",
		"roots": ["res://_Assets/Text/TextFiles/Synergies"],
	},
]

var _had_error := false
var _retranslate := PackedStringArray()
var _orphaned := PackedStringArray()


func _init() -> void:
	var seen_keys := {}
	for job: Dictionary in JOBS:
		_merge_job(job, seen_keys)
	if not _retranslate.is_empty():
		#print("\nNEEDS RETRANSLATION (en changed, locale cells cleared):")
		for k: String in _retranslate:
			#print("  - " + k)
	if not _orphaned.is_empty():
		#print("\nORPHANED rows (no matching .txt on disk; kept, delete manually if intended):")
		for k: String in _orphaned:
			#print("  - " + k)
	quit(1 if _had_error else 0)


func _merge_job(job: Dictionary, seen_keys: Dictionary) -> void:
	var out_path := str(job.out)

	# 1) Load the existing CSV (if any) into header + key->row map.
	var header := DEFAULT_HEADER
	var rows := {}  # key -> PackedStringArray sized to header
	var row_order := PackedStringArray()
	var file := FileAccess.open(out_path, FileAccess.READ)
	if file != null:
		header = file.get_csv_line()
		while not file.eof_reached():
			var row := file.get_csv_line()
			if row.size() == 1 and row[0].is_empty():
				continue
			if row.size() != header.size():
				push_error("generate_text_csvs: %s row '%s' has %d columns, expected %d — fix the CSV first (check_csv_integrity.gd), aborting this file" % [out_path, row[0], row.size(), header.size()])
				_had_error = true
				return
			rows[row[0]] = row
			row_order.append(row[0])

	var en_col := header.find("en")
	var notes_col := header.find("_notes")
	if en_col == -1:
		push_error("generate_text_csvs: %s has no 'en' column" % out_path)
		_had_error = true
		return
	var locale_cols := PackedInt32Array()
	for i: int in header.size():
		if i != 0 and i != en_col and not header[i].begins_with("_"):
			locale_cols.append(i)

	# 2) Walk the .txt files and merge.
	var added := 0
	var updated := 0
	var unchanged := 0
	var keys_on_disk := {}
	for root: String in job.roots:
		var dir := DirAccess.open(root)
		if dir == null:
			push_error("generate_text_csvs: cannot open folder " + root)
			_had_error = true
			continue
		for fname: String in dir.get_files():
			if not fname.ends_with(".txt"):
				continue
			var path := root.path_join(fname)
			var key := String(LocScript.key_from_path(path))
			if seen_keys.has(key):
				push_error("generate_text_csvs: key collision %s (%s vs %s)" % [key, seen_keys[key], path])
				_had_error = true
				continue
			seen_keys[key] = path
			keys_on_disk[key] = true
			var txt := FileAccess.open(path, FileAccess.READ)
			if txt == null:
				push_error("generate_text_csvs: cannot read " + path)
				_had_error = true
				continue
			var en_text := txt.get_as_text()

			if not rows.has(key):
				var new_row := PackedStringArray()
				new_row.resize(header.size())
				new_row.fill("")
				new_row[0] = key
				new_row[en_col] = en_text
				if notes_col != -1:
					new_row[notes_col] = path
				rows[key] = new_row
				row_order.append(key)
				added += 1
			elif _norm((rows[key] as PackedStringArray)[en_col]) != _norm(en_text):
				var row: PackedStringArray = rows[key]
				row[en_col] = en_text
				for i: int in locale_cols:
					row[i] = ""
				rows[key] = row
				updated += 1
				_retranslate.append("%s (%s)" % [key, out_path.get_file()])
			else:
				unchanged += 1

	for key: String in row_order:
		if not keys_on_disk.has(key):
			_orphaned.append("%s (%s)" % [key, out_path.get_file()])

	# 3) Write back, keys sorted for stable diffs.
	row_order.sort()
	var lines := PackedStringArray([_join_csv(header)])
	for key: String in row_order:
		lines.append(_join_csv(rows[key]))
	var out := FileAccess.open(out_path, FileAccess.WRITE)
	if out == null:
		push_error("generate_text_csvs: cannot write " + out_path)
		_had_error = true
		return
	out.store_string("\n".join(lines) + "\n")
	#print("%s: %d added, %d en-updated, %d unchanged, %d orphaned" % [out_path.get_file(), added, updated, unchanged, _count_for(out_path)])


func _count_for(out_path: String) -> int:
	var n := 0
	for entry: String in _orphaned:
		if entry.ends_with("(%s)" % out_path.get_file()):
			n += 1
	return n


func _join_csv(row: PackedStringArray) -> String:
	var cells := PackedStringArray()
	for cell: String in row:
		cells.append(_escape(cell))
	return ",".join(cells)


## Whitespace-insensitive comparison: the CSV en cells are normalized (no trailing
## spaces) while the .txt files often have them — such differences are invisible
## in-game and must NOT count as "text changed" (that would wipe translations).
func _norm(text: String) -> String:
	var out := PackedStringArray()
	for line: String in text.split("\n"):
		out.append(line.rstrip(" \t\r"))
	return "\n".join(out).strip_edges()


func _escape(cell: String) -> String:
	if cell.contains("\"") or cell.contains(",") or cell.contains("\n") or cell.contains("\r"):
		return "\"" + cell.replace("\"", "\"\"") + "\""
	return cell
