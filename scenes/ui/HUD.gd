extends MarginContainer
class_name HUD

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal end_game

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay.connect("combo_done", self, "_on_ComboDisplay_combo_done")
	$HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay.connect("new_best_combo", self, "_on_ComboDisplay_new_best_combo")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_MoveCount_out_of_moves():
	emit_signal("end_game")


func _on_TimeDisplay_out_of_time():
	emit_signal("end_game")


func _on_ComboDisplay_combo_done(score):
	$HBoxContainer/VBoxContainer/ScoreDisplay.increment_score(score)


func _on_ComboDisplay_new_best_combo(score):
	$HBoxContainer/VBoxContainer/ScoreDisplay.update_best_chain_score(score)
