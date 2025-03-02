extends "res://ennemy/states/ennemy_state.gd"

func _enter_state(_previous, params = {}):
	var shooter = params.shooter
	referer.collision_layer = 0
	referer.animation_player.play("shot_stomach" if shooter.is_crouching else "shot_head")
	await referer.animation_player.animation_finished
	referer.animation_player.play("died")
	await referer.animation_player.animation_finished
	referer.global_animation_player.play("disappear")
	await referer.global_animation_player.animation_finished   
	referer.queue_free()
