extends Node2D
class_name Spinner

var size: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(size: int):
	self.size = size
	set_points(Vector2(-size/2, -size * sqrt(3) / 6), Vector2(0, size * sqrt(3) / 3), Vector2(size/2, (-1) * size * sqrt(3) / 6))

func set_points(point1: Vector2, point2: Vector2, point3: Vector2):
	var triangleVectorArray = PoolVector2Array()
	triangleVectorArray.append(point1)
	triangleVectorArray.append(point2)
	triangleVectorArray.append(point3)
	$Triangle.set_polygon(triangleVectorArray)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Triangle.rotate(delta * 5)
