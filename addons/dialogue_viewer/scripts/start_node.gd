@tool
extends DialogueNode
class_name StartNode

func get_node_data()-> Dictionary:
	var data = super.get_node_data()
	data["text"] = $LineEdit.text
	return data

func set_node_data(data):
	super.set_node_data(data)
	$LineEdit.text = data["text"]
