extends TextureButton

@export var action_names: PackedStringArray

func _on_button_down() -> void:
	for action_name in action_names:
		var event = InputEventAction.new()
		event.action = action_name
		event.pressed = true
		Input.parse_input_event(event)


func _on_button_up() -> void:
	for action_name in action_names:
		var event = InputEventAction.new()
		event.action = action_name
		event.pressed = false
		Input.parse_input_event(event)
