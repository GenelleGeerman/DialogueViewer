@tool
extends Container
class_name DialogueDock

@onready var file_name: Label = $Field/Top/InfoBox/Label
@onready var button_container: VBoxContainer = $Field/Body/DialogueScrollContainer/ButtonContainer
@onready var input_container: VBoxContainer = $Field/Body/InputScrollContainer/InputContainer
@onready var add_speaker_button = $Field/Top/Buttons/AddSpeakerButton
@onready var conversation_name = $Field/Top/Buttons/ConversationName
var dialogue_button = preload("res://addons/dialogue_viewer/scenes/dialogue_button.tscn")
var speaker_box_scene = preload("res://addons/dialogue_viewer/scenes/speaker_box.tscn")
var line_box_scene = preload("res://addons/dialogue_viewer/scenes/line_box.tscn")
var option_box_scene = preload("res://addons/dialogue_viewer/scenes/option_box.tscn")
var active_button: D_Button
var focused_speaker
var file_dialog: EditorFileDialog
var file: D_Dialogue
var dialogues: Array[D_Dialogue] = []
var dialogue_buttons: Array
var active_dialogue: D_Dialogue
enum FileType {NaN, RESOURCE, YAML, JSON}

func _ready():
	init_file_dialog()
	if dialogues.size() <= 0:
		add_speaker_button.disabled = true

func clear_panel():
	file = D_Dialogue.new()
	file_dialog.current_path = ""
	file_dialog.current_file = ""
	file_name.text = ""
	dialogues = []
	active_dialogue = null
	conversation_name.text = ""
	clear_input_container()
	if dialogues.size() <= 0:
		add_speaker_button.disabled = true
	remove_buttons()

func init_file_dialog():
	file_dialog = EditorFileDialog.new()
	add_child(file_dialog)
	file_dialog.file_selected.connect(on_file_selected)
	file_dialog.add_filter("*.tres","Resource")
	file_dialog.size = Vector2i(750,500)

func save_as():
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.clear_filters()
	file_dialog.add_filter("*.tres ; Resource Files")
	file_dialog.add_filter("*.yml, *.yaml ; Yaml Files")
	file_dialog.add_filter("*.json ; Json Files")
	file_dialog.popup_centered()

func save_file(path: String) -> void:
	init_file(path)
	file.text = path.split("/")[-1].split(".")[0].capitalize()
	active_dialogue.children = box_to_dialogue()
	file.children = dialogues
	match get_file_type(path):
		FileType.RESOURCE:
			ResourceSaver.save(file, path)
		FileType.YAML:
			var saver = FileAccess.open(path, FileAccess.WRITE)
			var exportFile = Exporter.export_yaml(file)
			saver.store_line(exportFile)
		FileType.JSON:
			var saver = FileAccess.open(path, FileAccess.WRITE)
			var exportFile = Exporter.export_json(file)
			saver.store_line(exportFile)

func load_file(path: String) -> void:
	match get_file_type(path):
		FileType.RESOURCE:
			file = ResourceLoader.load(path)
			if file is D_Dialogue:
				file_name.text = file.text
				dialogues = file.children
				remove_buttons()
				for dButton in dialogues:
					create_dialogue_button(dButton)
			else:
				printerr("Failed to load resource:", path)

func create_dialogue_button(dialogue):
	var button = dialogue_button.instantiate() as D_Button
	button_container.add_child(button)
	if dialogue.text == "":
		dialogue.text = "New Conversation"
	button.set_text(dialogue.text)
	button.pressed.connect(populate_dialogue_button.bind(dialogue))
	button.pressed.connect(set_active_button.bind(button))
	button.removed.connect(remove_dialogue.bind(dialogue))
	set_active_button(button)
	dialogue_buttons.append(button)
	button.grab_focus()
	populate_dialogue_button(dialogue)
	add_speaker_button.disabled = false

func populate_dialogue_button(dialogue: D_Dialogue):
	if active_dialogue:
		active_dialogue.children = box_to_dialogue()
	active_dialogue = dialogue
	clear_input_container()
	dialogue_to_box(dialogue)

func set_active_button(button):
	active_button = button
	conversation_name.text = active_button.get_text()

func init_file(path):
	if !file:
		file = D_Dialogue.new()
	if !active_dialogue:
		if file.children.size() > 0:
			populate_dialogue_button(file.children[0])
		else:
			active_dialogue = D_Dialogue.new()
			active_dialogue.text = ""

