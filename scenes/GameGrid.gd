extends Node2D
class_name GameGrid


export (PackedScene) var TriangleCell
export var gridBase: int
export var gridHeight: int
export var cellSize: int
export var margin: int
var grid: Array = []
var window: Rect2
var gravityTimer: Timer
enum Direction {LEFT, RIGHT, VERTICAL, VERTICAL_POINT}
enum Rotation {CLOCKWISE, COUNTERCLOCKWISE}

# Called when the node enters the scene tree for the first time.
func _ready():
	window = OS.get_window_safe_area()
	initialize_grid()

# create grid and fill it with cells
func initialize_grid():
	for rowIndex in gridHeight:
		grid.append([])
		for columnIndex in gridBase + 2 * rowIndex:
			grid[rowIndex].append(TriangleCell.instance())
			grid[rowIndex][columnIndex].init(cellSize, rowIndex, columnIndex,
			get_position_for_cell(rowIndex, columnIndex, false), true)
			add_child(grid[rowIndex][columnIndex])

# Try to put the given piece in the top row. return true if successful.
func drop_piece(piece) -> bool:
	var direction: int
	var neighborDirection: int
	if (piece.columnIndex + piece.rowIndex) % 2 != 0:
		direction = Direction.VERTICAL
		neighborDirection = Direction.VERTICAL_POINT
	else:
		direction = Direction.VERTICAL_POINT
		neighborDirection = Direction.VERTICAL
	var neighbor: TriangleCell = grid[piece.rowIndex - 1][piece.columnIndex - 1]
	if !neighbor.is_empty():
		# Cannot fill.
		return false
	var leftNeighbor = get_neighbor(neighbor.rowIndex, neighbor.columnIndex, Direction.LEFT)
	var rightNeighbor = get_neighbor(neighbor.rowIndex, neighbor.columnIndex, Direction.RIGHT)
	neighbor.fill_from_neighbor(piece.leftColor, piece.rightColor, piece.verticalColor, neighborDirection,
		!(leftNeighbor != null && leftNeighbor.is_empty()), !(rightNeighbor != null && rightNeighbor.is_empty()))
	clear_enclosed_areas()
	return true

# Gets the position in which to draw the cell with the passed indices
func get_position_for_cell(rowIndex: int, columnIndex: int, flipped: bool) -> Vector2:
	var result = Vector2((window.size[0]/2) - cellSize/2 +
				((columnIndex - ((gridBase + rowIndex * 2)/2)) * ((cellSize/2) + margin)),
				window.size[1] - cellSize - (rowIndex * ((cellSize * sqrt(3) / 2) + margin)))
	if flipped:
		result = Vector2(result[0], result[1] + cellSize * 0.87)
	return result

# returns an array of TriangleCells
func get_all_empty_cells() -> Array:
	var results = []
	for rowIndex in grid.size():
		for columnIndex in grid[rowIndex].size():
			if grid[rowIndex][columnIndex].is_empty():
				results.append(grid[rowIndex][columnIndex])
	return results

# get neighbor of the cell with the passed index,
# in the given direction. If off the edge, return null
func get_neighbor(rowIndex: int, columnIndex: int, direction: int) -> TriangleCell:
	if direction == Direction.LEFT && columnIndex > 0:
		return grid[rowIndex][columnIndex - 1]
	elif direction == Direction.RIGHT && columnIndex < grid[rowIndex].size() - 1:
		return grid[rowIndex][columnIndex + 1]
	elif (((grid[rowIndex][columnIndex].pointFacingUp && direction == Direction.VERTICAL)
	|| (!grid[rowIndex][columnIndex].pointFacingUp && direction == Direction.VERTICAL_POINT))
	&& rowIndex > 0):
			return grid[rowIndex - 1][columnIndex - 1]
	elif (((!grid[rowIndex][columnIndex].pointFacingUp && direction == Direction.VERTICAL)
	|| (grid[rowIndex][columnIndex].pointFacingUp && direction == Direction.VERTICAL_POINT))
	&& rowIndex < grid.size() - 1):
		return grid[rowIndex + 1][columnIndex + 1]
	return null

