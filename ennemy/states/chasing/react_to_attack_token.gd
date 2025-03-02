extends "res://ennemy/states/ennemy_state.gd"


func _enter_state(_previous, _params = {}):
	if ennemy.attack_token != null:
		await get_tree().process_frame
		if _active:
			ennemy.fight()
			return
	if not ennemy.receive_attack_token.is_connected(_on_attack_token_received):
		ennemy.receive_attack_token.connect(_on_attack_token_received)
	
func _exit_state(_next):
	if ennemy.receive_attack_token.is_connected(_on_attack_token_received):
		ennemy.receive_attack_token.disconnect(_on_attack_token_received)
	
func _on_attack_token_received(_token):
	ennemy.fight()
