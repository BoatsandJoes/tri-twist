extends Node2D
class_name GameGrid

signal tumble
signal grid_full
signal garbage_rows
signal erase_chain
signal end_combo_if_exists

export (PackedScene) var TriangleCell
var FakeGameGrid = load("res://scenes/FakeGameGrid.tscn")
export var gridWidth: int
export var gridHeight: int
export var margin: int
var cellSize: int
var grid: Array = []
var fakeGameGrid: FakeGameGrid
var digMode: bool = false
var piecesToSpawn: int = 0
var lastDefenseChains: Array = []
var ghostRow
var ghostColumn

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
			grid[rowIndex][columnIndex].connect("erase_chain", self, "_on_TriangleCell_erase_chain")
			grid[rowIndex][columnIndex].connect("end_combo_if_exists", self, "_on_TriangleCell_end_combo_if_exists")
			grid[rowIndex][columnIndex].connect("tumble", self, "_on_TriangleCell_tumble")
	# Garbage timer.
	$GarbageTimerBar.max_value = $GarbageTimer.wait_time
	$GarbageTimerBar.set_percent_visible(false)
	$GarbageTimerBar.hide()
	$GarbageTimerBar.rect_size = Vector2(cellSize * (gridWidth + 1) / 2, cellSize / 5)
	$GarbageTimerBar.rect_position = Vector2(grid[0][0].position[0] - cellSize / 2, grid[0][0].position[1] + cellSize / 2)

func set_dig_mode():
	digMode = true

func set_multiplayer():
	fakeGameGrid = FakeGameGrid.instance()
	add_child(fakeGameGrid)
	fakeGameGrid.initialize_grid(false)

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

func queue_garbage(score: int):
	var initialPiecesToSpawn = piecesToSpawn
	piecesToSpawn = piecesToSpawn + score / 1000
	if initialPiecesToSpawn < piecesToSpawn:
		$GarbageTimer.start()

func lock_in_garbage():
	var existingChainKeys = get_parent().get_parent().get_chains().keys()
	if existingChainKeys.empty():
		spawn_garbage(piecesToSpawn)
	else:
		var lastDefenseChainGroup = {}
		lastDefenseChainGroup["chainKeys"] = existingChainKeys
		lastDefenseChainGroup["garbageCount"] = piecesToSpawn
		lastDefenseChains.append(lastDefenseChainGroup)
		for key in existingChainKeys:
			grid[key[0]][key[1]].get_node("ChainTimerBar").set_modulate(Color(0.870588, 0.4, 0.117647))
	piecesToSpawn = 0

func offset_garbage(score: int, chainKey) -> int:
	score = score / 1000
	var lastDefenseChainsToRemove: Array = []
	for lastDefenseChain in lastDefenseChains:
		var lockedInPiecesToSpawn = lastDefenseChain.get("garbageCount")
		if score >= lockedInPiecesToSpawn:
			score = score - lockedInPiecesToSpawn
			lastDefenseChainsToRemove.append(lastDefenseChain)
		else:
			lastDefenseChain["garbageCount"] = lockedInPiecesToSpawn - score
			score = 0
			break
	for chain in lastDefenseChainsToRemove:
		lastDefenseChains.erase(chain)
	if score >= piecesToSpawn:
		score = score - piecesToSpawn
		piecesToSpawn = 0
		$GarbageTimer.stop()
	else:
		piecesToSpawn = piecesToSpawn - score
		score = 0
	var chainGroupsToErase = []
	for chainGroup in lastDefenseChains:
		var keysToRemove: Array = []
		var chainKeys = chainGroup.get("chainKeys")
		for key in chainKeys:
			if key == chainKey:
				keysToRemove.append(key)
		for key in keysToRemove:
			chainKeys.erase(key)
		# check for no more chains in group
		if chainKeys.empty():
			spawn_garbage(chainGroup.get("garbageCount"))
			chainGroupsToErase.append(chainGroup)
		else:
			chainGroup["chainKeys"] = chainKeys
	for group in chainGroupsToErase:
		lastDefenseChains.erase(group)
	return score * 1000

