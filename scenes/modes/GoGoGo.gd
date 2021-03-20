extends GameScene
class_name GoGoGo

# Called when the node enters the scene tree for the first time.
func _ready():
	prep_gogogo()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_triangleDropper_piece_sequence_advanced():
	hud.get_node("HBoxContainer/VBoxContainer/ScoreDisplay").decrement_score(100)
	._on_triangleDropper_piece_sequence_advanced()