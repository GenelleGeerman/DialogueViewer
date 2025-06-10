@tool
extends DialogueNode
class_name EndNode
const END = "end"
func get_node_data()-> Dictionary:
	var data = super.get_node_data()
	data["node"] = "end"
	return data
