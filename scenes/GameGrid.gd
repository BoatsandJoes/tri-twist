extends Node2D
class_name GameGrid

signal tumble
signal grid_full
signal garbage_rows
signal erase_chain
signal end_combo_if_exists

export (PackedScene) var TriangleCell
var screenWidth: int
var screenHeight: int
var gridWidth: int
var gridHeight: int
export var margin: int
var FakeGameGrid = load("res://scenes/FakeGameGrid.tscn")
var cellSize: int
var grid: Array = []
var digMode: bool = false
var piecesToSpawn: int = 0
var lastDefenseChains: Array = []
var ghostRow
var ghostColumn
var garbageHitstopTimers: Array = []
var digVersus = false
var queuedAttacks: FakeGameGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# create grid and fill it with cells
func initialize_grid(gridWidth: int, gridHeight: int, screenHeight: int, screenWidth: int):
	self.gridWidth = gridWidth
	self.gridHeight = gridHeight
	self.screenHeight = screenHeight
	self.screenWidth = screenWidth
	cellSize = ((screenHeight / (gridHeight + 2)) - margin) / (sqrt(3) / 2)
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
	digVersus = true
	queuedAttacks = FakeGameGrid.instance()
	add_child(queuedAttacks)
	queuedAttacks.initialize_grid(384, 360)
	queuedAttacks.set_position(Vector2(queuedAttacks.position[0] + 300, queuedAttacks.position[1] - 309))
	queuedAttacks.set_cells_visible(0)

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
			grid[key[0]][key[1]].get_node("ChainTimerBarContainer/ChainTimerBar").set_modulate(Color(0.870588, 0.4, 0.117647))
	piecesToSpawn = 0

