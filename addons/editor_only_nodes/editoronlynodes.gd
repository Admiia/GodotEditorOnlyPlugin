@tool
extends EditorPlugin
## Editor/Debug only nodes plugin

var export_plugin: EditorExportPlugin
var context_menu_plugin: EditorContextMenuPlugin
const AUTOLOAD_NAME: String = "EditorOnlyRuntimeHandler"


func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/editor_only_nodes/editor_only_runtime.gd")
	

func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	

func _enter_tree() -> void:
	export_plugin = preload("res://addons/editor_only_nodes/export_plugin.gd").new()
	add_export_plugin(export_plugin)
	
	context_menu_plugin = preload("res://addons/editor_only_nodes/context_menu_plugin.gd").new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, context_menu_plugin)
	
	
func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null
	
	remove_context_menu_plugin(context_menu_plugin)
	context_menu_plugin = null
	
