extends Area2D

signal entered(this)

@export var blocking := false

func _on_body_entered(_body: Node2D) -> void:
	entered.emit(self)
	queue_free()
