extends Area2D

var size: int
const colors = [Color.royalblue, Color.crimson]
var leftColor: int
var rightColor: int
var verticalColor: int
var pointFacingUp = false
var triangleFocused = false

func _ready():
	pass

# Called when the node enters the scene tree for the first time.
func init(triangleSize: int):
	size = triangleSize
	# Define vertices
	var baseVectorArray = PoolVector2Array()
	baseVectorArray.append(Vector2(0, 0))
	baseVectorArray.append(Vector2(size, 0))
	baseVectorArray.append(Vector2(size/2, size * sqrt(3) / 2))
	$CollisionPolygon2D.set_polygon(baseVectorArray)
	# Define vertices and color and position of children
	# left
	leftColor = randi() % colors.size()
	$LeftEdge.set_color(colors[leftColor])
	var leftEdgeVectorArray = PoolVector2Array()
	leftEdgeVectorArray.append(Vector2(0, 0))
	leftEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 2))
	leftEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 6))
	$LeftEdge.set_polygon(leftEdgeVectorArray)
	# right
	rightColor = randi() % colors.size()
	$RightEdge.set_color(colors[rightColor])
	var rightEdgeVectorArray = PoolVector2Array()
	rightEdgeVectorArray.append(Vector2(size, 0))
	rightEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 2))
	rightEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 6))
	$RightEdge.set_polygon(rightEdgeVectorArray)
	# vertical
	verticalColor = randi() % colors.size()
	$VerticalEdge.set_color(colors[verticalColor])
	var verticalEdgeVectorArray = PoolVector2Array()
	verticalEdgeVectorArray.append(Vector2(0, 0))
	verticalEdgeVectorArray.append(Vector2(size, 0))
	verticalEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 6))
	$VerticalEdge.set_polygon(verticalEdgeVectorArray)
	# offset so the center is in the center
	#translate(Vector2(-size/2,-(size * tan(PI/6))))

func flip():
	scale = Vector2(1, scale[1] * -1)
	#TODO position fix should work no matter whether we are flipping up or down
	position = Vector2(position[0], position[1] + size * 0.87)
	pointFacingUp = !pointFacingUp

func topple(direction: int):
	# 1 is right, -1 is left
	# TODO
	pass

func spin(direction: int):
	var tempVerticalColor = verticalColor
	var tempLeftColor = leftColor
	# -1 is counterclockwise, 1 is clockwise
	if (direction == -1 && !pointFacingUp) || (direction == 1 && pointFacingUp):
		verticalColor = rightColor
		leftColor = tempVerticalColor
		rightColor = tempLeftColor
	else:
		leftColor = rightColor
		verticalColor = tempLeftColor
		rightColor = tempVerticalColor
	$VerticalEdge.set_color(colors[verticalColor])
	$LeftEdge.set_color(colors[leftColor])
	$RightEdge.set_color(colors[rightColor])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Triangle_mouse_entered():
	triangleFocused = true


func _on_Triangle_mouse_exited():
	triangleFocused = false
