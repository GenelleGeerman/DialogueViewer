@tool
extends DialogueNode

class_name TextNode


func get_node_data():
	var data = super.get_node_data()
	data["text"] = $TextEdit.text
	return data

func set_node_data(data):
	super.set_node_data(data)
	$TextEdit.text = data["text"]