# return an array with move instructions if a move is possible, empty array otherwise
func get_move(rowIndex: int, columnIndex: int, direction: int) -> Array:
	var neighbor = get_neighbor(rowIndex, columnIndex, direction)
	if neighbor != null && !neighbor.is_empty() && !neighbor.is_marked_for_clear():
		# return move instructions
		return [rowIndex, columnIndex, direction]
	return []

# Safely grabs neighbor in the given direction and moves it to the given position.
func move_neighbor_here(rowIndex: int, columnIndex: int, direction: int) -> bool:
	var neighbor = get_neighbor(rowIndex, columnIndex, direction)
	if neighbor != null && !neighbor.is_empty():
		var leftNeighborFilled = false;
		var rightNeighborFilled = false;
		if direction == Direction.VERTICAL:
			# get other neighbor info if we need it
			var leftNeighbor = get_neighbor(rowIndex, columnIndex, Direction.LEFT)
			var rightNeighbor = get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
			leftNeighborFilled = leftNeighbor == null || (leftNeighbor != null && !leftNeighbor.is_empty())
			rightNeighborFilled = rightNeighbor == null || (rightNeighbor != null && !rightNeighbor.is_empty())
		# copy
		grid[rowIndex][columnIndex].fill_from_neighbor(
			neighbor.leftColor, neighbor.rightColor, neighbor.verticalColor,
			direction, leftNeighborFilled, rightNeighborFilled)
		# clear neighbor
		grid[neighbor.rowIndex][neighbor.columnIndex].clear(neighbor.colors.size() - 1)
		return true
	return false

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			for rowIndex in grid.size():
				for columnIndex in grid[rowIndex].size():
					if grid[rowIndex][columnIndex].cellFocused:
						handle_cell_input(rowIndex, columnIndex, event)
						break

# handles a cell click TODO handle controller and keyboard input
func handle_cell_input(rowIndex: int, columnIndex: int, event: InputEventMouseButton):
	if event.button_index == 3:
		# delete tile, debug
		grid[rowIndex][columnIndex].clear(grid[rowIndex][columnIndex].colors.size() - 1)
	elif event.button_index == 8 || event.button_index == 9 || event.button_index == 1 || event.button_index == 2:
		# rotate
		var leftNeighbor = get_neighbor(rowIndex, columnIndex, Direction.LEFT)
		var rightNeighbor = get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
		var verticalNeighbor = get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
		# move disallowed if one neighbor is off the grid or being cleared
		if (leftNeighbor != null && rightNeighbor != null && verticalNeighbor != null
		&& !grid[rowIndex][columnIndex].is_marked_for_clear() && !leftNeighbor.is_marked_for_clear()
		&& !rightNeighbor.is_marked_for_clear() && !verticalNeighbor.is_marked_for_clear()):
			var rotation
			if event.button_index == 8 || event.button_index == 1:
				rotation = Rotation.COUNTERCLOCKWISE
			else:
				rotation = Rotation.CLOCKWISE
			grid[rowIndex][columnIndex].spin(rotation)
			# rotate neighbors same way
			leftNeighbor.spin(rotation)
			rightNeighbor.spin(rotation)
			verticalNeighbor.spin(rotation)
			if ((event.button_index == 1 && grid[rowIndex][columnIndex].pointFacingUp) ||
			(event.button_index == 2 && !grid[rowIndex][columnIndex].pointFacingUp)):
				# Move tiles around center
				var tempVertColors = [verticalNeighbor.leftColor,
						verticalNeighbor.rightColor, verticalNeighbor.verticalColor]
				verticalNeighbor.set_colors(leftNeighbor.leftColor, leftNeighbor.rightColor, leftNeighbor.verticalColor)
				leftNeighbor.set_colors(rightNeighbor.leftColor, rightNeighbor.rightColor, rightNeighbor.verticalColor)
				rightNeighbor.set_colors(tempVertColors[0], tempVertColors[1], tempVertColors[2])
			elif ((event.button_index == 1 && !grid[rowIndex][columnIndex].pointFacingUp) ||
			(event.button_index == 2 && grid[rowIndex][columnIndex].pointFacingUp)):
				# Move tiles around center
				var tempVertColors = [verticalNeighbor.leftColor,
						verticalNeighbor.rightColor, verticalNeighbor.verticalColor]
				verticalNeighbor.set_colors(rightNeighbor.leftColor, rightNeighbor.rightColor, rightNeighbor.verticalColor)
				rightNeighbor.set_colors(leftNeighbor.leftColor, leftNeighbor.rightColor, leftNeighbor.verticalColor)
				leftNeighbor.set_colors(tempVertColors[0], tempVertColors[1], tempVertColors[2])
			clear_enclosed_areas()

