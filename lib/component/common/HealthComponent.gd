extends Node
class_name HealthComponent

var component_id = Components.IDS.HEALTH
var __current_value = -1
var value:
	get:
		return get_value()

@export var initial_value: float = 100
@export var max_value: int = 100

signal changed(new_value: int, old_value: int)
signal died

func _ready():
	initial_value = min(initial_value, max_value)
	if __current_value < 0:
		set_value(initial_value)
	
	
func set_value(hp: float):
	var old = get_value()
	__current_value = clamp(0, hp, max_value)
	var new = get_value()
	changed.emit(new, old)
	if get_value() == 0:
		died.emit()
	
	
func get_value() -> int:
	return round(__current_value)
	
func get_max_value() -> int:
	return max_value


func increase(inc: float):
	inc = abs(inc)
	change(inc)
	
	
func decrease(inc: float):
	inc = abs(inc)
	change(-inc)
	
	
func change(inc):
	set_value(__current_value + inc)
	
