extends EditorExportPlugin
## Editor/Debug only nodes export time handling
## 
## Handles the main behaviour for the plugin, fully stripping nodes from the exported runtime


var config: ConfigFile = ConfigFile.new()
enum release_type {NONE, RELEASE, DEBUG}
var project_release: int = release_type.NONE

func _get_name() -> String:
	return "DebugOnlyStripper"
	
func _begin_customize_scenes(platform: EditorExportPlatform, features: PackedStringArray) -> bool:
	if "debug" in features:
		project_release = release_type.DEBUG
	elif "release" in features:
		project_release = release_type.RELEASE
	else:
		return false
	print("[DEBUG NODE STRIPPER] Stripping nodes in mode: %s" % release_type.keys()[project_release])
	return true
	
func _end_customize_scenes() -> void:
	project_release = release_type.NONE
	print("[DEBUG NODE STRIPPER] Finished Node Stripping")
	
func _get_customization_configuration_hash() -> int:
	return "EditorOnlyStripper_v1".hash()
	
func _customize_scene(scene: Node, path: String) -> Node:
	if not scene:
		return null
	
	var _modified = _strip_editor_only_nodes(scene)
	
	if _modified:
		return scene
	else:
		return null
	
const main_script = preload("res://addons/editor_only_nodes/editoronlynodes.gd")
var auto_load_val: String = ""
func _export_begin(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	var auto_load_setting: String = "autoload/%s" % main_script.AUTOLOAD_NAME
	if ProjectSettings.has_setting(auto_load_setting):
		auto_load_val = ProjectSettings.get_setting(auto_load_setting)
		ProjectSettings.set_setting(auto_load_val, null)
		ProjectSettings.save()
		print("[DEBUG NODE STRIPPER] Disabled plugin autoload for export.")
		
func _export_end() -> void:
	if auto_load_val != "":
		var auto_load_setting: String = "autoload/%s" % main_script.AUTOLOAD_NAME
		ProjectSettings.set_setting(auto_load_setting, auto_load_val)
		ProjectSettings.save()
		auto_load_val = ""
		print("[DEBUG NODE STRIPPER] Restored plugin auto load settings.")
		
	
func _strip_editor_only_nodes(root: Node) -> bool:
	var err = config.load("res://addons/editor_only_nodes/plugin.cfg")
	var debug_grp: String
	var editor_grp: String
	if err == OK:
		debug_grp = config.get_value("settings", "debugonlygrp")
		editor_grp = config.get_value("settings", "editoronlygrp")
	else:
		debug_grp = "__DebugOnly"
		editor_grp = "__EditorOnly"
	var _modified = false
	
	for idx in range(root.get_child_count() - 1, -1, -1):
		var child = root.get_child(idx)
		
		var strip_node: bool = child.is_in_group(editor_grp)
		if project_release == release_type.RELEASE:
			strip_node = strip_node or child.is_in_group(debug_grp)
		
		if strip_node:
			root.remove_child(child)
			child.free()
			_modified = true
		else:
			if _strip_editor_only_nodes(child):
				_modified = true
				
	return _modified
		
