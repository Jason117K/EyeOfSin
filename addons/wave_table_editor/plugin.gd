@tool
extends EditorPlugin

const WaveTableInspector := preload("res://addons/wave_table_editor/wave_table_inspector.gd")

var _inspector: EditorInspectorPlugin = null


func _enter_tree() -> void:
	_inspector = WaveTableInspector.new()
	_inspector.plugin = self
	add_inspector_plugin(_inspector)


func _exit_tree() -> void:
	if _inspector != null:
		remove_inspector_plugin(_inspector)
		_inspector = null
