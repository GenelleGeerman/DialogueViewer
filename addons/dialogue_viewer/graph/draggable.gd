@tool
extends TextureRect

class_name Draggable

@export var preview_texture: Texture2D
func _get_drag_data(at_position: Vector2) -> Variant:
	set_preview()
	return self

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Texture2D

func _drop_data(at_position: Vector2, data: Variant) -> void:
	texture = data

func set_preview():
	var preview = TextureRect.new()
	preview.texture = preview_texture
	preview.expand_mode = 1
	preview.size = Vector2(30,30)
	set_drag_preview(preview)