func spawn_garbage(lockedInPiecesToSpawn: int):
	#TODO sound sfx "incoming garbage"
	for row in grid:
		for cell in row:
			if lockedInPiecesToSpawn == 0:
				break
			if cell.is_empty():
				if lockedInPiecesToSpawn == 1 && !cell.pointFacingUp:
					var rightNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.RIGHT)
					if rightNeighbor == null || !rightNeighbor.is_empty():
						cell.fill_without_matching_neighbors()
						lockedInPiecesToSpawn = lockedInPiecesToSpawn - 1
				else:
					cell.fill_without_matching_neighbors()
					lockedInPiecesToSpawn = lockedInPiecesToSpawn - 1
	if lockedInPiecesToSpawn > 0:
		emit_signal("grid_full")

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
	var isGridFull = true
	var rowsEmpty = true
	var isAnyCellMarkedForClear = false
	var ghostGarbageCount = 0
	# TODO temp for testing; ghost garbage currently only half functional and needs rework.
	var lockedInPiecesToSpawn = 0
	for rowIndex in range(grid.size()):
		for cell in grid[rowIndex]:
			if cell.is_empty():
				isGridFull = false
				if digMode:
					if ghostGarbageCount < lockedInPiecesToSpawn:
						var ghostGarbageAdded: bool = false
						if lockedInPiecesToSpawn - ghostGarbageCount == 1 && !cell.pointFacingUp:
							var rightNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.RIGHT)
							if (rightNeighbor == null || !rightNeighbor.is_empty()):
								ghostGarbageAdded = true
						else:
							ghostGarbageAdded = true
						if ghostGarbageAdded:
							ghostGarbageCount = ghostGarbageCount + 1
							if ghostRow != rowIndex || ghostColumn != cell.columnIndex:
								fakeGameGrid.cells[rowIndex][cell.columnIndex].set_modulate(Color(0.870588, 0.4, 0.117647))
								fakeGameGrid.cells[rowIndex][cell.columnIndex].visible = true
						else:
							fakeGameGrid.cells[rowIndex][cell.columnIndex].visible = false
					elif ghostGarbageCount - lockedInPiecesToSpawn < piecesToSpawn:
						var ghostGarbageAdded: bool = false
						if piecesToSpawn - (ghostGarbageCount - lockedInPiecesToSpawn) == 1 && !cell.pointFacingUp:
							var rightNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.RIGHT)
							if (rightNeighbor == null || !rightNeighbor.is_empty()):
								ghostGarbageAdded = true
						else:
							ghostGarbageAdded = true
						if ghostGarbageAdded:
							ghostGarbageCount = ghostGarbageCount + 1
							if ghostRow != rowIndex || ghostColumn != cell.columnIndex:
								fakeGameGrid.cells[rowIndex][cell.columnIndex].visible = true
								fakeGameGrid.cells[rowIndex][cell.columnIndex].set_modulate(Color(1,1,1))
						else:
							fakeGameGrid.cells[rowIndex][cell.columnIndex].visible = false
					else:
						fakeGameGrid.cells[rowIndex][cell.columnIndex].visible = false
			elif digMode:
				fakeGameGrid.cells[rowIndex][cell.columnIndex].visible = false
				if rowIndex > 0:
					rowsEmpty = false
			if cell.is_marked_for_clear():
				isAnyCellMarkedForClear = true
	if isGridFull:
		if !grid[0][0].activeChainMode && isAnyCellMarkedForClear:
			set_off_chains()
		elif !isAnyCellMarkedForClear:
			emit_signal("grid_full")
	if digMode && rowsEmpty:
			move_up_rows(grid.size() - 1)
			fill_bottom_rows(2)
			emit_signal("garbage_rows")
	if !$GarbageTimer.is_stopped():
		# apply effect.
		$GarbageTimerBar.show()
		$GarbageTimerBar.value = $GarbageTimer.time_left
	else:
		$GarbageTimerBar.hide()

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

func _on_TriangleCell_end_combo_if_exists(chainKey):
	emit_signal("end_combo_if_exists", chainKey)

func _on_TriangleCell_erase_chain(chainKey):
	emit_signal("erase_chain", chainKey)

func _on_GarbageTimer_timeout():
	lock_in_garbage()
