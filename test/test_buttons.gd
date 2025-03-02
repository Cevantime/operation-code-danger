extends CanvasLayer

@onready var button: Button = $Control/Button

func _ready():
	button.grab_focus()
