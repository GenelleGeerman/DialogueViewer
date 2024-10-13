extends Resource
class_name D_Dialogue
enum IndentLevel { CONVERSATION = 0, SPEAKER = 4, LINE = 8, SELECT = 12 }

@export var text: String
@export var children: Array[D_Dialogue]
@export var is_option: bool = false
