extends "res://ennemy/states/ennemy_state.gd"

var clock_wise = true

func _process(_delta: float) -> void:
	var target = ennemy.targeted_player
	if target == null:
		return
		
	var direction_to_target = ennemy.direction_to_targeted_player()
	var perpendicular = Vector2(direction_to_target.y, -direction_to_target.x)
	ennemy.direction = perpendicular if clock_wise else -perpendicular 
	
	
func _on_random_range_timer_timeout() -> void:
	clock_wise = ! clock_wise
