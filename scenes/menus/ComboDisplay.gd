extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var combos: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $CompleteScorecardTimer.is_stopped():
		pass

func end_combo():
	if $CompleteScorecardTimer.is_stopped():
		$CompleteScorecardTimer.start()
		$Scorecard.set_modulate(Color(0.483521, 0.690471, 0.910156))
	elif $CompleteScorecardTimer.time_left < $CompleteScorecardTimer.wait_time / 2:
		#TODO Show our new scorecard.
		# Restart timer.
		$CompleteScorecardTimer.start()

func _on_CompleteScorecardTimer_timeout():
	$Scorecard.set_modulate(Color(1, 1, 1))
