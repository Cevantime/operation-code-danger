extends Node2D

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var background_sprite_2d: Sprite2D = %BackgroundSprite2D


func play_emotion(emotion_name, permanently = false):
	if not is_node_ready():
		await ready
	sprite_2d.texture = load("res://asset/emotion/%s.png" % emotion_name)
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("emotion")
	await animation_player.animation_finished
	if not permanently:
		stop_emotion()
		
func stop_emotion():
	sprite_2d.hide()
	background_sprite_2d.hide()
	


func _on_background_sprite_2d_visibility_changed() -> void:
	print("visible ", background_sprite_2d.visible)
	print_stack()
