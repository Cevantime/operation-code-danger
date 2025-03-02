extends "res://ennemy/states/ennemy_state.gd"

@export var minimum_distance = 60.0
@export var maximum_distance = 100.0

func _process(_delta: float) -> void:
	var dist = ennemy.distance_to_targeted_player()
	if dist != null and dist  < minimum_distance:
		change_state("MovingAway")
	elif dist != null and dist > maximum_distance:
		change_state("Approaching")
