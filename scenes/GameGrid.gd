extends Node2D
class_name GameGrid

signal tumble
signal grid_full

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
			grid[rowIndex][columnIndex].connect("tumble", self, "_on_TriangleCell_tumble")

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
		# Clear Zangi-move flag.
		for rowIndex in range(grid.size()):
			for columnIndex in range(grid[rowIndex].size()):
				grid[rowIndex][columnIndex].wasHardDroppedMostRecently = false
		neighbor.fill_from_neighbor(piece.leftColor, piece.rightColor, piece.verticalColor,
			neighborDirection, piece.Direction.VERTICAL, piece.FallType.DROP)
	return true

func hard_drop(piece: TriangleCell):
	# Clear Zangi-move flag
	for rowIndex in range(grid.size()):
		for columnIndex in range(grid[rowIndex].size()):
			grid[rowIndex][columnIndex].wasHardDroppedMostRecently = false
	grid[piece.rowIndex][piece.columnIndex].spawn_piece(piece)

# Gets the position in which to draw the cell with the passed indices
func get_position_for_cell(rowIndex: int, columnIndex: int, flipped: bool) -> Vector2:
	var result = Vector2(columnIndex * (cellSize/2 + margin) + window.size[0]/5,
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

func set_off_chains():
	for row in grid:
		for cell in row:
			if cell.is_marked_for_clear():
				cell.fallType = cell.FallType.CLEAR
				cell.get_node("CPUParticles2D").emitting = true
				cell.clear(cell.Direction.VERTICAL_POINT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rowIndex: int = grid.size() - 1
	var isGridFull = true
	var isAnyCellMarkedForClear = false
	while isGridFull && rowIndex >= 0:
		for cell in grid[rowIndex]:
			if cell.is_empty():
				isGridFull = false
				break
			if cell.is_marked_for_clear():
				isAnyCellMarkedForClear = true
		rowIndex = rowIndex - 1
	if isGridFull:
		if !grid[0][0].activeChainMode && isAnyCellMarkedForClear:
			set_off_chains()
		elif !isAnyCellMarkedForClear:
			emit_signal("grid_full")

func _on_TriangleCell_tumble():
	emit_signal("tumble")