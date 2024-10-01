extends Node
class_name Dialogue
signal on_ended

const EXIT_CODE = -1
var speaker: String = ""
var lines: Array[String] = []
var currentDialog: Dialogue
var line_index = 0
var dialog_index = 0
var dialogs: Array[Dialogue]
enum IndentLevel { CONVERSATION = 0, SPEAKER = 4, LINE = 8, SELECT = 12 }

func next_line():
	if dialogs && dialog_index < dialogs.size():
		if currentDialog != dialogs[dialog_index]:
			if currentDialog:
				currentDialog.on_ended.disconnect(onEnd)
			currentDialog = dialogs[dialog_index]
			currentDialog.on_ended.connect(onEnd)
		return currentDialog.next_line()

	line_index = line_index + 1
	if line_index >= lines.size():
		on_ended.emit()
	if lines.size() > line_index - 1:
		return lines[line_index - 1]
	return EXIT_CODE


func get_speaker():
	if lines.size() > 0:
		return speaker
	return currentDialog.get_speaker()


func onEnd():
	dialog_index = dialog_index + 1
