@tool
extends EditorPlugin

const MAIN_PANEL_SCENE = preload("res://addons/dialogue_viewer/_settings/Dock.tscn")
var main_panel: Control

func _enter_tree():
	main_panel = MAIN_PANEL_SCENE.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel)
	_make_visible(false)
	
func _exit_tree():
	if main_panel:
		main_panel.queue_free()

func _has_main_screen() -> bool:
	return true

func _make_visible(visible):
	if main_panel:
		main_panel.visible = visible
		main_panel.clear_panel()

func _get_plugin_name():
	return "Dialogue Viewer"

func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("GraphEdit", "EditorIcons")
