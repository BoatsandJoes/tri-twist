extends Area2D
class_name TriangleCell

var size: int
# last color is the null color, for empty cells
const colors = [Color.royalblue, Color.crimson, Color.black]
const focusColors = [Color.dodgerblue, Color.indianred, Color.darkslategray]
const highlightColors = [Color.deepskyblue, Color.deeppink]
var leftColor: int = colors.size() - 1
var rightColor: int = colors.size() - 1
var verticalColor: int = colors.size() - 1
var pointFacingUp = false
var cellFocused = false
var rowIndex: int
var columnIndex: int
var inGrid
var autofillMode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Call after instantiation to initialize.
func init(triangleSize: int, triRowIndex: int, triColumnIndex: int, cellPostion: Vector2, isInGrid: bool):
	size = triangleSize
	rowIndex = triRowIndex
	columnIndex = triColumnIndex
	inGrid = isInGrid
	# set position
	position = cellPostion
	# move particle emitter to center
	$CPUParticles2D.position = Vector2(size/2, size * sqrt(3) / 6)
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
	# flip every odd triangle cell and cells outside the grid
	if columnIndex % 2 != 0 || !inGrid:
		flip()
	# make empty
	clear(colors.size() - 1)
	# offset so the center is in the center XXX
	#translate(Vector2(-size/2,-(size * tan(PI/6))))

func _input(event):
	if event is InputEventKey && event.is_action_pressed("ui_focus_next"):
		autofillMode = !autofillMode
		if autofillMode:
			fill_randomly()

func fill_randomly():
	leftColor = randi() % (colors.size() - 1)
	rightColor = randi() % (colors.size() - 1)
	verticalColor = randi() % (colors.size() - 1)
	update_colors_visually()

func set_colors(left: int, right: int, vertical: int):
	leftColor = left
	rightColor = right
	verticalColor = vertical
	update_colors_visually()

func fill_from_neighbor(neighborLeftColor: int, neighborRightColor: int, neighborVerticalColor: int, direction: int,
		isLeftNeighborFilled: bool, isRightNeighborFilled: bool):
	if (direction == get_parent().Direction.LEFT ||
	(isRightNeighborFilled && direction == get_parent().Direction.VERTICAL)):
		set_colors(neighborLeftColor, neighborVerticalColor, neighborRightColor)
	elif (direction == get_parent().Direction.RIGHT ||
	(isLeftNeighborFilled && direction == get_parent().Direction.VERTICAL)):
		set_colors(neighborVerticalColor, neighborRightColor,neighborLeftColor)
	else:
		set_colors(neighborLeftColor, neighborRightColor, neighborVerticalColor)

func update_colors_visually():
	if cellFocused:
		$LeftEdge.set_color(focusColors[leftColor])
		$RightEdge.set_color(focusColors[rightColor])
		$VerticalEdge.set_color(focusColors[verticalColor])
	else:
		$LeftEdge.set_color(colors[leftColor])
		$RightEdge.set_color(colors[rightColor])
		$VerticalEdge.set_color(colors[verticalColor])

func flip():
	scale = Vector2(1, scale[1] * -1)
	# Position fix will cause the tile to drift if flipped more than once
	position = Vector2(position[0], position[1] + size * 0.87)
	# Flip particle emitter back over
	$CPUParticles2D.scale = Vector2(1, $CPUParticles2D.scale[1] * -1)
	pointFacingUp = !pointFacingUp

func spin(rotation: int):
	if !is_marked_for_clear():
		if ((rotation == get_parent().Rotation.COUNTERCLOCKWISE && !pointFacingUp)
				|| (rotation == get_parent().Rotation.CLOCKWISE && pointFacingUp)):
			set_colors(verticalColor, leftColor, rightColor)
		else:
			set_colors(rightColor, verticalColor, leftColor)

func clear(color: int):
	if (color == colors.size() - 1 && !is_marked_for_clear()):
		# Immediately blank tile.
		set_colors(colors.size() - 1, colors.size() - 1, colors.size() - 1)
		if (autofillMode):
			fill_randomly()
	elif color != colors.size() - 1:
		# Mark cell for clearing, visually. Remove focus highlights, too, but not other clear highlights.
		if leftColor == color:
			$LeftEdge.set_color(highlightColors[leftColor])
		elif !is_marked_for_clear():
			$LeftEdge.set_color(colors[leftColor])
		if rightColor == color:
			$RightEdge.set_color(highlightColors[rightColor])
		elif !is_marked_for_clear():
			$RightEdge.set_color(colors[rightColor])
		if verticalColor == color:
			$VerticalEdge.set_color(highlightColors[verticalColor])
		elif !is_marked_for_clear():
			$VerticalEdge.set_color(colors[verticalColor])
		# Set particle color
		if !is_marked_for_clear():
			$CPUParticles2D.color = highlightColors[color]
		else:
			# Split colors case XXX does the same thing for now
			$CPUParticles2D.color = highlightColors[color]
		if $ClearTimer.is_stopped():
			# set a timer to actually clear the cell
			$ClearTimer.start()

func is_empty() -> bool:
	return leftColor == colors.size() - 1

func is_marked_for_clear() -> bool:
	return !$ClearTimer.is_stopped()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_TriangleCell_mouse_entered():
	# If not in grid, do nothing.
	if inGrid:
		cellFocused = true
		if !is_marked_for_clear():
			# Highlight.
			update_colors_visually()

func _on_TriangleCell_mouse_exited():
	# If not in grid, do nothing.
	if inGrid:
		cellFocused = false
		if !is_marked_for_clear():
			# Remove highlight
			update_colors_visually()


func _on_ClearTimer_timeout():
	# visual effect
	$CPUParticles2D.emitting = true
	clear(colors.size() - 1)
