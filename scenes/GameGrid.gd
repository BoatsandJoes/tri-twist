extends Node2D
class_name GameGrid

signal tumble
signal grid_full
signal garbage_rows

export (PackedScene) var TriangleCell
export var gridWidth: int
export var gridHeight: int
export var margin: int
var cellSize: int
var grid: Array = []
var digMode: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_grid()

# create grid and fill it with cells
func initialize_grid():
	cellSize = ((1080 / (gridHeight + 2)) - margin) / (sqrt(3) / 2)
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

func has_no_filled_cells_above_row_index(index: int) -> bool:
	index = index + 1
	while(index < grid.size()):
		for cell in grid[index]:
			if !cell.is_empty():
				return false
		index = index + 1
	return true

func fill_bottom_rows(rows: int):
	#TODO sound sfx "incoming garbage"
	for rowIndex in range(rows):
		for cell in grid[rowIndex]:
			cell.fill_without_matching_neighbors()

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
	# TODO sound sfx optional "hard drop"

func draw_dig_line():
	var line_points: PoolVector2Array = []
	var cell1Position: Vector2 = get_position_for_cell(0, 0, false)
	var cellFinalPosition: Vector2 = get_position_for_cell(0, grid[0].size() - 1, false)
	line_points.append(Vector2(cell1Position[0] - cellSize / 4, cell1Position[1] - cellSize * sqrt(3) / 6 - 1))
	line_points.append(Vector2(cellFinalPosition[0] + cellSize / 4, cellFinalPosition[1] - cellSize * sqrt(3) / 6 - 1))
	$Line2D.points = line_points

# Gets the position in which to draw the cell with the passed indices
func get_position_for_cell(rowIndex: int, columnIndex: int, flipped: bool) -> Vector2:
	var result = Vector2(columnIndex * (cellSize/2 + margin) + 1920/5,
				1080 - cellSize - (rowIndex * ((cellSize * sqrt(3) / 2) + margin)))
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
				cell.emit_particles()
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
	# Dig mode
	if digMode:
		var rowsEmpty = true
		var digRowIndex = grid.size() - 1
		while digRowIndex > 0:
			for cell in grid[digRowIndex]:
				if !cell.is_empty():
					rowsEmpty = false
					break
			digRowIndex = digRowIndex - 1
		if rowsEmpty:
			move_up_rows(grid.size() - 1)
			fill_bottom_rows(2)
			emit_signal("garbage_rows")

func move_up_rows(digRowIndex: int):
	while digRowIndex > 1:
		for cellIndex in grid[digRowIndex].size():
			grid[digRowIndex][cellIndex].set_colors(grid[digRowIndex - 2][cellIndex].leftColor,
			grid[digRowIndex - 2][cellIndex].rightColor, grid[digRowIndex - 2][cellIndex].verticalColor)
			grid[digRowIndex][cellIndex].wasHardDroppedMostRecently = (
			grid[digRowIndex - 2][cellIndex].wasHardDroppedMostRecently)
			if grid[digRowIndex - 2][cellIndex].is_marked_for_clear():
				# Highlights.
				if (grid[digRowIndex - 2][cellIndex].get_node("LeftEdge").get_modulate() ==
				Color(3, 3, 3)):
					grid[digRowIndex][cellIndex].highlight_edge(grid[digRowIndex][cellIndex].Direction.LEFT)
				if (grid[digRowIndex - 2][cellIndex].get_node("RightEdge").get_modulate() ==
				Color(3, 3, 3)):
					grid[digRowIndex][cellIndex].highlight_edge(grid[digRowIndex][cellIndex].Direction.RIGHT)
				if (grid[digRowIndex - 2][cellIndex].get_node("VerticalEdge").get_modulate() ==
				Color(3, 3, 3)):
					grid[digRowIndex][cellIndex].highlight_edge(grid[digRowIndex][cellIndex].Direction.VERTICAL)
				grid[digRowIndex][cellIndex].get_node("ClearTimer").start(
				grid[digRowIndex - 2][cellIndex].get_node("ClearTimer").get_time_left())
			grid[digRowIndex][cellIndex].fallType = grid[digRowIndex - 2][cellIndex].fallType
			grid[digRowIndex][cellIndex].tumbleDirection = grid[digRowIndex - 2][cellIndex].tumbleDirection
			if grid[digRowIndex - 2][cellIndex].is_falling():
				grid[digRowIndex][cellIndex].get_node("GravityTimer").start(
				grid[digRowIndex - 2][cellIndex].get_node("GravityTimer").get_time_left())
		digRowIndex = digRowIndex - 1

func _on_TriangleCell_tumble():
	emit_signal("tumble")