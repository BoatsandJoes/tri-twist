extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal out_of_moves
var startingValue: int = 0
var currentValue: int = 0
var incrementing = true
var warningsLeft = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(startValue: int):
	$HBoxContainer/MovesValue.set_modulate(Color(1,1,1))
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
		elif currentValue <= 10:
				if warningsLeft == 6:
					$HBoxContainer/MovesValue.set_modulate(Color(0.870588, 0.4, 0.117647))
					warningsLeft = 5
					#TODO sound sfx "10 moves left"
				elif currentValue <= warningsLeft:
					warningsLeft = warningsLeft - 1
					#TODO sound sfx "5 4 3 2 1 moves left"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
