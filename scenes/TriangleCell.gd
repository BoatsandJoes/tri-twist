extends Area2D
class_name TriangleCell

var size: int
# last color is the null color, for empty cells
enum Direction {LEFT, RIGHT, VERTICAL, VERTICAL_POINT}
enum Rotation {CLOCKWISE, COUNTERCLOCKWISE}
const colors = [Color.royalblue, Color.crimson, Color.goldenrod, Color.webgreen, Color.black]
const focusColors = [Color.dodgerblue, Color.indianred, Color.orange, Color.seagreen, Color.darkslategray]
const highlightColors = [Color.deepskyblue, Color.deeppink, Color.gold, Color.green]
var leftColor: int = colors.size() - 1
var rightColor: int = colors.size() - 1
var verticalColor: int = colors.size() - 1
var pointFacingUp = false
var cellFocused = false
var rowIndex: int
var columnIndex: int
var inGrid
var bigClearMode = true
var tumbleDirection: int

# Called when the node enters the scene tree for the first time.
func _ready():
	tumbleDirection = Direction.VERTICAL

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
	set_colors(colors.size() - 1, colors.size() - 1, colors.size() - 1)
	# offset so the center is in the center XXX
	#translate(Vector2(-size/2,-(size * tan(PI/6))))

func _input(event):
	if event is InputEventKey && event.is_action_pressed("ui_focus_next"):
		bigClearMode = !bigClearMode

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
		tumblingDirection: int):
	if direction == Direction.VERTICAL || direction == Direction.VERTICAL_POINT:
		tumbleDirection = tumblingDirection
		if tumblingDirection == Direction.VERTICAL:
			set_colors(neighborLeftColor, neighborRightColor, neighborVerticalColor)
		elif ((tumblingDirection == Direction.RIGHT && pointFacingUp) ||
				(tumblingDirection == Direction.LEFT && !pointFacingUp)):
			set_colors(neighborLeftColor, neighborVerticalColor, neighborRightColor)
		else:
			set_colors(neighborVerticalColor, neighborRightColor, neighborLeftColor)
	elif direction == Direction.LEFT:
		tumbleDirection = Direction.RIGHT
		set_colors(neighborLeftColor, neighborVerticalColor, neighborRightColor)
	elif direction == Direction.RIGHT:
		set_colors(neighborVerticalColor, neighborRightColor, neighborLeftColor)
		tumbleDirection = Direction.LEFT
	# Check if we should start our gravity timer or come to rest
	var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
	var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
	var leftNeighborFilled = leftNeighbor == null || !leftNeighbor.is_empty()
	var rightNeighborFilled = rightNeighbor == null || !rightNeighbor.is_empty()
	var belowNeighbor
	if pointFacingUp:
		belowNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
	else:
		belowNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL_POINT)
	if (belowNeighbor != null && belowNeighbor.is_empty()):
		enter_falling_state(tumbleDirection)
	elif !pointFacingUp && leftNeighborFilled != rightNeighborFilled:
		if rightNeighborFilled:
			enter_falling_state(Direction.LEFT)
		else:
			enter_falling_state(Direction.RIGHT)
	# Check for enclosed areas.
	check_for_clear([])
	# push balancing pieces over
	if leftNeighbor != null && !leftNeighbor.is_empty():
		var neighborsNeighbor = get_parent().get_neighbor(
			leftNeighbor.rowIndex, leftNeighbor.columnIndex, Direction.LEFT)
		if neighborsNeighbor != null && neighborsNeighbor.is_empty():
			leftNeighbor.enter_falling_state(Direction.LEFT)
	if rightNeighbor != null && !rightNeighbor.is_empty():
		var neighborsNeighbor = get_parent().get_neighbor(
			rightNeighbor.rowIndex, rightNeighbor.columnIndex, Direction.RIGHT)
		if neighborsNeighbor != null && neighborsNeighbor.is_empty():
			rightNeighbor.enter_falling_state(Direction.RIGHT)

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
		if ((rotation == Rotation.COUNTERCLOCKWISE && !pointFacingUp)
				|| (rotation == Rotation.CLOCKWISE && pointFacingUp)):
			set_colors(verticalColor, leftColor, rightColor)
		else:
			set_colors(rightColor, verticalColor, leftColor)
		check_for_clear([])

