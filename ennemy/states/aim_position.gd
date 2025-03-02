extends "res://ennemy/states/ennemy_state.gd"

var attack: Attack
var token: AttackManager.AttackToken

@onready var random_range_timer: Timer = %RandomRangeTimer

func _enter_state(_previous, params = {}):
	if not is_instance_valid(ennemy.targeted_player):
		await get_tree().process_frame
		if _active:
			change_state("Idle")
			return
		
	attack = params.attack
	token = params.token
	if not random_range_timer.timeout.is_connected(_on_random_range_timer_timeout):
		random_range_timer.timeout.connect(_on_random_range_timer_timeout)
	if not ennemy.decision_timer.timeout.is_connected(_on_decision_timer_timeout):
		ennemy.decision_timer.timeout.connect(_on_decision_timer_timeout)
	
func _exit_state(_next):
	if ennemy.decision_timer.timeout.is_connected(_on_decision_timer_timeout):
		ennemy.decision_timer.timeout.disconnect(_on_decision_timer_timeout)
	if random_range_timer.timeout.is_connected(_on_random_range_timer_timeout):
		random_range_timer.timeout.disconnect(_on_random_range_timer_timeout)
	
func _on_decision_timer_timeout():
	if not is_instance_valid(ennemy.targeted_player):
		change_state("Idle")
		return
		
	set_process(true)
		
		
func _process(_delta: float) -> void:
	ennemy.direction = compute_direction()
		

	
func compute_direction() -> Vector2:
	if ennemy.targeted_player == null:
		return Vector2.ZERO
		
	var semi_range = compute_attack_range_length()
	var offset = attack.attack_range_min + semi_range
	if token.left:
		offset = - offset
	
	var target_position = ennemy.targeted_player.global_position + Vector2(offset, 0)
	var player_position = ennemy.targeted_player.global_position
	var diff_to_target = target_position - ennemy.global_position
	var dir_to_target = diff_to_target.normalized()
	
	var dist = diff_to_target.length()
	
	if dist < semi_range:
		set_process(false)
		return Vector2.ZERO
	
	if sign(target_position.x - player_position.x) == sign(ennemy.global_position.x - player_position.x):
		return dir_to_target
	else:
		if diff_to_target.length() > 2.0 * attack.attack_range_max:
			return dir_to_target
		else:
			var dir_to_player = player_position - ennemy.global_position
			var dir = Vector2(dir_to_player.y, -dir_to_player.x).normalized()
			return dir

func compute_attack_range_length():
	return  (attack.attack_range_max - attack.attack_range_min) / 2.0
	
func _on_random_range_timer_timeout() -> void:
	if not is_instance_valid(ennemy.targeted_player):
		return
	var semi_range = compute_attack_range_length()
	var offset = attack.attack_range_min + semi_range
	if token.left:
		offset = - offset
	
	var target_position = ennemy.targeted_player.global_position + Vector2(offset, 0)

	var diff_to_target = target_position - ennemy.global_position
	
	var dist = diff_to_target.length()
	
	if dist < semi_range:
		change_state(attack.attack_state)
