@tool
extends CanvasLayer

@onready var poster_texture_rect: TextureRect = %PosterTextureRect

@export var title: String:
	set(v):
		title = v
		if not is_node_ready():
			await ready
		label.text = v
		
@export var text: String:
	set(v):
		text = v
		if not is_node_ready():
			await ready
		rich_text_label.text = v
		
@export var poster_texture: Texture:
	set(v):
		poster_texture = v
		if not is_node_ready():
			await ready
		poster_texture_rect.texture = v

@onready var label: Label = %Label
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
