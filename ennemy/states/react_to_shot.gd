extends "res://ennemy/states/ennemy_state.gd"

@export var chances_to_dodge = 0.5

func _enter_state(previous, params = {}):
	super._enter_state(previous, params)
	if not ennemy.was_shot.is_connected(_on_shot):
		ennemy.was_shot.connect(_on_shot)
	
	
func _exit_state(next):
	super._exit_state(next)
	if ennemy.was_shot.is_connected(_on_shot):
		ennemy.was_shot.disconnect(_on_shot)

func _on_shot(shooter):
	if randf() < chances_to_dodge:
		change_state("Dodge")
	else:
		referer.health_component.decrease(40.0)
		if referer.health_component.get_value() <= 0:
			change_state("Dead", {"shooter" : shooter})
		else:
			change_state("Shot", {"shooter" : shooter})
