extends CanvasLayer

@onready var lives_label: Label = %LivesLabel
@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var go_label: TextureRect = %GoLabel
@onready var score_value_label: Label = %ScoreValueLabel

func _ready() -> void:
	lives_label.text = str(GlobalState.lives)
	GlobalState.lives_updated.connect(_on_lives_updated)
	update_score_value(GlobalState.score)
	GlobalState.score_updated.connect(_on_score_updated)


func update_score_value(score):
	score_value_label.text = str(int(GlobalState.score)).pad_zeros(5)


func _on_lives_updated(lives):
	lives_label.text = str(lives)


func _on_score_updated(score):
	update_score_value(score)
 

func display_go():
	go_label.start_blinking()
	
	
func hide_go():
	go_label.stop_blinking()
