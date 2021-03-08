extends Node2D
class_name GameScene


export (PackedScene) var TriangleDropper
var HUD = load("res://scenes/ui/HUD.tscn")
var triangleDropper: TriangleDropper
var hud: HUD
var chains: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	triangleDropper = TriangleDropper.instance()
	add_child(triangleDropper)
	triangleDropper.set_previews_visible(3)
	triangleDropper.connect("piece_sequence_advanced", self, "_on_triangleDropper_piece_sequence_advanced")
	triangleDropper.gameGrid.connect("tumble", self, "_on_gameGrid_tumble")
	hud = HUD.instance()
	hud.set_position(Vector2(100, 100))
	hud.set_size(Vector2(1720, 780))
	add_child(hud)

func _input(event):
	if event is InputEventKey && event.is_action_pressed("ui_escape"):
		get_tree().change_scene("scenes/ui/MainMenu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_triangleDropper_piece_sequence_advanced():
	hud.get_node("HBoxContainer/VBoxContainer2/MoveCount").make_move()

func _on_gameGrid_tumble():
	hud.get_node("HBoxContainer/VBoxContainer/ScoreDisplay").increment_score(10)