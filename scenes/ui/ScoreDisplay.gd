extends Control
class_name ScoreDisplay

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func increment_score(value: int):
	score = score + value
	$VBoxContainer/HBoxContainer/ScoreValue.text = String(score).pad_zeros(12)