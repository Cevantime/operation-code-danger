extends "res://ennemy/states/ennemy_state.gd"

func _process(delta):
	referer.velocity = lerp(referer.velocity, Vector2.ZERO, 15.0 * delta)
	referer.move_and_slide()
	
	
func _enter_state(previous, params = {}):
	var shooter = params.shooter
	referer.animation_player.play("shot_stomach" if shooter.is_crouching else "shot_head")
	referer.sprite_2d.scale.x = sign(shooter.global_position.x - referer.global_position.x)
	referer.velocity.x = 100.0 * sign(referer.global_position.x - shooter.global_position.x)
	await referer.animation_player.animation_finished
	if not _active:
		return
	change_state("Idle" if previous.name != "Controlled" else "Controlled")
	
	
	
