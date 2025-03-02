extends "res://ennemy/states/ennemy_state.gd"

@export var maximum_distance = 80.0

func _process(_delta: float) -> void:
	var dist = ennemy.distance_to_targeted_player()
	if dist != null and dist > maximum_distance:
		change_state("Circling")
