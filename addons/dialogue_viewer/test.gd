extends Node2D

@onready var label:Label = $Label
@onready var end:Label = $EndText
@onready var dialogue_reader:DialogueReader = $DialogueReader
var selected_option = ""

func _ready() -> void:
	dialogue_reader.end_reached.connect(on_end_reached)
	
func _on_button_pressed() -> void:
	var dialogue = dialogue_reader.get_next_line(selected_option) as Dialogue
	selected_option = ""
	if dialogue == null: return
	label.text = (dialogue.speaker as CharacterData).character_name + ": "
	if dialogue.isOption:
		selected_option = dialogue.options[0]
		for option in dialogue.options:
			label.text += option + "\n"
	else:
		label.text += dialogue.text
	$TextureRect.texture = dialogue.speaker.portrait

func on_end_reached():
	end.visible = true
