extends ProgressBar

var value_node: Node:
	set(v):
		value_node = v
		if v == null:
			return
		max_value = value_node.get_max_value()
		value = value_node.get_value()
		if not value_node.changed.is_connected(_on_value_node_changed):
			value_node.changed.connect(_on_value_node_changed)

@export var value_node_path: NodePath:
	set(v):
		value_node_path = v
		if not is_node_ready():
			await ready
		value_node = get_node(value_node_path)
		

func _on_value_node_changed(new_value, _old_value):
	value = new_value
