extends Area2D
class_name TriangleCell

var size: int
const colors = [Color.royalblue, Color.crimson, Color.black]
var leftColor: int = colors.size() - 1
var rightColor: int = colors.size() - 1
var verticalColor: int = colors.size() - 1
var pointFacingUp = false
var cellFocused = false
var empty = true
var rowIndex: int
var columnIndex: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Call after instantiation to initialize.
func init(triangleSize: int, triRowIndex: int, triColumnIndex: int, cellPostion: Vector2):
	size = triangleSize
	rowIndex = triRowIndex
	columnIndex = triColumnIndex
	# set position
	position = cellPostion
	# Define vertices
	var baseVectorArray = PoolVector2Array()
	baseVectorArray.append(Vector2(0, 0))
	baseVectorArray.append(Vector2(size, 0))
	baseVectorArray.append(Vector2(size/2, size * sqrt(3) / 2))
	$CollisionPolygon2D.set_polygon(baseVectorArray)
	# Define vertices of children
	# left
	var leftEdgeVectorArray = PoolVector2Array()
	leftEdgeVectorArray.append(Vector2(0, 0))
	leftEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 2))
	leftEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 6))
	$LeftEdge.set_polygon(leftEdgeVectorArray)
	# right
	var rightEdgeVectorArray = PoolVector2Array()
	rightEdgeVectorArray.append(Vector2(size, 0))
	rightEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 2))
	rightEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 6))
	$RightEdge.set_polygon(rightEdgeVectorArray)
	# vertical
	var verticalEdgeVectorArray = PoolVector2Array()
	verticalEdgeVectorArray.append(Vector2(0, 0))
	verticalEdgeVectorArray.append(Vector2(size, 0))
	verticalEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 6))
	$VerticalEdge.set_polygon(verticalEdgeVectorArray)
	# flip every odd triangle cell
	if columnIndex % 2 == 1:
		flip()
	# make empty
	clear()
	# offset so the center is in the center
	#translate(Vector2(-size/2,-(size * tan(PI/6))))

func fill_randomly():
	leftColor = randi() % (colors.size() - 1)
	$LeftEdge.set_color(colors[leftColor])
	rightColor = randi() % (colors.size() - 1)
	$RightEdge.set_color(colors[rightColor])
	verticalColor = randi() % (colors.size() - 1)
	$VerticalEdge.set_color(colors[verticalColor])
	empty = false

func flip():
	scale = Vector2(1, scale[1] * -1)
	# Position fix will cause the tile to drift if flipped more than once
	position = Vector2(position[0], position[1] + size * 0.87)
	pointFacingUp = !pointFacingUp

func spin(rotation: int):
	var tempVerticalColor = verticalColor
	var tempLeftColor = leftColor
	if ((rotation == get_parent().Rotation.COUNTERCLOCKWISE && !pointFacingUp)
			|| (rotation == get_parent().Rotation.CLOCKWISE && pointFacingUp)):
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

func clear():
	leftColor = colors.size() - 1
	$LeftEdge.set_color(colors[leftColor])
	rightColor = colors.size() - 1
	$RightEdge.set_color(colors[rightColor])
	verticalColor = colors.size() - 1
	$VerticalEdge.set_color(colors[verticalColor])
	empty = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_TriangleCell_mouse_entered():
	cellFocused = true

func _on_TriangleCell_mouse_exited():
	cellFocused = false
