extends "res://ennemy/states/ennemy_state.gd"

func _enter_state(_previous, _params = {}):
	if is_instance_valid(ennemy.targeted_player):
		await get_tree().process_frame
		if _active : change_state("Chasing")
		return
	else:
		ennemy.targeted_player = null
		
	if not ennemy.player_targeted.is_connected(_on_player_targeted):
		ennemy.player_targeted.connect(_on_player_targeted)
		
	ennemy.animation_player.play("waiting")
		

func _exit_state(_next):
	if ennemy.player_targeted.is_connected(_on_player_targeted):
		ennemy.player_targeted.disconnect(_on_player_targeted)
		
		
func _on_player_targeted(player):
	if player != null:
		change_state("Chasing")
