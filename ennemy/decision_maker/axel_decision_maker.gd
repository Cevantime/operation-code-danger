extends DecisionMaker

func _on_decision():
	var active_state_name = state._active_state.name
	var distance_to_player =  ennemy.distance_to_targeted_player()
	if active_state_name == "Circling" and (distance_to_player < 45.0 or distance_to_player > 55.0):
		state.change_state("Approaching")
		state._active_state.closer = distance_to_player > 55.0
		
	

func _on_process(delta):
	if ennemy.targeted_player == null:
		return
		
	var active_state_name = state._active_state.name
	if active_state_name == "Approaching" and ennemy.distance_to_targeted_player() < 50.0:
		state.change_state("Circling")
		
