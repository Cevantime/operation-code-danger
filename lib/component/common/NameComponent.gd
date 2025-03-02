extends Node

var component_id = Components.IDS.NAME

signal name_changed(new_name)
signal displayed_name_changed(new_displayed_name)

@export var entity_name: String = "" :
	set(v):
		name_changed.emit(v)
		entity_name = v

@export var displayed_name: String = "":
	set(v):
		displayed_name_changed.emit(v)
		displayed_name = v
	get:
		return entity_name if displayed_name == "" else displayed_name
