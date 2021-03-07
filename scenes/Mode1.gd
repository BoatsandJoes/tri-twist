extends Node2D
class_name Mode1

export (PackedScene) var TriangleDropper
var triangleDropper: TriangleDropper

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	triangleDropper = TriangleDropper.instance()
	add_child(triangleDropper)
	triangleDropper.connect("piece_sequence_advanced", self, "_on_triangleDropper_piece_sequence_advanced")
	triangleDropper.gameGrid.toggle_chain_mode(false)
	triangleDropper.gameGrid.set_gravity(0.3)

func _input(event):
	if event is InputEventKey && event.is_action_pressed("ui_escape"):
		get_tree().change_scene("scenes/ui/MainMenu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_triangleDropper_piece_sequence_advanced():
	$HUD/HBoxContainer/VBoxContainer2/MoveCount.make_move()