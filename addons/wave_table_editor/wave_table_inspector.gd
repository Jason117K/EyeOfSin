@tool
extends EditorInspectorPlugin

const WaveTablePanel := preload("res://addons/wave_table_editor/wave_table_panel.gd")

## Set by plugin.gd; passed through so the panel can reach get_undo_redo().
var plugin: EditorPlugin = null


func _can_handle(object: Object) -> bool:
	return object is WaveTableHost


## _parse_begin rather than _parse_property: the host stores no wave data, so
## there is no property to bind an EditorProperty to.
func _parse_begin(object: Object) -> void:
	var panel := WaveTablePanel.new()
	panel.setup(object as WaveTableHost, plugin)
	add_custom_control(panel)
