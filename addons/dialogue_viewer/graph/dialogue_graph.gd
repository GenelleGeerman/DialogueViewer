@tool
extends GraphEdit

class_name DialogueGraph
@onready var popup_menu = $PopupMenu
@export var character_node_scene : PackedScene
@export var text_node_scene : PackedScene 
@export var option_node_scene: PackedScene  
@export var start_node_scene : PackedScene
@export var end_node_scene: PackedScene 

var initial_position = Vector2(100, 100)
var node_index = 0
var file_dialog: EditorFileDialog
var selected_node : DialogueNode
var graph : GraphData
var encoder: GraphEncoder

func _ready() -> void:
	encoder = GraphEncoder.new()
	popup_menu.clear()
	add_valid_connections()
	init_file_dialog()

func clear_panel():
	pass

#region init
func init_file_dialog():
	file_dialog = EditorFileDialog.new()
	add_child(file_dialog)
	file_dialog.file_selected.connect(on_file_selected)
	file_dialog.add_filter("*.tres","Resource")
	file_dialog.size = Vector2i(750,500)

func add_valid_connections():
	add_valid_connection_type(DialogueNode.slot_type.CHARACTER,DialogueNode.slot_type.TEXT)
	add_valid_connection_type(DialogueNode.slot_type.CHARACTER,DialogueNode.slot_type.OPTION)
	add_valid_connection_type(DialogueNode.slot_type.OPTION,DialogueNode.slot_type.CHARACTER)
	add_valid_connection_type(DialogueNode.slot_type.TEXT,DialogueNode.slot_type.CHARACTER)
	add_valid_connection_type(DialogueNode.slot_type.TEXT,DialogueNode.slot_type.OPTION)
	add_valid_connection_type(DialogueNode.slot_type.OPTION,DialogueNode.slot_type.TEXT)
	add_valid_connection_type(DialogueNode.slot_type.OPTION,DialogueNode.slot_type.CHARACTER)
	add_valid_connection_type(DialogueNode.slot_type.START,DialogueNode.slot_type.CHARACTER)
	add_valid_connection_type(DialogueNode.slot_type.TEXT,DialogueNode.slot_type.END)
	add_valid_connection_type(DialogueNode.slot_type.OPTION,DialogueNode.slot_type.END)

#endregion

#region file operations

func on_file_selected(path):
	match(file_dialog.file_mode):
		EditorFileDialog.FILE_MODE_OPEN_FILE:
			load_file(path)
		EditorFileDialog.FILE_MODE_SAVE_FILE:
			save_file(path)

func save_as():
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.clear_filters()
	file_dialog.add_filter("*.tres ; Resource Files")
	file_dialog.popup_centered()

func save_file(path: String) -> void:
	if !FileAccess.file_exists(path):
		graph = GraphData.new()
	else: graph = ResourceLoader.load(path)
	graph.nodes.clear()
	graph.edges.clear()
	for node in get_children():
		if node is DialogueNode:
			graph.nodes.append(node.get_node_data())
	graph.edges = get_connection_list()
	graph.readable = encoder.get_readable(graph)
	graph.resource_name = path.split("/")[-1].trim_suffix(".tres")
	ResourceSaver.save(graph, path)

func load_file(path: String) -> void:
	graph = ResourceLoader.load(path)
	_on_close_button_pressed()

	for node in graph.nodes:
		var scene_path = node["scene_path"]
		var n_instance = load(scene_path).instantiate() as DialogueNode
		add_child(n_instance, true)
		move_child(n_instance, -1)
		n_instance.owner = self
		n_instance.set_node_data(node)
	for edge in graph.edges:
		connect_node(StringName(edge["from_node"]),edge["from_port"],StringName(edge["to_node"]),edge["to_port"])

#endregion

#region GRAPH OPERATIONS
func get_graph_pos():
	return DisplayServer.mouse_get_position()

func set_current_node(node):
	selected_node = node

