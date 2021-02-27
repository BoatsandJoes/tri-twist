extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (PackedScene) var GameGrid
var grid: GameGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	grid = GameGrid.instance()
	add_child(grid)

func _input(event):
	if event is InputEventKey && event.is_action_pressed("ui_escape"):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
