extends PointLight2D

const TriggerZone = preload("res://zone/trigger_zone.gd")

@export var trigger_zone: TriggerZone

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

func _ready() -> void:
	trigger_zone.entered.connect(_on_zone_entered)
	

func _on_zone_entered(_zone):
	animation_player.play("alternate")

func stop():
	audio_stream_player_2d.stop()
	animation_player.stop()
	energy = 0
