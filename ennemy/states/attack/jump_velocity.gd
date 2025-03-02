extends "res://ennemy/states/ennemy_state.gd"

@export var JUMP_SPEED = 10.0

func _enter_state(_p, _pr = {}):
	ennemy.direction = Vector2(sign(ennemy.targeted_player.global_position.x - ennemy.global_position.x), 0)
	ennemy.target_speed = JUMP_SPEED
	
func _exit_state(_next):
	ennemy.target_speed = 1.0