func enter_falling_state(tumblingDirection: int):
	if !is_marked_for_clear() && !is_falling() && !is_empty():
		$GravityTimer.start()
		tumbleDirection = tumblingDirection

func clear(edge: int):
	tumbleDirection = Direction.VERTICAL
	$GravityTimer.stop()
	if (edge == Direction.VERTICAL_POINT && !is_marked_for_clear()):
		# Immediately blank tile.
		set_colors(colors.size() - 1, colors.size() - 1, colors.size() - 1)
		# Check to see if any neighbors should enter falling state.
		if !pointFacingUp:
			# Primarily, we have to check above.
			var neighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
			if neighbor != null:
				neighbor.enter_falling_state(neighbor.tumbleDirection)
			# We also have to check our left/right neighbors, and if they're empty, our neighbors' neighbor should consider falling.
			var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
			if leftNeighbor != null && leftNeighbor.is_empty():
				var neighborsNeighbor = get_parent().get_neighbor(leftNeighbor.rowIndex, leftNeighbor.columnIndex, Direction.LEFT)
				if neighborsNeighbor != null:
					# This is just getting silly
					var neighborsNeighborsNeighbor = get_parent().get_neighbor(neighborsNeighbor.rowIndex,
					neighborsNeighbor.columnIndex, Direction.LEFT)
					if neighborsNeighborsNeighbor == null || !neighborsNeighborsNeighbor.is_empty():
						neighborsNeighbor.enter_falling_state(Direction.RIGHT)
			var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
			if rightNeighbor != null && rightNeighbor.is_empty():
				var neighborsNeighbor = get_parent().get_neighbor(rightNeighbor.rowIndex, rightNeighbor.columnIndex, Direction.RIGHT)
				if neighborsNeighbor != null:
					# This is just getting silly
					var neighborsNeighborsNeighbor = get_parent().get_neighbor(neighborsNeighbor.rowIndex,
					neighborsNeighbor.columnIndex, Direction.RIGHT)
					if neighborsNeighborsNeighbor == null || !neighborsNeighborsNeighbor.is_empty():
						neighborsNeighbor.enter_falling_state(Direction.LEFT)
		else:
			# If left and right are both empty or both full, they shouldn't move.
			var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
			var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
			var leftNeighborFilled = leftNeighbor == null || !leftNeighbor.is_empty()
			var rightNeighborFilled = rightNeighbor == null || !rightNeighbor.is_empty()
			if leftNeighborFilled != rightNeighborFilled:
				if leftNeighborFilled:
					leftNeighbor.enter_falling_state(Direction.RIGHT)
				else:
					rightNeighbor.enter_falling_state(Direction.LEFT)
			else:
				# Fall from above. TODO this sometimes doesn't work?
				var verticalNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL_POINT)
				if verticalNeighbor != null:
					verticalNeighbor.enter_falling_state(verticalNeighbor.tumbleDirection)
	elif edge != Direction.VERTICAL_POINT:
		# Mark edge for clearing, visually.
		var particleColor: int = 0
		if Direction.LEFT == edge:
			$LeftEdge.set_color(highlightColors[leftColor])
			particleColor = leftColor
		if Direction.RIGHT == edge:
			$RightEdge.set_color(highlightColors[rightColor])
			particleColor = rightColor
		elif Direction.VERTICAL == edge:
			$VerticalEdge.set_color(highlightColors[verticalColor])
			particleColor = verticalColor
		# Set particle color XXX else block to handle split color case
		if !is_marked_for_clear():
			$CPUParticles2D.color = highlightColors[particleColor]
		# set a timer to actually clear the cell, or restart it
		$ClearTimer.start()

