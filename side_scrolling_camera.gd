extends Camera2D

@export var followed_node_path: NodePath

@onready var followed_node: Node2D

var follow_the_node := true

func _ready() -> void:
	if followed_node_path:
		followed_node = get_node(followed_node_path)

func _process(_delta: float) -> void:
	if follow_the_node and is_instance_valid(followed_node) and followed_node.global_position.x > global_position.x:
		global_position.x = followed_node.global_position.x
