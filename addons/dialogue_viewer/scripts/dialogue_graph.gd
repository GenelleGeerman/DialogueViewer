@tool
extends GraphEdit

class_name DialogueGraph
@onready var popup_menu = $PopupMenu
var character_node_scene = preload("res://addons/dialogue_viewer/scenes/Character Node.tscn")
var text_node_scene = preload("res://addons/dialogue_viewer/scenes/Text Node.tscn")
var option_node_scene = preload("res://addons/dialogue_viewer/scenes/Option Node.tscn")
var start_node_scene = preload("res://addons/dialogue_viewer/scenes/Start Node.tscn")
var end_node_scene = preload("res://addons/dialogue_viewer/scenes/End Node.tscn")

var initial_position = Vector2(100, 100)
var node_index = 0

var node : GraphNode

func _ready() -> void:
	popup_menu.clear()
	add_valid_connection_type(DialogueNode.slot_type.CHARACTER,DialogueNode.slot_type.TEXT)
	add_valid_connection_type(DialogueNode.slot_type.TEXT,DialogueNode.slot_type.CHARACTER)
	add_valid_connection_type(DialogueNode.slot_type.TEXT,DialogueNode.slot_type.OPTION)
	add_valid_connection_type(DialogueNode.slot_type.OPTION,DialogueNode.slot_type.TEXT)
	add_valid_connection_type(DialogueNode.slot_type.OPTION,DialogueNode.slot_type.CHARACTER)
	add_valid_connection_type(DialogueNode.slot_type.START,DialogueNode.slot_type.CHARACTER)
	add_valid_connection_type(DialogueNode.slot_type.TEXT,DialogueNode.slot_type.END)
	add_valid_connection_type(DialogueNode.slot_type.OPTION,DialogueNode.slot_type.END)

func clear_panel():
	pass

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Draggable

func _drop_data(at_position: Vector2, data: Variant) -> void:
	pass
func get_graph_pos():
	return DisplayServer.mouse_get_position()
#region POPUP MENU

func _on_popup_request(at_position: Vector2) -> void:
	var last_mouse_pos = get_graph_pos()
	if node and node.get_rect().has_point(at_position):
		node.populate(popup_menu)
		popup_menu.popup(Rect2i(last_mouse_pos.x, last_mouse_pos.y, popup_menu.size.x, popup_menu.size.y))

func _on_popup_menu_popup_hide() -> void:
	for s in popup_menu.index_pressed.get_connections():
		if s["signal"] == popup_menu.index_pressed:
			popup_menu.call_deferred("disconnect","index_pressed",s["callable"])

func set_current_node(n):
	node = n

func get_current_node():
	return node
#endregion


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	connect_node(from_node,from_port,to_node,to_port)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node,from_port,to_node,to_port)

func create_node(index, port = -1, position = Vector2.ZERO):
	var n : GraphNode
	match index:
		DialogueNode.slot_type.CHARACTER:
			n = character_node_scene.instantiate()
		DialogueNode.slot_type.TEXT:
			n = text_node_scene.instantiate()
		DialogueNode.slot_type.OPTION:
			n = option_node_scene.instantiate()
		DialogueNode.slot_type.START:
			n = start_node_scene.instantiate()
		DialogueNode.slot_type.END:
			n = end_node_scene.instantiate()
	if position == Vector2.ZERO:
		position = initial_position + (node_index * Vector2(20,20))+ scroll_offset
		node_index = (node_index+1) % 10
	add_child(n)
	n.position_offset = position
	return n

func _on_character_node_button_pressed() -> void:
	create_node(DialogueNode.slot_type.CHARACTER)
func _on_text_node_button_pressed() -> void:
	create_node(DialogueNode.slot_type.TEXT)
func _on_option_node_button_pressed() -> void:
	create_node(DialogueNode.slot_type.OPTION)
func _on_start_node_button_pressed() -> void:
	create_node(DialogueNode.slot_type.START)
func _on_end_node_button_pressed() -> void:
	create_node(DialogueNode.slot_type.END)


func _on_connection_from_empty(to_node: StringName, to_port: int, release_position: Vector2) -> void:
	if get_node(NodePath(to_node)) != node:
		node = get_node(NodePath(to_node))
	on_empty_popup(to_port, release_position, true)
	prints("to_port: ",to_port)


func _on_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	if get_node(NodePath(from_node)) != node:
		node = get_node(NodePath(from_node))
	on_empty_popup(from_port, release_position, false)
	prints("from_port: ",from_port)

func on_empty_popup(port, pos, isInputPort: bool):
	popup_menu.clear()
	popup_menu.add_item("Character Node", 0)
	popup_menu.add_item("Text Node", 1)
	popup_menu.add_item("Option Node", 2)
	popup_menu.add_item("Start Node", 3)
	popup_menu.add_item("End Node", 4)
	var last_mouse_pos = get_graph_pos()
	popup_menu.popup(Rect2i(last_mouse_pos.x, last_mouse_pos.y, popup_menu.size.x, popup_menu.size.y))
	popup_menu.index_pressed.connect(empty_selected.bind(port, pos, isInputPort))

func empty_selected(index, port, pos, isInput):
	var newNode = create_node(index, port, (pos+scroll_offset)/zoom)
	var inputNode = newNode
	var outputNode = node
	var inputPort = 0
	var outputPort = port
	if isInput:
		inputNode = node
		outputNode = newNode
		inputPort = port
		outputPort = 0

	if is_valid_connection_type(outputNode.get_output_port_type(outputPort),inputNode.get_input_port_type(inputPort)):
		connect_node(outputNode.name, outputPort, inputNode.name, inputPort)

func is_valid_connection_type(from_type: int, to_type: int):
	return super.is_valid_connection_type(from_type,to_type)

func _is_node_hover_valid(from, from_port, to, to_port):
	var from_type = get_node(NodePath(from)).get_output_port_type(from_port)
	var to_type = get_node(NodePath(to)).get_output_port_type(to_port)
	return to!=from and ports_are_not_character(from_type, to_type)

func ports_are_not_character(from_type, to_type):
	return !(from_type == DialogueNode.slot_type.CHARACTER and to_type == DialogueNode.slot_type.CHARACTER)
