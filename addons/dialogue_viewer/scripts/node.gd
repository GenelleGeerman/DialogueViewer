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
	print("focus")
	graph.set_current_node(self)

func _on_node_deselected() -> void:
	print("unfocus")
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
	var slots = get_input_port_count()
	var color
	for i in slots:
		match left_slot_type:
			slot_type.CHARACTER:
				color = c_color
			slot_type.TEXT:
				color = t_color
			slot_type.OPTION:
				color = o_color
			slot_type.END:
				color = start_end_color
		set_slot_color_left(i, color)
		set_slot_type_left(i, left_slot_type)
	slots = get_output_port_count()
	for i in slots:
		match right_slot_type:
			slot_type.CHARACTER:
				color = c_color
			slot_type.TEXT:
				color = t_color
			slot_type.OPTION:
				color = o_color
			slot_type.START:
				color = start_end_color
		set_slot_color_right(i, color)
		set_slot_type_right(i, right_slot_type)
