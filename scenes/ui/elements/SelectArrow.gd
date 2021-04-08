extends Node2D
class_name SelectArrow

var movingRight = true
var size: int = 32
var leftMargin: int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	set_points(Vector2(leftMargin, 0), Vector2(leftMargin + size * sqrt(3) / 2, size / 2),
	Vector2(leftMargin + size * sqrt(3) / 2, - size / 2))

func set_points(point1: Vector2, point2: Vector2, point3: Vector2):
	var arrowVectorArray = PoolVector2Array()
	arrowVectorArray.append(point1)
	arrowVectorArray.append(point2)
	arrowVectorArray.append(point3)
	$Arrow.set_polygon(arrowVectorArray)
	arrowVectorArray.append(point1)
	$Outline.set_points(arrowVectorArray)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if movingRight:
		pass
	else:
		pass
