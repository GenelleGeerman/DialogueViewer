@tool
extends Container
class_name D_Speaker

func on_add(line_box: Container, scene_to_add):
	var scene = scene_to_add.instantiate()
	scene.added.connect(on_add)
	add_child(scene)
	move_child(scene,line_box.get_index()+1)

func get_speaker():
	return $SpeakerLabel.text

func set_speaker(text: String):
	$SpeakerLabel.text = text

func add_box(box):
	add_child(box)
	box.added.connect(on_add)