func box_to_dialogue()-> Array[D_Dialogue]:
	#var d = D_Dialogue.new()
	#d.text = "PARENT"
	#r_btd(input_container, d)
	#return d.children
	var output:Array[D_Dialogue] = []
	var speakerBoxes = input_container.get_children()
	for speakerBox in speakerBoxes:
		if speakerBox is not D_Speaker:
			continue
		var speakerDialogue = D_Dialogue.new()
		speakerDialogue.text = speakerBox.get_text()
		for box in speakerBox.get_children():
			if box is not D_Line:
				continue
			var lineDialogue = D_Dialogue.new()
			lineDialogue.text = box.get_text()
			lineDialogue.is_option = box.is_option
			if box.is_option:
				speakerDialogue.children[-1].children.append(lineDialogue)
			else:
				speakerDialogue.children.append(lineDialogue)
		output.append(speakerDialogue)
	return output

#func r_btd(parent, parent_dialogue: D_Dialogue = D_Dialogue.new(), grand_parent_dialogue = null ,index = 0) -> void:
	#var children = parent.get_children()
	#if children == null || children.size() == 0:
		#return
	#if children.size() <= index:
		#return
#
	#var child = children[index]
	#if child is not D_Speaker and child is not D_Line:
#
		#r_btd(parent, parent_dialogue, parent_dialogue, index + 1)
		#return
#
	#var dialogue = D_Dialogue.new()
	#dialogue.text = child.get_text()
	#var p = parent_dialogue
	#if child is D_Line:
		#dialogue.is_option = child.is_option
		#if dialogue.is_option:
			#if parent_dialogue.children.size() == 0:
				#parent_dialogue.children.append(D_Dialogue.new())
				#p = grand_parent_dialogue
#
	#p.children.append(dialogue)
	#r_btd(child, dialogue, parent_dialogue)
	#r_btd(parent, parent_dialogue, parent_dialogue, index + 1)
	#var t = p.text
	#for c in p.children:
		#t+=(" - ")
		#t+=(c.text)
	#prints(t)

func dialogue_to_box(button: D_Dialogue):
	r_dialogue_to_box(button)

func r_dialogue_to_box(dialogue:D_Dialogue, speaker_box: D_Speaker = null, index = 0):
	if dialogue.children.size() <= index:
		return
	var child = dialogue.children[index]
	var box
	if speaker_box:
		if child.is_option:
			box = option_box_scene.instantiate() as D_Line
		else:
			box = line_box_scene.instantiate() as D_Line
		speaker_box.add_box(box)
		box.is_option = child.is_option
		r_dialogue_to_box(child, speaker_box)
	else:
		box = speaker_box_scene.instantiate() as D_Speaker
		input_container.add_child(box)
		input_container.move_child(box,-1)
		r_dialogue_to_box(child, box)
	box.set_text(child.text)
	r_dialogue_to_box(dialogue, speaker_box, index+1)


func clear_input_container():
	for child in input_container.get_children():
		if child == add_speaker_button:
			continue
		child.queue_free()

func remove_buttons():
	active_button = null
	for button in button_container.get_children():
		if button is not D_Button:
			continue
		for dict in button.pressed.get_connections():
			button.pressed.disconnect(dict.callable)
		button.queue_free()

func remove_dialogue(dialogue):
	if active_dialogue == dialogue:
		clear_input_container()
	dialogues.erase(dialogue)

func get_file_type(path: String):
	if path.ends_with(".tres"):
		return FileType.RESOURCE
	elif path.ends_with(".yml") or path.ends_with(".yaml"):
		return FileType.YAML
	elif path.ends_with(".json"):
		return FileType.JSON
	return FileType.NaN

#region signal functions
func _on_close_button_pressed() -> void:
	clear_panel()

func _on_load_button_pressed() -> void:
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.popup_centered()

func _on_save_as_button_pressed() -> void:
	save_as()

func _on_save_button_pressed() -> void:
	if file_dialog.current_file == "":
		save_as()
	else:
		save_file(file_dialog.current_path)

func _on_add_dialogue_button_pressed() -> void:
	var d = D_Dialogue.new()
	d.text = conversation_name.text
	dialogues.append(d)
	create_dialogue_button(d)

func _on_add_speaker_button_pressed() -> void:
	var speaker = speaker_box_scene.instantiate() as D_Speaker
	input_container.add_child(speaker)
	speaker.add_box(line_box_scene.instantiate())

func _on_conversation_name_text_changed(new_text: String) -> void:
	if active_button:
		active_button.set_text(new_text)

func on_file_selected(path):
	match(file_dialog.file_mode):
		EditorFileDialog.FILE_MODE_OPEN_FILE:
			load_file(path)
		EditorFileDialog.FILE_MODE_SAVE_FILE:
			save_file(path)
#endregion
