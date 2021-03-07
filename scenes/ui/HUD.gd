extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal end_game

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MoveCount_out_of_moves():
	emit_signal("end_game")


func _on_TimeDisplay_out_of_time():
	emit_signal("end_game")


func _on_ComboDisplay_combo_done(extra_arg_0):
	$HBoxContainer/VBoxContainer/ScoreDisplay.increment_score(extra_arg_0)
