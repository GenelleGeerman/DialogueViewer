extends Node
class_name DialogueReader

signal end_reached
@export var dialogue: GraphData
var readable:={}
var next_node_name: String
var speaker: CharacterData
var is_at_end = false
func _ready() -> void:
	if !dialogue:
		push_warning("Dialogue not set")
		return
	readable = dialogue.readable
	var startNode = readable["startNodeName"]
	next_node_name = readable[startNode]["to_node"][0] #readable[start node name]["to_node"][from_port] = node_name
#option is next_node
func get_next_line(selected_option = "") -> Dialogue:
	if is_at_end: return null
	var output = Dialogue.new()
	if readable[next_node_name] is String and readable[next_node_name] == EndNode.END:
		return end_dialogue()
	if !readable.has(next_node_name):
		push_error("Dialogue "+dialogue.resource_name+ " has incomplete connections")
		return end_dialogue()
	var node = readable[next_node_name]
	
	if node.has("character"): #is a character node
		speaker = node["character"] as CharacterData
		next_node_name = node["to_node"][0]
		return get_next_line()
	output.speaker = speaker
	if node.has("text"): #is a text node
		output.isOption = false
		output.text = node["text"][0]
		next_node_name = node["to_node"][0]
	elif node.has("options"): #is an option node
		if !selected_option.is_empty():
			var port = get_value_by_key(node["options"], selected_option)
			if port == null:
				push_error("Invalid Port")
				return end_dialogue()
			next_node_name = node["to_node"][port]
			return get_next_line()
		output.isOption = true
		output.options = node["options"].map(func(d): return d.keys()[0])
	return output

func end_dialogue():
	end_reached.emit()
	is_at_end = true
	return null

func get_value_by_key(dict_array: Array, key: String) -> Variant:
	for dict in dict_array:
		if dict.has(key):
			return dict[key]
	return null
