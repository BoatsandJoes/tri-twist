extends GameScene
class_name Triathalon

var modeIndex = 0
var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	prep_take_your_time()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_HUD_end_game():
	if timer == null || !weakref(timer).get_ref() || timer.is_stopped():
		if (modeIndex != 2):
			# Temporarily disable dropping.
			triangleDropper.disable_dropping()
			# Clear all chains.
			triangleDropper.gameGrid.set_off_chains()
			timer = Timer.new()
			timer.one_shot = true
			timer.connect("timeout", self, "_on_timer_timeout")
			add_child(timer)
			timer.start(3.1)
		else:
			._on_HUD_end_game()

func _on_timer_timeout():
	modeIndex = modeIndex + 1
	if modeIndex == 1:
		prep_gogogo()
	elif modeIndex == 2:
		prep_dig()
	else:
		._on_timer_timeout()

func _on_triangleDropper_piece_sequence_advanced():
	if (modeIndex == 1):
		hud.get_node("HBoxContainer/VBoxContainer/ScoreDisplay").decrement_score(100)
	._on_triangleDropper_piece_sequence_advanced()

func _on_gameGrid_garbage_rows():
	._on_gameGrid_garbage_rows()
	hud.get_node("HBoxContainer/VBoxContainer/ScoreDisplay").increment_score(50000, false)