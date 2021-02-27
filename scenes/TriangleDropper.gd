extends Node2D
class_name TriangleDropper

export (PackedScene) var GameGrid
var grid: GameGrid


# Called when the node enters the scene tree for the first time.
func _ready():
	grid = GameGrid.instance()
	add_child(grid)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
