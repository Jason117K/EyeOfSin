## One demon-pair synergy: identity, codex location, description text.
class_name SynergyDefinition extends Resource

## Unlock/lookup key, e.g. "CrawlerOcculum" (source then target). Each demon
## word capitalizes ONLY its first letter — "Spinalocculum", not
## "SpinalOcculum" — so a pair id can be split on capital letters.
@export var id: StringName
## Buff giver, by true name (e.g. "SpinalOcculum").
@export var source_demon: StringName
## Buff receiver, by true name. Also the codex page owner.
@export var target_demon: StringName
@export var display_name: String
## res://_Assets/Text/TextFiles/Synergies/{Target}{Source}.txt — filenames use
## true-name spelling and are case-sensitive in exports.
@export_file("*.txt") var description_file: String
## Which demon page the codex opens for this synergy (true name).
@export var codex_page: StringName
## Which _on_alt_N_pressed tab on that page shows this synergy.
@export var codex_alt_index: int


## Synergy ids lowercase everything after each word's first letter
## ("SpinalOcculum" -> "Spinalocculum"). Unknown pairs simply produce an id
## with no catalog entry, which consumers treat as "no synergy".
static func make_id(source_true_name: String, target_true_name: String) -> StringName:
	return StringName(_id_word(source_true_name) + _id_word(target_true_name))


static func _id_word(true_name: String) -> String:
	if true_name.is_empty():
		return ""
	return true_name.substr(0, 1).to_upper() + true_name.substr(1).to_lower()
