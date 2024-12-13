@tool
extends Control
class_name OptionLine
signal option_removed(option)
var text :
	get:
		return $LineEdit.text
	set(value):
		$LineEdit.text = value


func _on_delete_button_pressed() -> void:
	queue_free()
	option_removed.emit(self)
