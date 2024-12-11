@tool
extends EditorPlugin

const MAIN_PANEL_SCENE = preload("res://addons/dialogue_viewer/scenes/Dock.tscn")
var main_panel: Control

func _enter_tree():
	main_panel = MAIN_PANEL_SCENE.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, main_panel)
	_make_visible(false)

func _exit_tree():
	if main_panel:
		remove_control_from_docks(main_panel)
		main_panel.queue_free()

func _make_visible(visible):
	if main_panel:
		main_panel.visible = true
		main_panel.clear_panel()

func _get_plugin_name():
	return "Dialogue Viewer"

func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("GraphEdit", "EditorIcons")
