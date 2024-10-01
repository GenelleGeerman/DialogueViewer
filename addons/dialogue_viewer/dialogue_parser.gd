extends Node
class_name DialogueParser


func parse(file: FileAccess) -> Dialogue:
	var dialogs: Array[Dialogue]
	var content = file.get_as_text().split("\n", true)
	var currentConv: DialogueParser
	var currentSpeaker: DialogueParser
	for line in content:
		var indent_level = get_indentation_level(line)
		line = line.strip_edges()
		if line.length() == 0:
			continue
		match indent_level:
			Dialogue.IndentLevel.CONVERSATION:
				currentConv = DialogueParser.new()
				currentConv.speaker = line.replace(":", "")
				dialogs.append(currentConv)
			Dialogue.IndentLevel.SPEAKER:
				currentSpeaker = DialogueParser.new()
				currentSpeaker.speaker = line.replace(":", "")
				currentConv.dialogs.append(currentSpeaker)
			Dialogue.IndentLevel.LINE:
				currentSpeaker.lines.append(line.replace("-", ""))
			Dialogue.IndentLevel.SELECT:
				currentSpeaker.lines.append(line.replace("-", ""))
	var output = Dialogue.new()
	output.dialogs = dialogs
	return output

func get_indentation_level(line: String) -> Dialogue.IndentLevel:
	var trimmed_line = line.lstrip(" ")
	var indent_count = line.length() - trimmed_line.length()
	return indent_count as Dialogue.IndentLevel
