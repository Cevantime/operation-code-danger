extends TextureRect

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func start_blinking():
	animation_player.play("blink")
	
func stop_blinking():
	animation_player.stop()
	hide()
