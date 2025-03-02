@tool
extends Resource
class_name ShowResource

@export var small_poster: Texture:
	set(v):
		small_poster = v
		emit_changed()
@export var big_poster: Texture
@export var title: String
		
@export var dialogue: DialogueResource

@export_multiline var presentation_text: String
