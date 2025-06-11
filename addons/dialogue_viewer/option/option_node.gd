@tool
extends DialogueNode

class_name OptionNode

signal option_removed(node: StringName, port: int)
var option_line_scene = preload("./option_line.tscn")
var option_lines := []

func get_node_data()-> Dictionary:
	var data = super.get_node_data()
	var ops = {}
	for option in option_lines:
		ops[option.text] = option.get_index()
	data["options"] = ops
	return data

func set_node_data(data):
	super.set_node_data(data)
	for option in data["options"]:
		var option_line = option_line_scene.instantiate() as OptionLine
		add_child(option_line, true)
		move_child(option_line, data["options"][option])
		option_line.text = option
		option_lines.append(option_line)
		var index = option_line.get_index()
		set_slot_enabled_right(index, true)
		set_slot_color_right(index, get_color(right_slot_type))

func _on_add_option_button_pressed() -> void:
	var option_line = option_line_scene.instantiate() as OptionLine
	add_child(option_line, true)
	var index = option_line.get_index()
	option_line.option_removed.connect(on_line_freed)
	option_lines.append(option_line)
	set_slot_enabled_right(index, true)
	set_slot_color_right(index, get_color(right_slot_type))
	set_slot_type_right(index, right_slot_type)

func on_line_freed(option):
	option_lines.erase(option)
	option_removed.emit(name, option.get_index()-1)
