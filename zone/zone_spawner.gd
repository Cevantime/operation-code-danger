extends "res://lib/spawners/basic_spawner.gd"

const TriggerZone = preload("res://zone/trigger_zone.gd")

@export var trigger_zone: TriggerZone

func _ready() -> void:
	super._ready()
	trigger_zone.entered.connect(_on_zone_entered)
	

func _on_zone_entered(_zone):
	spawn()
