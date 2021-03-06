extends Node2D
class_name GameGrid


export (PackedScene) var TriangleCell
export var gridWidth: int
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
	cellSize = ((window.size[1] / (gridHeight + 2)) - margin) / (sqrt(3) / 2)
	for rowIndex in gridHeight:
		grid.append([])
		for columnIndex in gridWidth:
			grid[rowIndex].append(TriangleCell.instance())
			grid[rowIndex][columnIndex].init(cellSize, rowIndex, columnIndex,
			get_position_for_cell(rowIndex, columnIndex, false), true, false)
			add_child(grid[rowIndex][columnIndex])

func toggle_chain_mode(active):
	for row in grid:
		for cell in row:
			cell.activeChainMode = active
			if !active:
				cell.get_node("ClearTimer").stop()

func set_gravity(value):
	for row in grid:
		for cell in row:
			cell.get_node("GravityTimer").set_wait_time(value)

func set_clear_delay(value):
	for row in grid:
		for cell in row:
			cell.get_node("ClearTimer").set_wait_time(value)
			cell.clearDelay = value

func set_clear_scaling(value):
	for row in grid:
		for cell in row:
			cell.clearScaling = value

func set_grid_height(value):
	for row in grid:
		for cell in row:
			cell.free()
	grid = []
	gridHeight = value
	initialize_grid()

# Try to put the given piece in the top row. Return true if successful.
# Pass false as a second parameter to not actually drop the piece; just know if we can.
func drop_piece(piece: TriangleCell, dropForReal: bool):
	var neighborDirection: int
	if (piece.columnIndex + piece.rowIndex) % 2 == 0:
		neighborDirection = grid[0][0].Direction.VERTICAL_POINT
	else:
		neighborDirection = grid[0][0].Direction.VERTICAL
	var neighbor: TriangleCell = grid[piece.rowIndex - 1][piece.columnIndex]
	if !neighbor.is_empty():
		# Cannot fill.
		return false
	if dropForReal:
		neighbor.fill_from_neighbor(piece.leftColor, piece.rightColor, piece.verticalColor,
			neighborDirection, grid[0][0].Direction.VERTICAL)
	return true

# Gets the position in which to draw the cell with the passed indices
func get_position_for_cell(rowIndex: int, columnIndex: int, flipped: bool) -> Vector2:
	var result = Vector2(columnIndex * (cellSize/2 + margin) + 300,
				window.size[1] - cellSize - (rowIndex * ((cellSize * sqrt(3) / 2) + margin)))
	if flipped:
		result = Vector2(result[0], result[1] + cellSize * sqrt(3) / 6)
	return result

# get neighbor of the cell with the passed index,
# in the given direction. If off the edge, return null
func get_neighbor(rowIndex: int, columnIndex: int, direction: int) -> TriangleCell:
	if direction == grid[0][0].Direction.LEFT && columnIndex > 0:
		return grid[rowIndex][columnIndex - 1]
	elif direction == grid[0][0].Direction.RIGHT && columnIndex < grid[rowIndex].size() - 1:
		return grid[rowIndex][columnIndex + 1]
	elif (((grid[rowIndex][columnIndex].pointFacingUp && direction == grid[0][0].Direction.VERTICAL)
	|| (!grid[rowIndex][columnIndex].pointFacingUp && direction == grid[0][0].Direction.VERTICAL_POINT))
	&& rowIndex > 0):
			return grid[rowIndex - 1][columnIndex]
	elif (((!grid[rowIndex][columnIndex].pointFacingUp && direction == grid[0][0].Direction.VERTICAL)
	|| (grid[rowIndex][columnIndex].pointFacingUp && direction == grid[0][0].Direction.VERTICAL_POINT))
	&& rowIndex < grid.size() - 1):
		return grid[rowIndex + 1][columnIndex]
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
	if !grid[rowIndex][columnIndex].is_empty() && !grid[rowIndex][columnIndex].is_marked_for_clear():
		if event.button_index == 3:
			# delete tile, debug
			grid[rowIndex][columnIndex].clear(grid[rowIndex][columnIndex].Direction.VERTICAL_POINT)
		elif event.button_index == 1 || event.button_index == 2:
			# spin
			var rotation
			if event.button_index == 1:
				rotation = grid[0][0].Rotation.COUNTERCLOCKWISE
			else:
				rotation = grid[0][0].Rotation.CLOCKWISE
			if rotation_would_result_in_match(rowIndex, columnIndex, rotation):
				get_parent().advance_piece()
				grid[rowIndex][columnIndex].spin(rotation)
			else:
				# Play sound.
				pass

func rotation_would_result_in_match(rowIndex: int, columnIndex:int, rotation: int) -> bool:
	var cell: TriangleCell = TriangleCell.instance()
	cell.rowIndex = grid[rowIndex][columnIndex].rowIndex
	cell.columnIndex = grid[rowIndex][columnIndex].columnIndex
	cell.leftColor = grid[rowIndex][columnIndex].leftColor
	cell.rightColor = grid[rowIndex][columnIndex].rightColor
	cell.verticalColor = grid[rowIndex][columnIndex].verticalColor
	cell.pointFacingUp = grid[rowIndex][columnIndex].pointFacingUp
	cell.visible = false
	add_child(cell)
	cell.spin(rotation)
	var result = would_have_match(cell)
	cell.free()
	return result

func would_have_match(cell: TriangleCell) -> bool:
	var leftNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.LEFT)
	var rightNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.RIGHT)
	var verticalNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.VERTICAL)
	if leftNeighbor != null && leftNeighbor.rightColor == cell.leftColor:
		return true
	elif rightNeighbor != null && rightNeighbor.leftColor == cell.rightColor:
		return true
	elif verticalNeighbor != null && verticalNeighbor.verticalColor == cell.verticalColor:
		return true
	return false

func set_off_chains():
	for row in grid:
		for cell in row:
			if cell.is_marked_for_clear():
				cell.get_node("CPUParticles2D").emitting = true
				cell.clear(cell.Direction.VERTICAL_POINT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
