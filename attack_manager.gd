class_name AttackManager extends Node

class AttackToken:
	var owner
	var left
	
	func _init(o: Node2D, l: bool):
		owner = o
		left = l
	
var tokens: Array[AttackToken] = [
	AttackToken.new(null, true),
	AttackToken.new(null, false)
]


func _on_timer_timeout() -> void:
	var ennemies_without_token = get_tree().get_nodes_in_group("ennemy").filter(func(e): return e.attack_token == null)
	ennemies_without_token.shuffle()
	for unused_token in tokens.filter(func(t): return not is_instance_valid(t.owner)):
		for i in ennemies_without_token.size():
			var ennemy = ennemies_without_token[i]
			if try_give_token(ennemy, unused_token):
				break
		
	ennemies_without_token = get_tree().get_nodes_in_group("ennemy").filter(func(e): return e.attack_token == null)
	for unused_token in tokens.filter(func(t): return not is_instance_valid(t.owner)):
		for i in ennemies_without_token.size():
			var ennemy = ennemies_without_token[i]
			if give_token(ennemy, unused_token):
				break
		
func try_give_token(ennemy, token):
	if not ennemy.is_node_ready() or ennemy.attack_token != null or not is_instance_valid(ennemy.targeted_player):
		return false
	var dir = ennemy.direction_to_targeted_player()
	if (dir.x > 0 and token.left) or (dir.x < 0 and not token.left):
		ennemy.attack_token = token
		token.owner = ennemy
		return true
	return false

func give_token(ennemy, token):
	if not ennemy.is_node_ready() or ennemy.attack_token != null or not is_instance_valid(ennemy.targeted_player):
		return false
	ennemy.attack_token = token
	token.owner = ennemy
	return true
