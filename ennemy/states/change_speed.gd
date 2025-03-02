extends "res://ennemy/states/ennemy_state.gd"

@export var speed = 1.0

func _enter_state(_p, _params = {}):
	ennemy.target_speed = speed
	
func _exit_state(_p, _params = {}):
	ennemy.target_speed = 1.0
