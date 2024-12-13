@tool
extends DialogueNode

class_name OptionNode
var option_line_scene = preload("res://addons/dialogue_viewer/scenes/option_line.tscn")
var options = []

func get_node_data()-> Dictionary:
	var data = super.get_node_data()
	var ops = []
	for option in options:
		ops.append(option.text)
	data["options"] = ops
	return data

func set_node_data(data):
	super.set_node_data(data)
	for option in data["options"]:
		var option_line = option_line_scene.instantiate() as OptionLine
		add_child(option_line,true)
		option_line.text = option
		options.append(option_line)
		set_slot_enabled_right(get_child_count()-1, true)
		set_slot_color_right(get_child_count()-1, get_color(right_slot_type))

func _on_add_option_button_pressed() -> void:
	var option_line = option_line_scene.instantiate() as OptionLine
	var index = get_child_count() #TODO find a better way to do this
	add_child(option_line,true)
	option_line.option_removed.connect(on_line_freed)
	options.append(option_line)
	set_slot_enabled_right(index, true)
	set_slot_color_right(index, get_color(right_slot_type))
	set_slot_type_right(index, right_slot_type)

func on_line_freed(option):
	options.erase(option)
