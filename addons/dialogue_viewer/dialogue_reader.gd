extends Node
class_name DialogueReader

signal end_reached
@export var dialogue: GraphData
var readable:={}
var next_node_name: String
var end_node_name: String
var speaker: CharacterData
var is_at_end = false
func _ready() -> void:
	if !dialogue:
		push_warning("Dialogue not set")
		return
	readable = dialogue.readable
	end_node_name = readable["endNodeName"]
	var startNode = readable["startNodeName"]
	next_node_name = readable[startNode]["to_node"][0] #readable[start node name]["to_node"][from_port] = node_name

func get_next_line(selected_option = "") -> Dialogue:
	if is_at_end: return null
	var output = Dialogue.new()
	var node = readable[next_node_name]
	if node.has("character"): #is a character node
		speaker = node["character"] as CharacterData
		print(node["character"])
		next_node_name = node["to_node"][0]
		return get_next_line()
	output.speaker = speaker
	if node.has("text"): #is a text node
		output.isOption = false
		output.text = node["text"][0]
	elif node.has("options"):
		output.isOption = true
		output.options = []
		for o in node["options"]: 
			output.options.append(o)
	next_node_name = node["to_node"][0]
	if next_node_name == end_node_name:
		end_reached.emit()
		is_at_end = true
	return output
