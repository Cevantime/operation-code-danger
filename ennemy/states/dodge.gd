extends "res://ennemy/states/ennemy_state.gd"

func _enter_state(previous, _params = {}):
	ennemy.animation_player.play("dodge")
	await ennemy.animation_player.animation_finished
	ennemy.animation_player.play_backwards("dodge")
	await ennemy.animation_player.animation_finished
	if _active and previous.name != "Controlled":
		change_state("Idle")
	elif previous.name == "Controlled": 
		change_state("Controlled")
