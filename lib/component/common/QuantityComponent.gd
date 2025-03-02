extends Node

var component_id = Components.IDS.QUANTITY

@export var __current_quantity: int = 0

func increase(inc: int):
	inc = abs(inc)
	__current_quantity += inc
	
func decrease(dec: int):
	dec = abs(dec)
	assert(dec <= __current_quantity, "Trying to decrease quantity by too much")
	__current_quantity -= dec
	
func change(inc: int):
	increase(inc) if inc >= 0 else decrease(inc)
	
func initialize(quantity: int):
	assert(quantity >= 0, "Wrong quantity initialized")
	__current_quantity = quantity
	
func value() -> int:
	return __current_quantity
