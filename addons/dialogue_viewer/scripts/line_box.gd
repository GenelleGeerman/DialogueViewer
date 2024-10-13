@tool
extends Container
class_name D_Line
signal added(line_box, scene_to_add)
@export var is_option: bool = false
@onready var line_edit = $Main/Line
var line_box_scene = "res://addons/dialogue_viewer/scenes/line_box.tscn"
var option_scene = "res://addons/dialogue_viewer/scenes/option_box.tscn"

func get_text():
	return line_edit.text

func set_text(text: String):
	line_edit.text = text

func _on_button_pressed() -> void:
	queue_free()

func _on_add_line_button_pressed() -> void:
	added.emit(self, load(line_box_scene))

func _on_add_options_button_pressed() -> void:
	added.emit(self, load(option_scene))

func set_focus():
	line_edit.grab_focus()
