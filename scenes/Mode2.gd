extends GameScene
class_name Mode2

# Called when the node enters the scene tree for the first time.
func _ready():
	triangleDropper.gameGrid.toggle_chain_mode(true)
	triangleDropper.gameGrid.set_gravity(0.2)
	triangleDropper.connect("piece_sequence_advanced", self, "_on_triangleDropper_piece_sequence_advanced")
	hud.set_time_limit(2, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_triangleDropper_piece_sequence_advanced():
	hud.get_node("HBoxContainer/VBoxContainer/ScoreDisplay").decrement_score(100)
	._on_triangleDropper_piece_sequence_advanced()