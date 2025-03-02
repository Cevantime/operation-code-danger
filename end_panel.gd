extends Control

@onready var panel_container: Panel = %PanelContainer
@onready var comment_value_label: RichTextLabel = %CommentValueLabel
@onready var score_value_label: Label = %ScoreValueLabel

func _ready():
	get_tree().paused = true
	panel_container.pivot_offset = panel_container.size / 2

	var score = GlobalState.score
	var comment = ""
	if score < 1000:
		comment = "[color=red]Gordon, vous vous êtes fait tuer tellement de fois que c'est un miracle que vous ayez même réussi cette mission. Je demanderai plutôt à Gordon de s'en occuper, à l'avenir.[/color]"
	elif score < 1500:
		comment = "[color=red]Une assez piètre performance, Gordon. Vous êtes mort si souvent que j'en ai perdu le compte. Enfin, vous êtes encore parmis nous et c'est ce qui compte[/color]"
	elif score < 2000:
		comment = "[color=green]Vous vous êtes assez bien défendu, Gordon. Mais tâchez de moins mourir la prochaine fois. Vous nous coûtez cher en assurance vie.[/color]"
	elif score < 2400:
		comment = "[color=green]Une performance plus qu'honorable, Gordon. J'ai toujours su que vous étiez l'homme de la situation.[/color]"
	else:
		comment = "[color=green]Si la perfection était de ce monde, elle s'appellerait Gordon, Gordon.[/color]"

	comment_value_label.text = comment
	
	score_value_label.text = str(GlobalState.score).pad_zeros(5)

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_reload_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://character_selection.tscn")


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
