extends Node2D

@onready var label:Label = $Label
@onready var end:Label = $EndText
@onready var dialogue_reader: DialogueReader = $DialogueReader
@onready var option_btn_ctnr = $ScrollContainer/OptionButtonContainer
@onready var next_dialogue_btn = $Button
var selected_option = ""

func _ready() -> void:
	dialogue_reader.end_reached.connect(on_end_reached)
	option_btn_ctnr.hide()
	end.hide()
	
func _on_button_pressed() -> void:
	var dialogue = dialogue_reader.get_next_line(selected_option) as Dialogue
	selected_option = ""
	if dialogue == null: return
	label.text = (dialogue.speaker as CharacterData).character_name + ": \n" 
	if dialogue.isOption:
		
		handle_options(dialogue.options)
	else:
		label.text += dialogue.text
	$TextureRect.texture = dialogue.speaker.portrait

func handle_options(options):
	next_dialogue_btn.hide()
	option_btn_ctnr.show()
	for option in options:
		var btn = Button.new()
		btn.text = option
		btn.pressed.connect(option_pressed.bind(option))
		option_btn_ctnr.add_child(btn)

func option_pressed(option):
	next_dialogue_btn.show()
	selected_option = option
	for btn in option_btn_ctnr.get_children():
		btn.queue_free()
	_on_button_pressed()
	
func on_end_reached():
	next_dialogue_btn.hide()
	end.show()
