@tool
extends EditorContextMenuPlugin
## Context Menu Plugin For Editor Only Nodes Plugins
##
## Adds a simple user intuitive way to add a node to the plugin groups

var config: ConfigFile = ConfigFile.new()
var debug_grp: String
var editor_grp: String

var icon: Texture2D

func _init() -> void:
	var plugin_config = config.load("res://addons/editor_only_nodes/plugin.cfg")
	icon = load("res://addons/editor_only_nodes/at-icons/code.svg")
	
	if plugin_config == OK:
		debug_grp = config.get_value("settings", "debugonlygrp")
		editor_grp = config.get_value("settings", "editoronlygrp")
	else:
		debug_grp = "__DebugOnly"
		editor_grp = "__EditorOnly"

func _popup_menu(paths: PackedStringArray) -> void:
	if paths.is_empty():
		return

	var selected_nodes = _get_selected_nodes()
	if selected_nodes.is_empty():
		return

	var _cur_editor_only = selected_nodes[0].is_in_group(editor_grp)
	var _cur_debug_only = selected_nodes[0].is_in_group(debug_grp)
	
	# ideally this is a tickbox context menu item but was unable to see 
	# a way to do this :(
	add_context_menu_item(
		"%s Editor Only" % ("Clear" if _cur_editor_only else "Set"),
		_on_toggle_group.bind(not _cur_editor_only, editor_grp),
		icon
	)
	add_context_menu_item(
		"%s Debug Only" % ("Clear" if _cur_debug_only else "Set"),
		_on_toggle_group.bind(not _cur_debug_only, debug_grp),
		icon
	)

func _on_toggle_group(selected_nodes: Array[Node], enable: bool, group_name: String) -> void:
	var undo_redo = EditorInterface.get_editor_undo_redo()
	var current_scene = EditorInterface.get_edited_scene_root()

	undo_redo.create_action("Toggle Plugin Group")

	for node in selected_nodes:
		if enable:
			undo_redo.add_do_method(node, "add_to_group", group_name, true)
			undo_redo.add_undo_method(node, "remove_from_group", group_name)
		else:
			undo_redo.add_do_method(node, "remove_from_group", group_name)
			undo_redo.add_undo_method(node, "add_to_group", group_name, true)

	undo_redo.commit_action()
	
	if current_scene:
		EditorInterface.mark_scene_as_unsaved()

func _get_selected_nodes() -> Array[Node]:
	var nodes: Array[Node] = []
	var selection = EditorInterface.get_selection().get_selected_nodes()
	for item in selection:
		if item is Node:
			nodes.append(item)
	return nodes
