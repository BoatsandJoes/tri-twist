extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal out_of_moves
var startingValue: int = 0
var currentValue: int = 0
var incrementing = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(startValue: int):
	startingValue = startValue
	currentValue = startValue
	incrementing = startValue == 0
	$HBoxContainer/MovesValue.text = String(startValue)
	if !incrementing:
		$HBoxContainer/MovesLabel.text = "Moves Left "
	else:
		$HBoxContainer/MovesLabel.text = "Moves "

func make_move():
	if incrementing:
		currentValue = currentValue + 1
		$HBoxContainer/MovesValue.text = String(currentValue)
	else:
		currentValue = currentValue - 1
		$HBoxContainer/MovesValue.text = String(currentValue)
		if currentValue < 1:
			emit_signal("out_of_moves")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