# find neighbors that match with this cell, and mark both for clear.
func check_for_clear(alreadyCheckedCoordinates: Array):
	# only check if we aren't already checked, and aren't falling, and aren't empty
	var alreadyChecked = false
	for coordinates in alreadyCheckedCoordinates:
		if rowIndex == coordinates[0] && columnIndex == coordinates[1]:
			alreadyChecked = true
			break
	if !alreadyChecked && !is_falling() && !is_empty():
		alreadyCheckedCoordinates.append([rowIndex, columnIndex])
		# get neighbors.
		var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
		var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
		var verticalNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
		if leftNeighbor != null && !leftNeighbor.is_falling() && !leftNeighbor.is_empty() && leftNeighbor.rightColor == leftColor:
			# Mark for clear
			if bigClearMode:
				leftNeighbor.check_for_clear(alreadyCheckedCoordinates)
			else:
				leftNeighbor.clear(Direction.RIGHT)
			clear(Direction.LEFT)
		if rightNeighbor != null && !rightNeighbor.is_falling() && !rightNeighbor.is_empty() && rightNeighbor.leftColor == rightColor:
			# Mark for clear
			if bigClearMode:
				rightNeighbor.check_for_clear(alreadyCheckedCoordinates)
			else:
				rightNeighbor.clear(Direction.LEFT)
			clear(Direction.RIGHT)
		if (verticalNeighbor != null && !verticalNeighbor.is_falling() && !verticalNeighbor.is_empty()
		&& verticalNeighbor.verticalColor == verticalColor):
			# Mark for clear
			if bigClearMode:
				verticalNeighbor.check_for_clear(alreadyCheckedCoordinates)
			else:
				verticalNeighbor.clear(Direction.VERTICAL)
			clear(Direction.VERTICAL)

func is_empty() -> bool:
	return leftColor == colors.size() - 1

func is_falling() -> bool:
	return !$GravityTimer.is_stopped()

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
	clear(Direction.VERTICAL_POINT)

func _on_GravityTimer_timeout():
	# Check neighbors to figure out where this triangle should go, and if it should go at all
	var emptyCell: TriangleCell
	var direction: int
	if pointFacingUp:
		emptyCell = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
		direction = Direction.VERTICAL
	elif tumbleDirection == Direction.LEFT || tumbleDirection == Direction.RIGHT:
		# Inertia on precarious/tumbling pieces TODO this doesn't work
		emptyCell = get_parent().get_neighbor(rowIndex, columnIndex, tumbleDirection)
		if tumbleDirection == Direction.LEFT:
			direction = Direction.RIGHT
		elif tumbleDirection == Direction.RIGHT:
			direction = Direction.LEFT
	else:
		# Fall down
		emptyCell = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL_POINT)
		direction = Direction.VERTICAL_POINT
	if (emptyCell == null || !emptyCell.is_empty()) && !pointFacingUp:
		emptyCell = null
		# We can't fall there but we are on our point; try left/right
		var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
		var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
		var leftNeighborFilled = leftNeighbor == null || !leftNeighbor.is_empty()
		var rightNeighborFilled = rightNeighbor == null || !rightNeighbor.is_empty()
		# Don't tumble unless only one neighbor is filled
		if (leftNeighborFilled != rightNeighborFilled):
			if leftNeighborFilled:
				emptyCell = rightNeighbor
				direction = Direction.LEFT
			else:
				emptyCell = leftNeighbor
				direction = Direction.RIGHT
	if emptyCell != null && emptyCell.is_empty():
		# save info in temp variables
		var tempLeftColor = leftColor
		var tempRightColor = rightColor
		var tempVerticalColor = verticalColor
		var tempTumbleDirection = tumbleDirection
		# clear self
		clear(Direction.VERTICAL_POINT)
		# copy to neighbor
		get_parent().grid[emptyCell.rowIndex][emptyCell.columnIndex].fill_from_neighbor(
			tempLeftColor, tempRightColor, tempVerticalColor,
			direction, tempTumbleDirection)
	else:
		# We have come to rest.
		tumbleDirection = Direction.VERTICAL
