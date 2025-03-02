extends State

const Ennemy = preload("res://ennemy/ennemy.gd")

@onready var ennemy: Ennemy = referer

func _supports(node: Node):
	return node is Ennemy


	
