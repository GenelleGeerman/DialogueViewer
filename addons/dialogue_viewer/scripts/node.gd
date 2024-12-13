@tool
extends GraphNode
class_name DialogueNode

var graph: GraphEdit

@export var left_slot_type :slot_type = slot_type.TEXT
@export var right_slot_type :slot_type = slot_type.TEXT
var c_color: Color = Color(0.346, 0.832, 0.842)
var t_color: Color = Color(0.77, 0.277, 0.277)
var o_color: Color = Color(0.515, 0.77, 0.277)
var start_end_color: Color = Color(0.8, 0.884, 0.981)

enum slot_type {CHARACTER = 0, TEXT = 1, OPTION = 2, START = 3, END = 4}

func _ready() -> void:
	graph = get_parent()
	update_slots()

func _on_node_selected() -> void:
	graph.set_current_node(self)
func _on_node_deselected() -> void:
	if graph.get_current_node() == self:
		graph.set_current_node(null)

func populate(pm:PopupMenu):
	pm.clear()
	pm.add_item("Remove", 1)
	pm.id_pressed.connect(on_index_pressed)

func on_index_pressed(index):
	if index == 1:
		queue_free()

func update_slots():
	for i in get_child_count():
		if is_slot_enabled_left(i):
			set_slot_color_left(i, get_color(left_slot_type))
			set_slot_type_left(i, left_slot_type)
		if is_slot_enabled_right(i):
			set_slot_color_right(i, get_color(right_slot_type))
			set_slot_type_right(i, right_slot_type)

func get_color(type: slot_type) -> Color:
	match type:
		slot_type.CHARACTER:
			return c_color
		slot_type.TEXT:
			return t_color
		slot_type.OPTION:
			return o_color
		slot_type.START:
			return start_end_color

	return Color.WHITE

func get_node_data() -> Dictionary:
	var data = {}
	data["node_name"] = name
	data["offset"] = position_offset
	data["scene_path"] = scene_file_path
	return data

func set_node_data(data):
	name = data["node_name"]
	position_offset = data["offset"]