# find all cells that have an enclosed area, and clear them.
func clear_enclosed_areas():
	var colors = grid[0][0].colors
	# exclude final color, which is "empty cell"
	for color in (colors.size() - 1):
		var cellsToCheck = grid.duplicate(true)
		for row in cellsToCheck:
			for cell in row:
				if cell != null:
					var checkedCells = get_area(cell, color, [[], true])
					# checkedCells[1] is true if area is enclosed
					if checkedCells[1]:
						for checkedCell in checkedCells[0]:
							# mark for clearing
							grid[checkedCell.rowIndex][checkedCell.columnIndex].clear(color)
							# Don't need to check these cells again for this color
							cellsToCheck[checkedCell.rowIndex][checkedCell.columnIndex] = null
					else:
						for checkedCell in checkedCells[0]:
							# Don't need to check these cells again for this color
							cellsToCheck[checkedCell.rowIndex][checkedCell.columnIndex] = null

# takes a cell, color to check, and partially completed result (may already include cell)
# returns an array with first element an array of TriangleCells representing a contiguous area of that color,
# second element true if area is enclosed, false otherwise
func get_area(cell: TriangleCell, color: int, partialResult: Array) -> Array:
	# Check to see if the passed cell is already included in our partial result
	var alreadyIncluded = false
	for areaCell in partialResult[0]:
		if areaCell.rowIndex == cell.rowIndex && areaCell.columnIndex == cell.columnIndex:
			alreadyIncluded = true
			break
	if alreadyIncluded:
		# nothing to do
		return partialResult
	# If this is the first cell, make sure it contains the specified color
	if partialResult[0].empty() && cell.leftColor != color && cell.rightColor != color && cell.verticalColor != color:
		# There is no area at all
		partialResult[1] = false
		return partialResult
	# include passed cell in partial area
	partialResult[0].append(cell)
	
	# Check neighbors for other cells that might be part of this area
	if cell.leftColor == color:
		var neighbor = get_neighbor(cell.rowIndex, cell.columnIndex, Direction.LEFT)
		if neighbor != null && neighbor.rightColor == color:
			partialResult = get_area(neighbor, color, partialResult)
		else:
			# area is not enclosed
			partialResult[1] = false
	if cell.rightColor == color:
		var neighbor = get_neighbor(cell.rowIndex, cell.columnIndex, Direction.RIGHT)
		if neighbor != null && neighbor.leftColor == color:
			partialResult = get_area(neighbor, color, partialResult)
		else:
			# area is not enclosed
			partialResult[1] = false
	if cell.verticalColor == color:
		var neighbor = get_neighbor(cell.rowIndex, cell.columnIndex, Direction.VERTICAL)
		if neighbor != null && neighbor.verticalColor == color:
			partialResult = get_area(neighbor, color, partialResult)
		else:
			# area is not enclosed
			partialResult[1] = false
	return partialResult

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Make pieces fall at regular intervals
func _on_GravityTimer_timeout():
	var thereWereFloatingPieces = false
	var moves: Array = []
	# scan for empty cells
	for emptyCell in get_all_empty_cells():
		var move: Array
		if !emptyCell.pointFacingUp:
			# Try to fill from above
			move = get_move(emptyCell.rowIndex, emptyCell.columnIndex, Direction.VERTICAL)
		else:
			# Try to fill from side
			move = get_move(emptyCell.rowIndex, emptyCell.columnIndex, Direction.RIGHT)
			if move == []:
				move = get_move(emptyCell.rowIndex, emptyCell.columnIndex, Direction.LEFT)
				if move == []:
					# Fill from above the point
					move = get_move(emptyCell.rowIndex, emptyCell.columnIndex, Direction.VERTICAL_POINT)
		if (move != []):
			moves.append(move)
	# update grid at THIS point, so that pieces don't get double pulled
	for move in moves:
		move_neighbor_here(move[0], move[1], move[2])
	clear_enclosed_areas()
