@tool
extends Container
class_name D_Line
signal added(line_box, scene_to_add)
@export var is_option: bool = false
var line_box_scene = preload("res://addons/dialogue_viewer/scenes/line_box.tscn")
var option_scene = preload("res://addons/dialogue_viewer/scenes/option_box.tscn")

func get_text():
	return $Main/Line.text

func set_text(text: String):
	$Main/Line.text = text

func _on_button_pressed() -> void:
	queue_free()

func _on_add_line_button_pressed() -> void:
	added.emit(self, line_box_scene)

func _on_add_options_button_pressed() -> void:
	added.emit(self, option_scene)

func _show_buttons() -> void:
	$AddButtonsContainer.visible = true

func _hide_buttons() -> void:
	$AddButtonsContainer.visible = false
	$Main/Line.release_focus()
