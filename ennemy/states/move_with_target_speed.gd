extends "res://ennemy/states/ennemy_state.gd"

func _process(delta):
	if ennemy.direction != Vector2.ZERO and ennemy.target_speed == 0.0:
		ennemy.target_speed = 1.0
	#elif target != null :
		#change_state("Fighting", {"target": target})
		
	if (ennemy.is_on_floor() and ennemy.direction.y > 0) or (ennemy.is_on_ceiling() and ennemy.direction.y < 0):
		ennemy.direction.x = sign(ennemy.direction.x)
		ennemy.direction.y = 0
	
		
	ennemy.move_with_target_speed(delta)
