extends Timer

@export var min_wait_time = 0.5
@export var max_wait_time = 2.0

func _ready() -> void:
	wait_time = compute_wait_time()
	
func compute_wait_time():
	return randf_range(min_wait_time, max_wait_time)

func _on_timeout() -> void:
	if not one_shot:
		stop()
	wait_time = compute_wait_time()
	if not one_shot:
		start()
