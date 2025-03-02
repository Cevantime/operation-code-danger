@tool
extends Area2D

@onready var poster_sprite: Sprite2D = %PosterSprite

@export var show_resource: ShowResource:
	set(v):
		show_resource = v
		adapt_poster()
		show_resource.changed.connect(_on_show_changed)
		
		
func _on_show_changed():
	adapt_poster()
	

func adapt_poster():
	if not is_node_ready():
		await ready
	poster_sprite.texture = show_resource.small_poster

func _on_body_entered(body: Node2D) -> void:
	body.inspected_show = show_resource
	


func _on_body_exited(body: Node2D) -> void:
	body.inspected_show = null
