extends Node
## Editor/Debug only nodes runtime handling
## 
## Handles the plugin behaviour for non-exported builds when the export plugin
## has not yet ran on the scenes.
## Note: this may have a minor performance impact when new nodes are added to the scene


var config: ConfigFile = ConfigFile.new()
var debug_grp: String
var editor_grp: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var plugin_config = config.load("res://addons/editor_only_nodes/plugin.cfg")
	
	if plugin_config == OK:
		debug_grp = config.get_value("settings", "debugonlygrp")
		editor_grp = config.get_value("settings", "editoronlygrp")
	else:
		debug_grp = "__DebugOnly"
		editor_grp = "__EditorOnly"
	
	if OS.has_feature("editor"):
		strip_chilren_recursive(get_tree().root)
	else:
		# disable if not in editor - this plugin doesnt need to be built into the release build
		self.process_mode = Node.PROCESS_MODE_DISABLED


func _enter_tree() -> void:
	if OS.has_feature("editor"):
		get_tree().node_added.connect(_on_node_added)
		
func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)
	
func _on_node_added(node: Node) -> bool:
	if node.is_in_group(editor_grp):
		node.queue_free()
		return true
	return false
		
func strip_chilren_recursive(node: Node) -> void:
	for child in node.get_children():	
		var stripped: bool = _on_node_added(child)
		if not stripped and child.get_child_count() > 0:
			strip_chilren_recursive(child)
