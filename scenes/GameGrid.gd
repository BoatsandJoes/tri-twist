extends Node2D
class_name GameGrid


export (PackedScene) var TriangleCell
export var gridBase: int
export var gridHeight: int
export var margin: int
var cellSize: int
var grid: Array = []
var window: Rect2

# Called when the node enters the scene tree for the first time.
func _ready():
	window = OS.get_window_safe_area()
	initialize_grid()

# create grid and fill it with cells
func initialize_grid():
	cellSize = window.size[1] / (((gridHeight) * sqrt(3) + margin) / 2)
	for rowIndex in gridHeight:
		grid.append([])
		for columnIndex in gridBase + 2 * rowIndex:
			grid[rowIndex].append(TriangleCell.instance())
			grid[rowIndex][columnIndex].init(cellSize, rowIndex, columnIndex,
			get_position_for_cell(rowIndex, columnIndex, false), true)
			add_child(grid[rowIndex][columnIndex])

# Try to put the given piece in the top row. return true if successful.
func drop_piece(piece) -> bool:
	var neighborDirection: int
	if (piece.columnIndex + piece.rowIndex) % 2 != 0:
		neighborDirection = grid[0][0].Direction.VERTICAL_POINT
	else:
		neighborDirection = grid[0][0].Direction.VERTICAL
	var neighbor: TriangleCell = grid[piece.rowIndex - 1][piece.columnIndex - 1]
	if !neighbor.is_empty():
		# Cannot fill.
		return false
	neighbor.fill_from_neighbor(piece.leftColor, piece.rightColor, piece.verticalColor,
			neighborDirection, grid[0][0].Direction.VERTICAL)
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
	if direction == grid[0][0].Direction.LEFT && columnIndex > 0:
		return grid[rowIndex][columnIndex - 1]
	elif direction == grid[0][0].Direction.RIGHT && columnIndex < grid[rowIndex].size() - 1:
		return grid[rowIndex][columnIndex + 1]
	elif (((grid[rowIndex][columnIndex].pointFacingUp && direction == grid[0][0].Direction.VERTICAL)
	|| (!grid[rowIndex][columnIndex].pointFacingUp && direction == grid[0][0].Direction.VERTICAL_POINT))
	&& rowIndex > 0 && grid[rowIndex - 1].size() > columnIndex - 1 && columnIndex != 0):
			return grid[rowIndex - 1][columnIndex - 1]
	elif (((!grid[rowIndex][columnIndex].pointFacingUp && direction == grid[0][0].Direction.VERTICAL)
	|| (grid[rowIndex][columnIndex].pointFacingUp && direction == grid[0][0].Direction.VERTICAL_POINT))
	&& rowIndex < grid.size() - 1):
		return grid[rowIndex + 1][columnIndex + 1]
	return null

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
		var leftNeighbor = get_neighbor(rowIndex, columnIndex, grid[0][0].Direction.LEFT)
		var rightNeighbor = get_neighbor(rowIndex, columnIndex, grid[0][0].Direction.RIGHT)
		var verticalNeighbor = get_neighbor(rowIndex, columnIndex, grid[0][0].Direction.VERTICAL)
		# move disallowed if one neighbor is off the grid or being cleared
		if (leftNeighbor != null && rightNeighbor != null && verticalNeighbor != null
		&& !grid[rowIndex][columnIndex].is_marked_for_clear() && !leftNeighbor.is_marked_for_clear()
		&& !rightNeighbor.is_marked_for_clear() && !verticalNeighbor.is_marked_for_clear()):
			var rotation
			if event.button_index == 8 || event.button_index == 1:
				rotation = grid[rowIndex][columnIndex].Rotation.COUNTERCLOCKWISE
			else:
				rotation = grid[rowIndex][columnIndex].Rotation.CLOCKWISE
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
			grid[rowIndex][columnIndex].check_for_clear()
			leftNeighbor.check_for_clear()
			rightNeighbor.check_for_clear()
			verticalNeighbor.check_for_clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
