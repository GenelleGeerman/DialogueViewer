@tool
extends Node
class_name GraphEncoder

func get_readable(graph_data: GraphData) -> Dictionary:
	var graph = graph_data
	var readable := {}

	# Find the start node
	var start_node = graph.nodes.filter(is_start_node).front()
	assert(start_node, "Start Node doesn't Exist")
	readable["startNodeName"] = start_node["node_name"]

	for edge in graph.edges:
		var from_node = graph.nodes.filter(matches_node_name.bind(edge["from_node"])).front()
		var to_node = graph.nodes.filter(matches_node_name.bind(edge["to_node"])).front()
		var from_name = from_node["node_name"]
		var node = readable.get(from_name, {})
		try_add_end_node(readable, to_node)
		add_connection(node, edge)
		try_add_text(node, from_node, edge)
		try_add_options(node, from_node)
		try_add_character(node, from_node)
		readable[from_name] = node
	return readable

# --- Helper Functions ---

func is_start_node(node: Dictionary) -> bool:
	return node.get("node") == "start"

func matches_node_name(node: Dictionary, name: String) -> bool:
	return node.get("node_name") == name

func try_add_end_node(readable: Dictionary, to_node: Dictionary) -> void:
	if to_node and to_node.get("node") == "end":
		readable[to_node["node_name"]] = "end"  # Or to_node if you need all its data

func add_connection(node: Dictionary, edge: Dictionary) -> void:
	node["to_node"] = node.get("to_node", {})
	node["to_node"][edge["from_port"]] = edge["to_node"]

func try_add_text(node: Dictionary, from_node: Dictionary, edge: Dictionary) -> void:
	if from_node.has("text"):
		node["text"] = node.get("text", {})
		node["text"][edge["from_port"]] = from_node["text"]

func try_add_options(node: Dictionary, from_node: Dictionary) -> void:
	if !from_node.has("options"): return
	var ops = []
	for option in from_node["options"]:
		ops.append({option: int(from_node["options"][option]) - 1})  # Adjust for port offset
	ops.sort_custom(func(a,b): a.values()[0] < b.values()[0])
	print(ops)
	node.set("options", ops)
	
func try_add_character(node: Dictionary, from_node: Dictionary) -> void:
	if from_node.has("character"):
		node["character"] = from_node["character"]
	if from_node.has("node"):
		node["node"] = from_node["node"]
