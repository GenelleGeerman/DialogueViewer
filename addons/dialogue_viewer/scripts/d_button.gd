@tool
extends Container
class_name D_Button

signal pressed
signal removed
@onready var conversation_button = $ConversationButton

func _on_conversation_button_pressed() -> void:
	pressed.emit()

func get_text() -> String:
	return conversation_button.text

func set_text(new_text: String):
	conversation_button.text = new_text

func grab_focus():
	conversation_button.grab_focus()

func _on_delete_button_pressed() -> void:
	removed.emit()
	queue_free()
