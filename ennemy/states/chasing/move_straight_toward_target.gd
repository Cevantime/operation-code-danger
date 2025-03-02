extends "res://ennemy/states/ennemy_state.gd"

@export var closer := true

func _process(_delta: float) -> void:
	ennemy.direction = ennemy.direction_to_targeted_player()
	if not closer:
		ennemy.direction = - ennemy.direction
	
