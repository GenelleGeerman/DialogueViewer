@tool
extends Node

class_name Exporter

static func export_yaml(file, path):
	var output = ""
	for d in file.dialogues:
		output += traverse_dialogue(d, "", 0)
	var saver = FileAccess.open(path, FileAccess.WRITE)
	saver.store_line(output)

static func export_json(file, path):
	var j = JSON.new()
	var jString = j.stringify(file)
	var saver = FileAccess.open(path, FileAccess.WRITE)
	saver.store_line(jString)

static func traverse_dialogue(dialogue: D_Dialogue, output: String, indent_level: int) -> String:
	var prefix = ""
	var suffix = ""
	if indent_level < 2:
		suffix = ":"
	else:
		prefix = "-"

	output += get_indentation(indent_level) + prefix + dialogue.text + suffix + "\n"
	if dialogue.children != null:
		for child in dialogue.children:
			traverse_dialogue(child, output, indent_level + 1)
	return output

static func get_indentation(indent_level: int) -> String:
	var string = ""
	for i in range(indent_level):
		string += "	"
	return string

func parse_yaml(file: FileAccess) -> D_Dialogue:
	var dialogs: Array[D_Dialogue]
	var content = file.get_as_text().split("\n", true)
	var currentConv: DialogueParser
	var currentSpeaker: DialogueParser
	for line in content:
		var indent_level = get_indentation_level(line)
		line = line.strip_edges()
		if line.length() == 0:
			continue
		match indent_level:
			D_Dialogue.IndentLevel.CONVERSATION:
				currentConv = DialogueParser.new()
				currentConv.speaker = line.replace(":", "")
				dialogs.append(currentConv)
			D_Dialogue.IndentLevel.SPEAKER:
				currentSpeaker = DialogueParser.new()
				currentSpeaker.speaker = line.replace(":", "")
				currentConv.dialogs.append(currentSpeaker)
			D_Dialogue.IndentLevel.LINE:
				currentSpeaker.lines.append(line.replace("-", ""))
			D_Dialogue.IndentLevel.SELECT:
				currentSpeaker.lines.append(line.replace("-", ""))
	var output = D_Dialogue.new()
	output.dialogs = dialogs
	return output

func get_indentation_level(line: String) -> D_Dialogue.IndentLevel:
	var trimmed_line = line.lstrip(" ")
	var indent_count = line.length() - trimmed_line.length()
	return indent_count as D_Dialogue.IndentLevel
