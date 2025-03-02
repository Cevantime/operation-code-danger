extends "res://ennemy/states/ennemy_state.gd"

func _process(_delta):
	if ennemy.targeted_player != null:
		ennemy.sprite_2d.scale.x = sign(ennemy.targeted_player.global_position.x - ennemy.global_position.x)
		if ennemy.velocity.length_squared() > 40.0:
			ennemy.animation_player.play("walking")
		else:
			ennemy.animation_player.play("waiting")
