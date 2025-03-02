extends "res://ennemy/states/ennemy_state.gd"

@export var animation_name: String

func _enter_state(_previous, _params = {}):
	ennemy.animation_player.play(animation_name)
	await ennemy.animation_player.animation_finished
	if not _active:
		return
	if ennemy.attack_token != null :
		if ennemy.attack_token.owner == ennemy:
			ennemy.attack_token.owner = null
		ennemy.attack_token = null
	change_state("Idle")