func get_current_node():
	return selected_node

func create_node(index, port = -1, position = Vector2.ZERO):
	var node : GraphNode
	match index:
		DialogueNode.slot_type.CHARACTER:
			node = character_node_scene.instantiate()
		DialogueNode.slot_type.TEXT:
			node = text_node_scene.instantiate()
		DialogueNode.slot_type.OPTION:
			node = option_node_scene.instantiate()
		DialogueNode.slot_type.START:
			node = start_node_scene.instantiate()
		DialogueNode.slot_type.END:
			node = end_node_scene.instantiate()
	if position == Vector2.ZERO:
		position = initial_position + (node_index * Vector2(20,20))+ scroll_offset
		node_index = (node_index+1) % 10
	add_child(node, true)
	move_child(node, 1)
	node.position_offset = position
	return node

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
	var outputNode = selected_node
	var inputPort = 0
	var outputPort = port
	if isInput:
		inputNode = selected_node
		outputNode = newNode
		inputPort = port
		outputPort = 0

	if inputNode.get_input_port_count() <= 0 || outputNode.get_output_port_count() <= 0:
		return
	if is_valid_connection_type(outputNode.get_output_port_type(outputPort),inputNode.get_input_port_type(inputPort)):
		remove_connection_line(outputNode.name, outputPort)
		connect_node(outputNode.name, outputPort, inputNode.name, inputPort)

func ports_are_not_character(from_type, to_type):
	return !(from_type == DialogueNode.slot_type.CHARACTER and to_type == DialogueNode.slot_type.CHARACTER)

func _is_node_hover_valid(from, from_port, to, to_port):
	var from_type = get_node(NodePath(from)).get_output_port_type(from_port)
	var to_type = get_node(NodePath(to)).get_input_port_type(to_port)
	return to != from and ports_are_not_character(from_type, to_type)

#endregion

#region BUTTONS
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
#endregion

#region CONNECTION RULES
func _on_connection_from_empty(to_node: StringName, to_port: int, release_position: Vector2) -> void:
	if get_node(NodePath(to_node)) != selected_node:
		selected_node = get_node(NodePath(to_node))
	on_empty_popup(to_port, release_position, true)

func _on_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	if get_node(NodePath(from_node)) != selected_node:
		selected_node = get_node(NodePath(from_node))
	on_empty_popup(from_port, release_position, false)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var fromNode = get_node(NodePath(from_node)) as GraphNode
	remove_connection_line(from_node, from_port)
	connect_node(from_node,from_port,to_node,to_port)

func remove_connection_line(nodeName: StringName, port):
	var list = get_connection_list()
	for conn in list:
		if conn["from_node"] == nodeName and conn["from_port"] == port:
			disconnect_node(nodeName, conn["from_port"], conn["to_node"], conn["to_port"])

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node,from_port,to_node,to_port)

#endregion

#region POPUP MENU

func _on_popup_request(at_position: Vector2) -> void:
	var last_mouse_pos = get_graph_pos()
	if selected_node and selected_node.get_rect().has_point(at_position):
		selected_node.populate(popup_menu)
		popup_menu.popup(Rect2i(last_mouse_pos.x, last_mouse_pos.y, popup_menu.size.x, popup_menu.size.y))

func _on_popup_menu_popup_hide() -> void:
	for s in popup_menu.index_pressed.get_connections():
		if s["signal"] == popup_menu.index_pressed:
			popup_menu.call_deferred("disconnect","index_pressed",s["callable"])
#endregion

#region MENU BUTTONS
func _on_save_button_pressed() -> void:
	if file_dialog.current_file == "":
		save_as()
	else:
		save_file(file_dialog.current_path)

func _on_load_button_pressed() -> void:
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.popup_centered()

func _on_close_button_pressed() -> void:
	file_dialog.current_file = ""
	clear_connections()
	for node in get_children():
		if node is GraphNode:
			node.free()
#endregion
