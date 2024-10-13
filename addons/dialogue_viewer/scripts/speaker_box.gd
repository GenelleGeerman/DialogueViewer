@tool
extends Container
class_name D_Speaker
@onready var speaker_label = $HBoxContainer/SpeakerLabel

func on_add(line_box: Container, scene_to_add):
	var scene = scene_to_add.instantiate()
	add_box(scene)
	move_child(scene, line_box.get_index()+1)

func get_text():
	return speaker_label.text

func set_text(text: String):
	speaker_label.text = text

func add_box(box: D_Line):
	add_child(box)
	box.added.connect(on_add)
	box.set_focus()

func _on_delete_button_pressed() -> void:
	queue_free()
