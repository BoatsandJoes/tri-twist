extends Node2D
class_name GameScene

export (PackedScene) var TriangleDropper
var triangleDropper: TriangleDropper
#TODO implement UI in this class

# Called when the node enters the scene tree for the first time.
func _ready():
	triangleDropper = TriangleDropper.instance()
	add_child(triangleDropper)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
