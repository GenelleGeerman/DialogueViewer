@tool
extends DialogueNode
class_name StartNode

func set_node_data(data):
	super.set_node_data(data)
	$LineEdit.text = data["text"]
	
func get_node_data()-> Dictionary:
	var data = super.get_node_data()
	data["text"] = $LineEdit.text
	data["node"] = "start"
	return data
