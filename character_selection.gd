extends Control

@onready var texture_rect: TextureRect = %TextureRect
@onready var bernard_button: Button = %BernardButton

func _ready() -> void:
	if not Progress.read_raw("beauvoir.salute_done"):
		texture_rect.modulate.a = 0.5
		bernard_button.disabled = true
		bernard_button.text += " (Locked)"

func _on_beauvoir_button_pressed():
	GlobalState.selected_gordon = GordonData.NAME.BEAUVOIR
	get_tree().change_scene_to_file("res://level.tscn")

func _on_bernard_button_pressed() -> void:
	GlobalState.selected_gordon = GordonData.NAME.BERNARD
	get_tree().change_scene_to_file("res://level.tscn")