func offset_garbage(score: int, chainKey) -> int:
	score = score / 1000
	for i in range(garbageHitstopTimers.size()):
		if score == 0:
			break
		var garbageCount = garbageHitstopTimers[i].get("garbageCount")
		while score > 0 && garbageCount > 0:
			garbageCount = garbageCount - 1
			score = score - 1
		garbageHitstopTimers[i]["garbageCount"] = garbageCount
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
	if lockedInPiecesToSpawn > 0:
		var garbageHitstopTimer: Timer = Timer.new()
		add_child(garbageHitstopTimer)
		garbageHitstopTimer.one_shot = true
		garbageHitstopTimer.wait_time = 0.5
		garbageHitstopTimer.connect("timeout", self, "_on_garbageHitstopTimer_timeout")
		garbageHitstopTimer.start()
		var record: Dictionary = {}
		record["timer"] = garbageHitstopTimer
		record["garbageCount"] = lockedInPiecesToSpawn
		garbageHitstopTimers.append(record)

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
	var result = Vector2(columnIndex * (cellSize/2 + margin) + screenWidth/5,
				screenHeight - cellSize - (rowIndex * ((cellSize * sqrt(3) / 2) + margin)))
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
				cell.show_clear_animation()
				cell.clear(cell.Direction.VERTICAL_POINT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var isGridFull = true
	var rowsEmpty = true
	var isAnyCellMarkedForClear = false
	for rowIndex in range(grid.size()):
		for cell in grid[rowIndex]:
			if cell.is_empty():
				isGridFull = false
			elif digMode:
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
	if digVersus:
		var cellsPreviewingGarbage: Array = []
		# Preview spawning garbage.
		if !garbageHitstopTimers.empty():
			for garbageGroup in garbageHitstopTimers:
				var garbageCount = garbageGroup.get("garbageCount")
				for row in grid:
					for cell in row:
						if (cell.is_empty() && garbageCount > 0 && !cellsPreviewingGarbage.has([cell.rowIndex, cell.columnIndex])):
							if garbageCount == 1 && !cell.pointFacingUp:
								var rightNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.RIGHT)
								if (rightNeighbor == null || !rightNeighbor.is_empty()
								|| cellsPreviewingGarbage.has([rightNeighbor.rowIndex, rightNeighbor.columnIndex])):
									var timer: Timer = garbageGroup.get("timer")
									cell.show_garbage_spawn_animation(1 - timer.time_left / timer.wait_time)
									cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
									garbageCount = garbageCount - 1
							else:
								var timer: Timer = garbageGroup.get("timer")
								cell.show_garbage_spawn_animation(1 - timer.time_left / timer.wait_time)
								cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
								garbageCount = garbageCount - 1
		# Calculate size of attack that we're building
		var chainsInProgress: Dictionary = get_parent().get_parent().get_chains()
		var totalPendingOutgoingGarbage: int = 0
		var totalGarbageUsedToOffsetLastDefense: int = 0
		var alreadyOffsetGarbageForEachLastDefense: PoolIntArray = PoolIntArray()
		var highestTimerForEachLastDefense: PoolRealArray = PoolRealArray()
		for chainKey in chainsInProgress.keys():
			var chainInProgress = chainsInProgress.get(chainKey)
			var chainGarbage: int = 0
			var offsetChainGarbage: int = 0
			if chainInProgress.has("scoreTotal"):
				chainGarbage = chainInProgress.get("scoreTotal") / 1000
				# Check to see if this attack is part of a last defense.
				for lastDefenseChainGroupIndex in range(lastDefenseChains.size()):
					var defenseChainKeys: Array = lastDefenseChains[lastDefenseChainGroupIndex].get("chainKeys")
					if alreadyOffsetGarbageForEachLastDefense.size() == lastDefenseChainGroupIndex:
						# Save some info to use later.
						alreadyOffsetGarbageForEachLastDefense.append(0)
						highestTimerForEachLastDefense.append(0.0)
						for defenseChainKey in defenseChainKeys:
							var timeLeft = grid[defenseChainKey[0]][defenseChainKey[1]].get_node("ClearTimer").time_left
							if timeLeft > highestTimerForEachLastDefense[lastDefenseChainGroupIndex]:
								highestTimerForEachLastDefense[lastDefenseChainGroupIndex] = timeLeft
					if defenseChainKeys.has(
					chainKey) && offsetChainGarbage < chainGarbage:
						# Prevent offsetting from multiple chains in the same defense
						var newOffsetChainGarbage: int = min(lastDefenseChains[lastDefenseChainGroupIndex].get("garbageCount")
						- alreadyOffsetGarbageForEachLastDefense[lastDefenseChainGroupIndex], (chainGarbage - offsetChainGarbage))
						offsetChainGarbage = offsetChainGarbage + newOffsetChainGarbage
						alreadyOffsetGarbageForEachLastDefense[lastDefenseChainGroupIndex] = (
						alreadyOffsetGarbageForEachLastDefense[lastDefenseChainGroupIndex] + newOffsetChainGarbage)
			totalPendingOutgoingGarbage = totalPendingOutgoingGarbage + chainGarbage
			totalGarbageUsedToOffsetLastDefense = totalGarbageUsedToOffsetLastDefense + offsetChainGarbage
		# Preview last defense garbage
		for defenseIndex in range(lastDefenseChains.size()):
			var garbage = lastDefenseChains[defenseIndex].get("garbageCount") - alreadyOffsetGarbageForEachLastDefense[defenseIndex]
			for row in grid:
				for cell in row:
					if (garbage > 0 && (cell.is_empty() || (cell.is_marked_for_clear()
					&& cell.get_node("ClearTimer").time_left <= highestTimerForEachLastDefense[defenseIndex]))
					&& !cellsPreviewingGarbage.has([cell.rowIndex, cell.columnIndex])):
						if garbage == 1 && !cell.pointFacingUp:
								var rightNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.RIGHT)
								if (rightNeighbor == null || cellsPreviewingGarbage.has([rightNeighbor.rowIndex, rightNeighbor.columnIndex])
								|| (!rightNeighbor.is_empty() && !(rightNeighbor.is_marked_for_clear()
								&& rightNeighbor.get_node("ClearTimer").time_left <= highestTimerForEachLastDefense[defenseIndex]))):
									cell.show_garbage_preview(Color(0.870588, 0.4, 0.117647, 0.8))
									cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
									garbage = garbage - 1
						else:
							cell.show_garbage_preview(Color(0.870588, 0.4, 0.117647, 0.8))
							cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
							garbage = garbage - 1
		# Preview normal garbage
		var garbage = piecesToSpawn - (totalPendingOutgoingGarbage - totalGarbageUsedToOffsetLastDefense)
		for row in grid:
			for cell in row:
				if (garbage > 0 && (cell.is_empty() || cell.is_marked_for_clear())
				&& !cellsPreviewingGarbage.has([cell.rowIndex, cell.columnIndex])):
					if garbage == 1 && !cell.pointFacingUp:
							var rightNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.RIGHT)
							if (rightNeighbor == null || cellsPreviewingGarbage.has([rightNeighbor.rowIndex, rightNeighbor.columnIndex])
							|| (!rightNeighbor.is_empty() && !rightNeighbor.is_marked_for_clear())):
								cell.show_garbage_preview(Color(1, 1, 1, 0.8))
								cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
								garbage = garbage - 1
					else:
						cell.show_garbage_preview(Color(1, 1, 1, 0.8))
						cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
						garbage = garbage - 1
		# Preview offset normal garbage
		garbage = min(piecesToSpawn, totalPendingOutgoingGarbage - totalGarbageUsedToOffsetLastDefense)
		for row in grid:
			for cell in row:
				if (garbage > 0 && (cell.is_empty() || cell.is_marked_for_clear())
				&& !cellsPreviewingGarbage.has([cell.rowIndex, cell.columnIndex])):
					if garbage == 1 && !cell.pointFacingUp:
							var rightNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.RIGHT)
							if (rightNeighbor == null || cellsPreviewingGarbage.has([rightNeighbor.rowIndex, rightNeighbor.columnIndex])
							|| (!rightNeighbor.is_empty() && !rightNeighbor.is_marked_for_clear())):
								cell.show_garbage_preview(Color(1, 1, 1, 0.1))
								cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
								garbage = garbage - 1
					else:
						cell.show_garbage_preview(Color(1, 1, 1, 0.1))
						cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
						garbage = garbage - 1
		# Preview offset last defense garbage and blank other cells
		garbage = totalGarbageUsedToOffsetLastDefense
		for row in grid:
			for cell in row:
				if (garbage > 0 && (cell.is_empty() || cell.is_marked_for_clear())
				&& !cellsPreviewingGarbage.has([cell.rowIndex, cell.columnIndex])):
					if garbage == 1 && !cell.pointFacingUp:
							var rightNeighbor = get_neighbor(cell.rowIndex, cell.columnIndex, cell.Direction.RIGHT)
							if (rightNeighbor == null || cellsPreviewingGarbage.has([rightNeighbor.rowIndex, rightNeighbor.columnIndex])
							|| (!rightNeighbor.is_empty() && !rightNeighbor.is_marked_for_clear())):
								cell.show_garbage_preview(Color(0.870588, 0.4, 0.117647, 0.1))
								cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
								garbage = garbage - 1
					else:
						cell.show_garbage_preview(Color(0.870588, 0.4, 0.117647, 0.1))
						cellsPreviewingGarbage.append([cell.rowIndex, cell.columnIndex])
						garbage = garbage - 1
				if !cellsPreviewingGarbage.has([cell.rowIndex, cell.columnIndex]):
					cell.get_node("GarbagePreview").visible = false
		# TODO preview outgoing attacks
		queuedAttacks.set_cells_visible(totalPendingOutgoingGarbage - totalGarbageUsedToOffsetLastDefense - piecesToSpawn)
		
	if !$GarbageTimer.is_stopped():
		$GarbageTimerBar.show()
		if ($GarbageTimer.wait_time - $GarbageTimer.time_left < 0.15 &&
		$GarbageTimerBar.value < $GarbageTimerBar.max_value - 0.15):
			# Filling effect
			$GarbageTimerBar.value = $GarbageTimerBar.value + (delta / 0.15) * ($GarbageTimer.wait_time - 0.15)
		else:
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

func _on_garbageHitstopTimer_timeout():
	#TODO This might crash the game if a single chain is the last defense against two attacks
	garbageHitstopTimers[0].get("timer").queue_free()
	var lockedInPiecesToSpawn = garbageHitstopTimers[0].get("garbageCount")
	garbageHitstopTimers.remove(0)
	if lockedInPiecesToSpawn > 0:
		#TODO sound sfx "incoming garbage"
		for row in grid:
			for cell in row:
				if lockedInPiecesToSpawn <= 0:
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
