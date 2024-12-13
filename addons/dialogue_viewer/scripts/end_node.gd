@tool
extends DialogueNode
class_name EndNode

func get_node_data()-> Dictionary:
	var data = super.get_node_data()
	data["node"] = "end"
	return data
