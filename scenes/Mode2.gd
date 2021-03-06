extends Node2D
class_name Mode2

export (PackedScene) var TriangleDropper
var triangleDropper: TriangleDropper
#TODO implement UI in this class

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	triangleDropper = TriangleDropper.instance()
	add_child(triangleDropper)
	triangleDropper.gameGrid.toggle_chain_mode(true)
	triangleDropper.gameGrid.set_gravity(0.05)

func _input(event):
	if event is InputEventKey && event.is_action_pressed("ui_escape"):
		get_tree().change_scene("scenes/MainMenu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
