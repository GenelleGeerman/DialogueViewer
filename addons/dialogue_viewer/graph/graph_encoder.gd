@tool
extends Node
class_name GraphEncoder

func get_readable(graphData: GraphData):
	var	graph = graphData
	
	var starts = graph.nodes.filter(get_start)
	assert(starts != null && !starts.is_empty(), "Start Node doesn't Exist")
	var startNode = starts[0]
	
	var ends = graph.nodes.filter(get_end)
	assert(ends != null && !ends.is_empty(), "End Node doesn't Exist")
	var endNode = ends[0]
	var readable = {}
	readable["startNodeName"] = startNode["node_name"] 
	readable["endNodeName"] = endNode["node_name"]
	for edge in graph.edges:
		var node = {}
		var fromNode = graph.nodes.filter(find_node.bind(edge["from_node"]))[0]
		if readable.has(fromNode["node_name"]): node = readable[fromNode["node_name"]]
		if !node.has("to_node"): node["to_node"] = {}
		node["to_node"][edge["from_port"]] = edge["to_node"]
		if fromNode.has("text"):
			if !node.has("text"): node["text"] = {}
			node["text"][edge["from_port"]] = fromNode["text"]
		if fromNode.has("options"):
			for option in fromNode["options"]:
				if !node.has("options"): node["options"] = {}
				node["options"][option] = (fromNode["options"][option] as int)-1 # -1 since ports start at 1 due to offset
		readable[fromNode["node_name"]] = node
		if fromNode.has("character"):
			node["character"] = fromNode["character"]
	return readable

func find_edge(edge, nodeName):
	return edge["from_node"] == nodeName
	
func find_node(node, nodeName):
	return node["node_name"] == nodeName

func get_start(node: Dictionary):
	return node.has("node") and node["node"] == "start"

func get_end(node: Dictionary):
	return node.has("node") and node["node"] == "end"
