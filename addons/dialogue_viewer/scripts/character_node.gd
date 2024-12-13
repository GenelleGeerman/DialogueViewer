@tool
extends DialogueNode

class_name Character_Node

var file_dialog : EditorFileDialog
var character: CharacterData

@onready var portrait = $Portrait
@onready var character_name = $Info/Name
@onready var is_player = $"Info/Is Player"
@onready var select_button = $"Info/Select Button"

func _ready() -> void:
	super._ready()
	init_file_dialog()

func init_file_dialog():
	file_dialog = EditorFileDialog.new()
	add_child(file_dialog)
	file_dialog.file_selected.connect(on_file_selected)
	file_dialog.add_filter("*.tres","Resource")
	file_dialog.size = Vector2i(750,500)

func setup_character():
	select_button.text = "Change Character"
	portrait.visible = true
	portrait.texture = character.portrait
	character_name.visible = true
	character_name.text = character.character_name

func on_file_selected(path):
	if file_dialog.file_mode == EditorFileDialog.FILE_MODE_OPEN_FILE:
		print("open")
		character = ResourceLoader.load(path) as CharacterData
		if character is CharacterData:
			setup_character()

		else:
			printerr("Failed to load resource: ", path)

func _on_select_button_pressed() -> void:
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.popup_centered()

func get_node_data()-> Dictionary:
	var data = super.get_node_data()
	data["character"] = character
	return data

func set_node_data(data):
	super.set_node_data(data)
	character = data["character"]
	if character:
		setup_character()
