extends Node2D
class_name GameGrid


export (PackedScene) var TriangleCell
export var cellSize: int
export var margin: int
var grid: Array
var window: Rect2
var gravityTimer: Timer
enum Direction {LEFT, RIGHT, VERTICAL, VERTICAL_POINT}
enum Rotation {CLOCKWISE, COUNTERCLOCKWISE}

# Called when the node enters the scene tree for the first time.
func _ready():
	window = OS.get_window_safe_area()
	gravityTimer = Timer.new()
	_initialize_grid()

# create grid and fill it with cells
func _initialize_grid():
	grid = [[null, null, null],
			[null, null, null, null, null],
			[null, null, null, null, null, null, null],
			[null, null, null, null, null, null, null, null, null],
			[null, null, null, null, null, null, null, null, null, null, null]]
	for rowIndex in grid.size():
		for columnIndex in grid[rowIndex].size():
			grid[rowIndex][columnIndex] = TriangleCell.instance()
			grid[rowIndex][columnIndex].init(cellSize, rowIndex, columnIndex, get_position_for_cell(rowIndex, columnIndex))
			grid[rowIndex][columnIndex].fill_randomly()
			add_child(grid[rowIndex][columnIndex])
	# Fill grid randomly; debug
	fill_grid()

# fills all cells with random triangles
func fill_grid():
	for emptyCell in get_all_empty_cells():
		emptyCell.fill_randomly()

# Gets the position in which to draw the cell with the passed indices
func get_position_for_cell(rowIndex: int, columnIndex: int) -> Vector2:
	return Vector2((window.size[0]/2) - cellSize/2 +
				((columnIndex - (grid[rowIndex].size()/2)) * ((cellSize/2) + margin)),
				window.size[1] - cellSize - (rowIndex * ((cellSize * sqrt(3) / 2) + margin)))

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
	if neighbor != null && !neighbor.is_empty():
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
		grid[neighbor.rowIndex][neighbor.columnIndex].clear()
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
	elif event is InputEventKey && event.is_action_pressed("ui_accept"):
		# kick off gravity, debug
		$GravityTimer.start()

# handles a cell click TODO handle controller and keyboard input
func handle_cell_input(rowIndex: int, columnIndex: int, event: InputEventMouseButton):
	if event.button_index == 3:
		# delete tile, debug
		grid[rowIndex][columnIndex].clear()
	if event.button_index == 1 || event.button_index == 2:
		# rotate
		var rotation
		if event.button_index == 1:
			rotation = Rotation.COUNTERCLOCKWISE
		else:
			rotation = Rotation.CLOCKWISE
		grid[rowIndex][columnIndex].spin(rotation)
		# Get and rotate neighbors opposite way
		for i in range(3):
			var neighbor = get_neighbor(rowIndex, columnIndex, i)
			if neighbor != null:
				neighbor.spin(-rotation)
		clear_enclosed_areas()

# find all cells that have an enclosed area, and clear them.
func clear_enclosed_areas():
	var colors = grid[0][0].colors
	for color in (colors.size() - 1):
		clear_cells_with_enclosed_areas_of_color(colors[color])

# clear all cells that have an enclosed area of the passed color index
func clear_cells_with_enclosed_areas_of_color(color: int):
	var cellsToCheck = grid.duplicate(true)
	for row in cellsToCheck:
		for cell in row:
			if cell != null:
				var checkedCells = get_area(cell, color, [])
				if checkedCells[1]:
					for checkedCell in checkedCells[0]:
						# mark for clearing TODO delayed clear, score
						grid[checkedCell.rowIndex][checkedCell.columnIndex].clear()
						# Don't need to check these cells again for this color
						cellsToCheck[checkedCell.rowIndex][checkedCell.columnIndex] = null
				else:
					for checkedCell in checkedCells[0]:
						# Don't need to check these cells again for this color
						cellsToCheck[checkedCell.rowIndex][checkedCell.columnIndex] = null

# returns an array with first element an array of TriangleCells,
# second element true if area is enclosed, false otherwise
func get_area(cell: TriangleCell, color: int, partialArea: Array) -> Array:
	var result = [[], false]
	partialArea.append(cell)
	if cell.leftColor == color:
		var neighbor = get_neighbor(cell.rowIndex, cell.columnIndex, Direction.LEFT)
		if neighbor != null && neighbor.rightColor == color:
			walk_if_not_already_included(neighbor, color, partialArea)
	if cell.rightColor == color:
		var neighbor = get_neighbor(cell.rowIndex, cell.columnIndex, Direction.RIGHT)
		if neighbor != null && neighbor.leftColor == color:
			walk_if_not_already_included(neighbor, color, partialArea)
	if cell.verticalColorColor == color:
		var neighbor = get_neighbor(cell.rowIndex, cell.columnIndex, Direction.VERTICAL)
		if neighbor != null && neighbor.verticalColor == color:
			walk_if_not_already_included(neighbor, color, partialArea)
	# TODO put the result from walk...() in partialArea
	# TODO base case when either no neighbors matched or all neighbors are already included
	# TODO figure out if area is closed or open
	result[0] = partialArea
	return result

func walk_if_not_already_included(neighbor: TriangleCell, color: int, partialArea: Array) -> Array:
	# Check to see if this is already included in our partial area
			var alreadyIncluded = false
			for areaCell in partialArea:
				if areaCell.rowIndex == neighbor.rowIndex && areaCell.columnIndex == neighbor.columnIndex:
					alreadyIncluded = true
					break
			if !alreadyIncluded:
				return get_area(neighbor, color, partialArea)
			else:
				return null
	

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
	if moves.empty():
		#fill grid; debug
		fill_grid()
		# stop gravity, debug
		$GravityTimer.stop()
