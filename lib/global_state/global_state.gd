extends Node

signal score_updated
signal lives_updated
signal level_updated

var score = 0:
	set(v):
		score = max(v, 0)
		score_updated.emit(score)


var lives = 3:
	set(v):
		lives = v
		lives_updated.emit(lives)
		
		
var level = "":
	set(v):
		level = v
		level_updated.emit(level)
		
		
var highest_score:
	get:
		if highest_score == null:
			return score
		return max(score, highest_score)


var selected_gordon = "beauvoir"


func _ready():
	highest_score = LeaderBoard.get_highest_score()
