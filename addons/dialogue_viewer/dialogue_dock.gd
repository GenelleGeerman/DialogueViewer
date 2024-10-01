@tool
extends VBoxContainer
class_name DialogueDock

@export var file: Resource
var text
var file_dialog: EditorFileDialog
@onready var text_edit = $HSplitContainer/TextEdit

func _ready():
	file_dialog = EditorFileDialog.new()
	add_child(file_dialog)
	file_dialog.file_selected.connect(on_file_selected)
	file_dialog.add_filter("*.tscn, scn","Scenes")
	file_dialog.add_filter("*.tres","Resource")

func clear_panel():
	pass

func _on_save_button_button_up() -> void:
	if file_dialog.current_file != "":
		prints("In save :",file_dialog.current_path," ::: ", file_dialog.current_file)
		save_file(file_dialog.current_path)
	else:
		prints("In save as:",file_dialog.current_path," ::: ", file_dialog.current_file)
		save_as()

func _on_save_as_button_button_up() -> void:
	save_as()

func _on_load_button_button_up() -> void:
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.popup_centered()

func on_file_selected(path):
	if file_dialog.file_mode == EditorFileDialog.FILE_MODE_OPEN_FILE:
		load_file(path)
	elif file_dialog.file_mode == EditorFileDialog.FILE_MODE_SAVE_FILE:
		save_file(path)


func save_as():
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.clear_filters()
	file_dialog.add_filter("*.txt ; Text Files")
	file_dialog.popup_centered()

func save_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var text = text_edit.text
		file.store_string(text)
		file.close()
		print("File saved to:", path)
	else:
		printerr("Failed to save file:", path)

func load_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()  # Read the file's contents
		text_edit.text = text  # Set the content in the TextEdit node
		file.close()
		print("File loaded from:", path)
	else:
		printerr("Failed to load file:", path)
