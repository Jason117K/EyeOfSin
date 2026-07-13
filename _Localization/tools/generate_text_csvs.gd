extends SceneTree
## Regenerates the translation CSVs whose English text comes from the game's .txt files.
## Keys are derived from filenames via Loc.key_from_path (the .txt path is the identity),
## and the _notes comment column records the source path for translators/devs.
##
## Run headless from the project root:
##   <godot.exe> --headless --path . -s res://_Localization/tools/generate_text_csvs.gd
##
## Existing locale columns other than "en" are NOT preserved — after the machine-translation
## pass (Phase L4), fold new English rows into the translated CSVs instead of re-running blindly.

const LocScript := preload("res://_Utilities/loc.gd")

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


func _init() -> void:
	var seen_keys := {}
	var had_error := false
	for job: Dictionary in JOBS:
		var rows: Array[PackedStringArray] = []
		for root: String in job.roots:
			var dir := DirAccess.open(root)
			if dir == null:
				push_error("generate_text_csvs: cannot open folder " + root)
				had_error = true
				continue
			for fname: String in dir.get_files():
				if not fname.ends_with(".txt"):
					continue
				var path := root.path_join(fname)
				var key := String(LocScript.key_from_path(path))
				if seen_keys.has(key):
					push_error("generate_text_csvs: key collision %s (%s vs %s)" % [key, seen_keys[key], path])
					had_error = true
					continue
				seen_keys[key] = path
				var file := FileAccess.open(path, FileAccess.READ)
				if file == null:
					push_error("generate_text_csvs: cannot read " + path)
					had_error = true
					continue
				rows.append(PackedStringArray([key, file.get_as_text(), path]))
		rows.sort_custom(func(a: PackedStringArray, b: PackedStringArray) -> bool: return a[0] < b[0])
		if _write_csv(str(job.out), rows):
			print("Wrote %s (%d rows)" % [job.out, rows.size()])
		else:
			had_error = true
	quit(1 if had_error else 0)


func _write_csv(out_path: String, rows: Array[PackedStringArray]) -> bool:
	var lines := PackedStringArray(["keys,en,_notes"])
	for row: PackedStringArray in rows:
		var cells := PackedStringArray()
		for cell: String in row:
			cells.append(_escape(cell))
		lines.append(",".join(cells))
	var file := FileAccess.open(out_path, FileAccess.WRITE)
	if file == null:
		push_error("generate_text_csvs: cannot write " + out_path)
		return false
	file.store_string("\n".join(lines) + "\n")
	return true


func _escape(cell: String) -> String:
	if cell.contains("\"") or cell.contains(",") or cell.contains("\n") or cell.contains("\r"):
		return "\"" + cell.replace("\"", "\"\"") + "\""
	return cell
