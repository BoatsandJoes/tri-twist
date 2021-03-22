extends Area2D
class_name TriangleCell

signal tumble

var size: int
# last color is the null color, for empty cells
enum Direction {LEFT, RIGHT, VERTICAL, VERTICAL_POINT}
enum Rotation {CLOCKWISE, COUNTERCLOCKWISE}
enum FallType {DROP, CLEAR, PUSH}
var colors = [Color.darkorchid, Color.crimson, Color.goldenrod, Color.webgreen, Color.black]
var highlightColors = [Color.fuchsia, Color.deeppink, Color.gold, Color.green]
var leftColor: int = colors.size() - 1
var rightColor: int = colors.size() - 1
var verticalColor: int = colors.size() - 1
var pointFacingUp = false
var cellFocused = false
var rowIndex: int
var columnIndex: int
var inGrid
var isGhost
var tumbleDirection: int
var fallType: int
var clearDelay = 4
var quickChainCutoff = 0
var activeChainCap = 5
var sequentialChainCap = 5
var clearScaling = 0.0
var activeChainMode = true
var isMarkedForInactiveClear = false
var wasHardDroppedMostRecently = false
var sequentialChainCapFlag = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$ChainTimerBar.set_percent_visible(false)
	$ChainTimerBar.hide()
	$ClearTimer.wait_time = clearDelay

func set_clear_scaling(value):
	clearScaling = value

# Call after instantiation to initialize.
func init(triangleSize: int, triRowIndex: int, triColumnIndex: int, cellPostion: Vector2, isInGrid: bool, isAGhost: bool):
	size = triangleSize
	rowIndex = triRowIndex
	columnIndex = triColumnIndex
	inGrid = isInGrid
	isGhost = isAGhost
	tumbleDirection = Direction.VERTICAL
	# set position
	position = cellPostion
	# Define vertices
	#var baseVectorArray = PoolVector2Array()
	#baseVectorArray.append(Vector2(0, 0))
	#baseVectorArray.append(Vector2(size, 0))
	#baseVectorArray.append(Vector2(size/2, size * sqrt(3) / 2))
	# Define vertices of children
	become_default_size()
	# flip every even triangle cell and cells outside the grid
	if ((columnIndex + rowIndex) % 2 == 0 && !pointFacingUp) || (!inGrid && !isGhost):
		scale = Vector2(1, -1)
		# Postion adjust.
		if (!isGhost):
			position = Vector2(position[0], position[1] + size * sqrt(3) / 6 )
		# Flip particle emitter back over
		$CPUParticles2D.scale = Vector2(1, -1)
		pointFacingUp = true
	elif (columnIndex + rowIndex) % 2 != 0:
		scale = Vector2(1, 1)
		$CPUParticles2D.scale = Vector2(1, 1)
		pointFacingUp = false
	# Chain timer bar.
	$ChainTimerBar.max_value = clearDelay
	$ChainTimerBar.rect_size = Vector2(size / 2, size / 10)
	$ChainTimerBar.rect_position = Vector2($ChainTimerBar.rect_position[0] - size / 4, $ChainTimerBar.rect_position[1] - size / 20)
	# make empty
	set_colors(colors.size() - 1, colors.size() - 1, colors.size() - 1)

func become_default_size():
	# left
	var leftEdgeVectorArray = PoolVector2Array()
	leftEdgeVectorArray.append(Vector2(0, 0))
	leftEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 2))
	leftEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 6))
	$LeftEdge.set_polygon(leftEdgeVectorArray)
	$LeftEdge.set_modulate(Color(1,1,1))
	# right
	var rightEdgeVectorArray = PoolVector2Array()
	rightEdgeVectorArray.append(Vector2(size, 0))
	rightEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 2))
	rightEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 6))
	$RightEdge.set_polygon(rightEdgeVectorArray)
	$RightEdge.set_modulate(Color(1,1,1))
	# vertical
	var verticalEdgeVectorArray = PoolVector2Array()
	verticalEdgeVectorArray.append(Vector2(0, 0))
	verticalEdgeVectorArray.append(Vector2(size, 0))
	verticalEdgeVectorArray.append(Vector2(size/2, size * sqrt(3) / 6))
	$VerticalEdge.set_polygon(verticalEdgeVectorArray)
	$VerticalEdge.set_modulate(Color(1,1,1))
	# Move polygons to center on our position.
	$LeftEdge.position = Vector2((-1) * size/2, (-1) * size * sqrt(3) / 6)
	$RightEdge.position = Vector2((-1) * size/2, (-1) * size * sqrt(3) / 6)
	$VerticalEdge.position = Vector2((-1) * size/2, (-1) * size * sqrt(3) / 6)

func fill_randomly():
	leftColor = randi() % (colors.size() - 1)
	rightColor = randi() % (colors.size() - 1)
	verticalColor = randi() % (colors.size() - 1)
	update_colors_visually()

func fill_without_matching_neighbors():
	$ClearTimer.stop()
	$GravityTimer.stop()
	tumbleDirection = Direction.VERTICAL
	wasHardDroppedMostRecently = false
	var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
	var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
	var verticalNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
	var tempColors: Array = colors.duplicate()
	if leftNeighbor != null && !leftNeighbor.is_empty():
		var forbiddenColor = leftNeighbor.rightColor
		tempColors.erase(colors[forbiddenColor])
	leftColor = colors.find(tempColors[randi() % (tempColors.size() - 1)])
	tempColors = colors.duplicate()
	if rightNeighbor != null && !rightNeighbor.is_empty():
		var forbiddenColor = rightNeighbor.leftColor
		tempColors.erase(colors[forbiddenColor])
	rightColor = colors.find(tempColors[randi() % (tempColors.size() - 1)])
	tempColors = colors.duplicate()
	if verticalNeighbor != null && !verticalNeighbor.is_empty():
		var forbiddenColor = verticalNeighbor.verticalColor
		tempColors.erase(colors[forbiddenColor])
	verticalColor = colors.find(tempColors[randi() % (tempColors.size() - 1)])
	update_colors_visually()
	become_default_size()

func set_colors(left: int, right: int, vertical: int):
	leftColor = left
	rightColor = right
	verticalColor = vertical
	update_colors_visually()

func spawn_piece(piece: TriangleCell):
	fallType = FallType.DROP
	wasHardDroppedMostRecently = true
	set_colors(piece.leftColor, piece.rightColor, piece.verticalColor)
	after_fill_checks(get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT),
	get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT))

func fill_from_neighbor(neighborLeftColor: int, neighborRightColor: int, neighborVerticalColor: int, direction: int,
		tumblingDirection: int, fallType: int):
	self.fallType = fallType
	if direction == Direction.VERTICAL || direction == Direction.VERTICAL_POINT:
		tumbleDirection = tumblingDirection
		if (tumblingDirection == Direction.VERTICAL):
			if rowIndex == get_parent().gridHeight - 1 && (columnIndex + rowIndex) % 2 == 0:
				set_colors(neighborLeftColor, neighborRightColor, neighborVerticalColor)
			else:
				set_colors(neighborRightColor, neighborLeftColor, neighborVerticalColor)
		elif ((tumblingDirection == Direction.RIGHT && pointFacingUp) ||
				(tumblingDirection == Direction.LEFT && !pointFacingUp)):
			set_colors(neighborLeftColor, neighborVerticalColor, neighborRightColor)
			emit_signal("tumble")
		else:
			set_colors(neighborVerticalColor, neighborRightColor, neighborLeftColor)
			emit_signal("tumble")
	elif direction == Direction.LEFT:
		tumbleDirection = Direction.RIGHT
		set_colors(neighborLeftColor, neighborVerticalColor, neighborRightColor)
		emit_signal("tumble")
	elif direction == Direction.RIGHT:
		set_colors(neighborVerticalColor, neighborRightColor, neighborLeftColor)
		tumbleDirection = Direction.LEFT
		emit_signal("tumble")
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
		enter_falling_state(tumbleDirection, fallType)
	elif !pointFacingUp && leftNeighborFilled != rightNeighborFilled:
		if rightNeighborFilled:
			enter_falling_state(Direction.LEFT, fallType)
		else:
			enter_falling_state(Direction.RIGHT, fallType)
	after_fill_checks(leftNeighbor, rightNeighbor)

func after_fill_checks(leftNeighbor, rightNeighbor):
	# Check for enclosed areas.
	if (!is_marked_for_clear()):
		# XXX there is technically still a race condition here, but it's a narrow window. This piece would be double counted
		check_for_clear([])
	# push balancing pieces over
	if !is_falling():
		if pointFacingUp:
			if leftNeighbor != null && !leftNeighbor.is_empty():
				var neighborsNeighbor = get_parent().get_neighbor(
					leftNeighbor.rowIndex, leftNeighbor.columnIndex, Direction.LEFT)
				if neighborsNeighbor != null && neighborsNeighbor.is_empty():
					if fallType == FallType.CLEAR:
						# Indirect result of a clear.
						leftNeighbor.enter_falling_state(Direction.LEFT, FallType.CLEAR)
					else:
						# Pushing.
						leftNeighbor.enter_falling_state(Direction.LEFT, FallType.PUSH)
						#TODO sound sfx optional "toppling balancing piece"
			if rightNeighbor != null && !rightNeighbor.is_empty():
				var neighborsNeighbor = get_parent().get_neighbor(
					rightNeighbor.rowIndex, rightNeighbor.columnIndex, Direction.RIGHT)
				if neighborsNeighbor != null && neighborsNeighbor.is_empty():
					if fallType == FallType.CLEAR:
						# Indirect result of a clear.
						rightNeighbor.enter_falling_state(Direction.RIGHT, FallType.CLEAR)
					else:
						# Pushing.
						rightNeighbor.enter_falling_state(Direction.RIGHT, FallType.PUSH)
						#TODO sound sfx optional "toppling balancing piece"
	if !is_marked_for_clear() && !is_falling() && !activeChainMode && fallType == FallType.DROP:
		# Don't set off if we just hit the sequential chain cap
		if sequentialChainCapFlag:
			sequentialChainCapFlag = false
		else:
			get_parent().set_off_chains()

func update_colors_visually():
	$LeftEdge.set_color(colors[leftColor])
	$RightEdge.set_color(colors[rightColor])
	$VerticalEdge.set_color(colors[verticalColor])

func spin(rotation: int) -> bool:
	if !is_marked_for_clear():
		# Naively spin.
		if ((rotation == Rotation.COUNTERCLOCKWISE && !pointFacingUp)
				|| (rotation == Rotation.CLOCKWISE && pointFacingUp)):
			set_colors(verticalColor, leftColor, rightColor)
		else:
			set_colors(rightColor, verticalColor, leftColor)
		# Check to see if we match.
		var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
		var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
		var verticalNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
		if ((leftNeighbor != null && leftNeighbor.rightColor == leftColor) ||
		(rightNeighbor != null && rightNeighbor.leftColor == rightColor) ||
		(verticalNeighbor != null && verticalNeighbor.verticalColor == verticalColor)):
			# Perform the match
			fallType = FallType.DROP
			check_for_clear([])
			return true
		else:
			#unspin.
			if ((rotation == Rotation.COUNTERCLOCKWISE && !pointFacingUp)
				|| (rotation == Rotation.CLOCKWISE && pointFacingUp)):
				set_colors(rightColor, verticalColor, leftColor)
			else:
				set_colors(verticalColor, leftColor, rightColor)
	return false

func enter_falling_state(tumblingDirection: int, fallType: int):
	if !is_marked_for_clear() && !is_falling():
		$GravityTimer.start()
		tumbleDirection = tumblingDirection
		self.fallType = fallType

func clear(edge: int):
	wasHardDroppedMostRecently = false
	tumbleDirection = Direction.VERTICAL
	$GravityTimer.stop()
	$ClearTimer.stop()
	if (edge == Direction.VERTICAL_POINT):
		# Immediately blank tile.
		set_colors(colors.size() - 1, colors.size() - 1, colors.size() - 1)
		become_default_size()
		isMarkedForInactiveClear = false
		get_parent().get_parent().get_parent().end_combo_if_exists([rowIndex, columnIndex])
		# Check to see if any neighbors should enter falling state.
		if !pointFacingUp:
			# Primarily, we have to check above.
			var neighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
			if neighbor != null:
				neighbor.enter_falling_state(neighbor.tumbleDirection, fallType)
			# We also have to check our left/right neighbors, and if they're empty, our neighbors' neighbor should consider falling.
			var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
			if leftNeighbor != null && leftNeighbor.is_empty():
				var neighborsNeighbor = get_parent().get_neighbor(leftNeighbor.rowIndex, leftNeighbor.columnIndex, Direction.LEFT)
				if neighborsNeighbor != null:
					# This is just getting silly
					var neighborsNeighborsNeighbor = get_parent().get_neighbor(neighborsNeighbor.rowIndex,
					neighborsNeighbor.columnIndex, Direction.LEFT)
					if neighborsNeighborsNeighbor == null || !neighborsNeighborsNeighbor.is_empty():
						neighborsNeighbor.enter_falling_state(Direction.RIGHT, fallType)
			var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
			if rightNeighbor != null && rightNeighbor.is_empty():
				var neighborsNeighbor = get_parent().get_neighbor(rightNeighbor.rowIndex, rightNeighbor.columnIndex, Direction.RIGHT)
				if neighborsNeighbor != null:
					# This is just getting silly
					var neighborsNeighborsNeighbor = get_parent().get_neighbor(neighborsNeighbor.rowIndex,
					neighborsNeighbor.columnIndex, Direction.RIGHT)
					if neighborsNeighborsNeighbor == null || !neighborsNeighborsNeighbor.is_empty():
						neighborsNeighbor.enter_falling_state(Direction.LEFT, fallType)
		else:
			# If left and right are both empty or both full, they shouldn't move.
			var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
			var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
			var leftNeighborFilled = leftNeighbor == null || !leftNeighbor.is_empty()
			var rightNeighborFilled = rightNeighbor == null || !rightNeighbor.is_empty()
			if leftNeighborFilled != rightNeighborFilled:
				if leftNeighborFilled && leftNeighbor != null:
					var neighborsNeighbor = leftNeighbor.get_parent().get_neighbor(leftNeighbor.rowIndex,
					leftNeighbor.columnIndex, Direction.LEFT)
					if neighborsNeighbor == null || !neighborsNeighbor.is_empty():
						leftNeighbor.enter_falling_state(Direction.RIGHT, fallType)
				elif rightNeighbor != null:
					if rightNeighborFilled && rightNeighbor != null:
						var neighborsNeighbor = rightNeighbor.get_parent().get_neighbor(rightNeighbor.rowIndex,
						rightNeighbor.columnIndex, Direction.RIGHT)
						if neighborsNeighbor == null || !neighborsNeighbor.is_empty():
							rightNeighbor.enter_falling_state(Direction.RIGHT, fallType)
			# Fall from above. In theory, if a neighbor fills then it won't fall after all. XXX keep an eye on this
			var verticalNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL_POINT)
			if verticalNeighbor != null:
				verticalNeighbor.enter_falling_state(verticalNeighbor.tumbleDirection, fallType)
	elif edge != Direction.VERTICAL_POINT:
		# Mark edge for clearing, visually.
		highlight_edge(edge)
		if activeChainMode:
			# set a timer to actually clear the cell, or restart it
			$ClearTimer.start()
		else:
			isMarkedForInactiveClear = true

func highlight_edge(edge: int):
	var particleColor: int = 0
	if Direction.LEFT == edge:
		$LeftEdge.set_modulate(Color(1.9,1.9,1.9))
		particleColor = leftColor
		var leftEdgeVectorArray = PoolVector2Array()
		leftEdgeVectorArray.append(Vector2(0, 0))
		leftEdgeVectorArray.append(Vector2((size + 6)/2, (size + 6) * sqrt(3) / 2))
		leftEdgeVectorArray.append(Vector2((size + 6)/2, (size + 6) * sqrt(3) / 6))
		$LeftEdge.set_polygon(leftEdgeVectorArray)
		# Move polygon to center on our position.
		$LeftEdge.position = Vector2((-1) * (size + 6)/2, (-1) * (size + 6) * sqrt(3) / 6)
	if Direction.RIGHT == edge:
		$RightEdge.set_modulate(Color(1.9,1.9,1.9))
		particleColor = rightColor
		# right
		var rightEdgeVectorArray = PoolVector2Array()
		rightEdgeVectorArray.append(Vector2((size + 6), 0))
		rightEdgeVectorArray.append(Vector2((size + 6)/2, (size + 6) * sqrt(3) / 2))
		rightEdgeVectorArray.append(Vector2((size + 6)/2, (size + 6) * sqrt(3) / 6))
		$RightEdge.set_polygon(rightEdgeVectorArray)
		# Move polygon to center on our position.
		$RightEdge.position = Vector2((-1) * (size + 6)/2, (-1) * (size + 6) * sqrt(3) / 6)
	elif Direction.VERTICAL == edge:
		$VerticalEdge.set_modulate(Color(1.9,1.9,1.9))
		particleColor = verticalColor
		# vertical
		var verticalEdgeVectorArray = PoolVector2Array()
		verticalEdgeVectorArray.append(Vector2(0, 0))
		verticalEdgeVectorArray.append(Vector2((size + 6), 0))
		verticalEdgeVectorArray.append(Vector2((size + 6)/2, (size + 6) * sqrt(3) / 6))
		$VerticalEdge.set_polygon(verticalEdgeVectorArray)
		# Move polygon to center on our position.
		$VerticalEdge.position = Vector2((-1) * (size + 6)/2, (-1) * (size + 6) * sqrt(3) / 6)
	# Set particle color XXX else block to handle split color case
	if !is_marked_for_clear():
		$CPUParticles2D.color = highlightColors[particleColor]

# find neighbors that match with this cell, and mark both for clear.
func check_for_clear(alreadyCheckedCoordinates: Array) -> Dictionary:
	var clearTimerTimeLeft: float = $ClearTimer.get_time_left()
	var initialCheckedCoordinates = alreadyCheckedCoordinates.duplicate()
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
		var leftRoot: Array = []
		var rightRoot: Array = []
		var verticalRoot: Array = []
		var leftClearTimeLeft: float = $ClearTimer.wait_time
		var rightClearTimeLeft: float = $ClearTimer.wait_time
		var verticalClearTimeLeft: float = $ClearTimer.wait_time
		var numMatches: int = 0
		if leftNeighbor != null && !leftNeighbor.is_falling() && !leftNeighbor.is_empty() && leftNeighbor.rightColor == leftColor:
			# Zangi-move check
			if leftNeighbor.wasHardDroppedMostRecently:
				fallType = FallType.PUSH
			# Mark for clear
			var resultDictionary = leftNeighbor.check_for_clear(alreadyCheckedCoordinates)
			if resultDictionary.has("root"):
				leftRoot = resultDictionary.get("root")
			if resultDictionary.has("clearTimeRemaining"):
				leftClearTimeLeft = resultDictionary.get("clearTimeRemaining")
			clear(Direction.LEFT)
			numMatches = numMatches + 1
		if rightNeighbor != null && !rightNeighbor.is_falling() && !rightNeighbor.is_empty() && rightNeighbor.leftColor == rightColor:
			# Zangi-move check
			if rightNeighbor.wasHardDroppedMostRecently:
				fallType = FallType.PUSH
			# Mark for clear
			var resultDictionary = rightNeighbor.check_for_clear(alreadyCheckedCoordinates)
			if resultDictionary.has("root"):
				rightRoot = resultDictionary.get("root")
			if resultDictionary.has("clearTimeRemaining"):
				rightClearTimeLeft = resultDictionary.get("clearTimeRemaining")
			clear(Direction.RIGHT)
			numMatches = numMatches + 1
		if (verticalNeighbor != null && !verticalNeighbor.is_falling() && !verticalNeighbor.is_empty()
		&& verticalNeighbor.verticalColor == verticalColor):
			# Zangi-move check
			if verticalNeighbor.wasHardDroppedMostRecently:
				fallType = FallType.PUSH
			# Mark for clear
			var resultDictionary = verticalNeighbor.check_for_clear(alreadyCheckedCoordinates)
			if resultDictionary.has("root"):
				verticalRoot = resultDictionary.get("root")
			if resultDictionary.has("clearTimeRemaining"):
				verticalClearTimeLeft = resultDictionary.get("clearTimeRemaining")
			clear(Direction.VERTICAL)
			numMatches = numMatches + 1
		# Return chain root and this cell clear time remaining.
		if get_parent().get_parent().get_parent().get_chains().has([rowIndex,columnIndex]):
			# We are the root.
			return {"root": [rowIndex, columnIndex], "clearTimeRemaining": clearTimerTimeLeft}
		else:
			var chainRootsArray: Array = []
			if !leftRoot.empty():
				chainRootsArray.append(leftRoot)
			if !rightRoot.empty():
				chainRootsArray.append(rightRoot)
			if !verticalRoot.empty():
				chainRootsArray.append(verticalRoot)
			if chainRootsArray.size() == 1:
				if initialCheckedCoordinates.empty():
					# We are the single newest piece in an existing chain
					var existingChain = update_existing_chain(get_parent().get_parent().get_parent().get_chain(chainRootsArray[0]),
					numMatches, min(leftClearTimeLeft, min(rightClearTimeLeft, verticalClearTimeLeft)))
					get_parent().get_parent().get_parent().upsert_chain(chainRootsArray[0], existingChain, fallType == FallType.CLEAR)
					# Check chain caps.
					var chainCount = 0
					if (existingChain.has("activeChainCount")):
						chainCount = chainCount + existingChain.get("activeChainCount")
					if (existingChain.has("luckyChainCount")):
						chainCount = chainCount + existingChain.get("luckyChainCount")
					if (chainCount >= activeChainCap):
						# Clear.
						clear_self_and_matching_neighbors([])
					elif (existingChain.has("sequentialChainCount") &&
					existingChain.get("sequentialChainCount") >= sequentialChainCap):
						# Set flag for later, and clear.
						sequentialChainCapFlag = true
						clear_self_and_matching_neighbors([])
				# Tell our caller the root and clear time remaining.
				return {"root": chainRootsArray[0], "clearTimeRemaining": clearTimerTimeLeft}
			elif initialCheckedCoordinates.empty() && numMatches > 0:
				if chainRootsArray.empty():
					# The newest match becomes the new chain root if there are 0 roots in this chain.
					get_parent().get_parent().get_parent().upsert_chain([rowIndex,columnIndex],
					update_existing_chain(get_parent().get_parent().get_parent().get_chain([rowIndex,columnIndex]),
					numMatches, 0.0), fallType == FallType.CLEAR)
					return {"root": [rowIndex, columnIndex], "clearTimeRemaining": clearTimerTimeLeft}
				elif chainRootsArray.size() >= 2:
					# combine the chains
					var combinedChain = combine_chains(chainRootsArray, numMatches,
					min(leftClearTimeLeft, min(rightClearTimeLeft, verticalClearTimeLeft)))
					get_parent().get_parent().get_parent().upsert_chain(chainRootsArray[0], combinedChain, fallType == FallType.CLEAR)
					# Check chain caps.
					var chainCount = 0
					if (combinedChain.has("activeChainCount")):
						chainCount = chainCount + combinedChain.get("activeChainCount")
					if (combinedChain.has("luckyChainCount")):
						chainCount = chainCount + combinedChain.get("luckyChainCount")
					if (chainCount >= activeChainCap):
						# Clear.
						clear_self_and_matching_neighbors([])
					elif (combinedChain.has("sequentialChainCount") &&
					combinedChain.get("sequentialChainCount") >= sequentialChainCap):
						# Set flag for later, and clear.
						sequentialChainCapFlag = true
						clear_self_and_matching_neighbors([])
					return {"root": chainRootsArray[0], "clearTimeRemaining": clearTimerTimeLeft}
	return {"root": [], "clearTimeRemaining": clearTimerTimeLeft}

func combine_chains(chainRoots: Array, numMatches, lowestTimeLeft) -> Dictionary:
	var combinedChain: Dictionary = get_parent().get_parent().get_parent().get_chain(chainRoots[0])
	for chainRootIndex in range(chainRoots.size()):
		if chainRootIndex != 0:
			var contributingChain: Dictionary = get_parent().get_parent().get_parent().get_chain(chainRoots[chainRootIndex])
			if contributingChain.has("brainChainCount"):
				if combinedChain.has("brainChainCount"):
					combinedChain["brainChainCount"] = combinedChain.get("brainChainCount") + contributingChain.get("brainChainCount")
				else:
					combinedChain["brainChainCount"] = contributingChain.get("brainChainCount")
			if contributingChain.has("quickChainCount"):
				if combinedChain.has("quickChainCount"):
					combinedChain["quickChainCount"] = combinedChain.get("quickChainCount") + contributingChain.get("quickChainCount")
				else:
					combinedChain["quickChainCount"] = contributingChain.get("quickChainCount")
			if contributingChain.has("luckyChainCount"):
				if combinedChain.has("luckyChainCount"):
					combinedChain["luckyChainCount"] = combinedChain.get("luckyChainCount") + contributingChain.get("luckyChainCount")
				else:
					combinedChain["luckyChainCount"] = contributingChain.get("luckyChainCount")
			if contributingChain.has("activeChainCount"):
				if combinedChain.has("activeChainCount"):
					combinedChain["activeChainCount"] = (combinedChain.get("activeChainCount")
					+ contributingChain.get("activeChainCount"))
				else:
					combinedChain["activeChainCount"] = contributingChain.get("activeChainCount")
			if contributingChain.has("sequentialChainCount"):
				if combinedChain.has("sequentialChainCount"):
					combinedChain["sequentialChainCount"] = (combinedChain.get("sequentialChainCount")
					+ contributingChain.get("sequentialChainCount"))
				else:
					combinedChain["sequentialChainCount"] = contributingChain.get("sequentialChainCount")
			if contributingChain.has("twoTrickCount"):
				if combinedChain.has("twoTrickCount"):
					combinedChain["twoTrickCount"] = combinedChain.get("twoTrickCount") + contributingChain.get("twoTrickCount")
				else:
					combinedChain["twoTrickCount"] = contributingChain.get("twoTrickCount")
			if contributingChain.has("hatTrickCount"):
				if combinedChain.has("hatTrickCount"):
					combinedChain["hatTrickCount"] = combinedChain.get("hatTrickCount") + contributingChain.get("hatTrickCount")
				else:
					combinedChain["hatTrickCount"] = contributingChain.get("hatTrickCount")
			if contributingChain.has("simulchaineousCount"):
				if combinedChain.has("simulchaineousCount"):
					combinedChain["simulchaineousCount"] = (combinedChain.get("simulchaineousCount")
					+ contributingChain.get("simulchaineousCount"))
				else:
					combinedChain["simulchaineousCount"] = contributingChain.get("simulchaineousCount")
			get_parent().get_parent().get_parent().delete_chain(chainRoots[chainRootIndex])
	return update_existing_chain(combinedChain, numMatches, lowestTimeLeft)

func update_existing_chain(existingChain, numMatches, lowestTimeLeft) -> Dictionary:
	if numMatches == 2 && fallType != FallType.CLEAR:
		# We performed a two trick.
		var existingTwoTricks: int = 0
		if existingChain.has("twoTrickCount"):
			existingTwoTricks = existingChain.get("twoTrickCount")
		existingTwoTricks = existingTwoTricks + 1
		existingChain["twoTrickCount"] = existingTwoTricks
	if numMatches == 3 && fallType != FallType.CLEAR:
		# We performed a hat trick.
		var existingHatTricks: int = 0
		if existingChain.has("hatTrickCount"):
			existingHatTricks = existingChain.get("hatTrickCount")
		existingHatTricks = existingHatTricks + 1
		existingChain["hatTrickCount"] = existingHatTricks
	if fallType == FallType.PUSH:
		# Brain chain
		var existingBrainChainCount: int = 0
		if existingChain.has("brainChainCount"):
			existingBrainChainCount = existingChain.get("brainChainCount")
		existingBrainChainCount = existingBrainChainCount + 1
		existingChain["brainChainCount"] = existingBrainChainCount
		#TODO sound sfx "extra points match"
	elif fallType == FallType.CLEAR:
		# Lucky chain (fewer points, to make mashing weaker)
		var existingLuckyChainCount: int = 0
		if existingChain.has("luckyChainCount"):
			existingLuckyChainCount = existingChain.get("luckyChainCount")
		existingLuckyChainCount = existingLuckyChainCount + 1
		existingChain["luckyChainCount"] = existingLuckyChainCount
		#TODO sound sfx optional "this match is worth like 1 point"
	else:
		if !activeChainMode:
			# Sequential chain
			var existingSequentialChainCount: int = 0
			if existingChain.has("sequentialChainCount"):
				existingSequentialChainCount = existingChain.get("sequentialChainCount")
			existingSequentialChainCount = existingSequentialChainCount + 1
			existingChain["sequentialChainCount"] = existingSequentialChainCount
		#TODO sound sfx "normal match, changes pitch depending on 'sequentialChainCount' 1 through 5"
		else:
			if lowestTimeLeft > $ClearTimer.wait_time - quickChainCutoff:
				# Quick chain
				var existingQuickChainCount: int = 0
				if existingChain.has("quickChainCount"):
					existingQuickChainCount = existingChain.get("quickChainCount")
				existingQuickChainCount = existingQuickChainCount + 1
				existingChain["quickChainCount"] = existingQuickChainCount
			else:
				# Active chain
				var existingActiveChainCount: int = 0
				if existingChain.has("activeChainCount"):
					existingActiveChainCount = existingChain.get("activeChainCount")
				existingActiveChainCount = existingActiveChainCount + 1
				existingChain["activeChainCount"] = existingActiveChainCount
				#TODO sound sfx "normal match, changes pitch depending on 'activeChainCount' 1 through 5"
	return existingChain

func clear_self_and_matching_neighbors(alreadyCheckedCoordinates: Array):
	if !alreadyCheckedCoordinates.has([rowIndex, columnIndex]):
		fallType = FallType.CLEAR
		$CPUParticles2D.emitting = true
		alreadyCheckedCoordinates.append([rowIndex, columnIndex])
		var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
		var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
		var verticalNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
		if leftNeighbor != null && leftNeighbor.rightColor == leftColor && leftNeighbor.is_marked_for_clear():
			leftNeighbor.clear_self_and_matching_neighbors(alreadyCheckedCoordinates)
		if rightNeighbor != null && rightNeighbor.leftColor == rightColor && rightNeighbor.is_marked_for_clear():
			rightNeighbor.clear_self_and_matching_neighbors(alreadyCheckedCoordinates)
		if verticalNeighbor != null && verticalNeighbor.verticalColor == verticalColor && verticalNeighbor.is_marked_for_clear():
			verticalNeighbor.clear_self_and_matching_neighbors(alreadyCheckedCoordinates)
		clear(Direction.VERTICAL_POINT)

func is_empty() -> bool:
	return leftColor == colors.size() - 1

func is_falling() -> bool:
	return !$GravityTimer.is_stopped()

func is_marked_for_clear() -> bool:
	return !$ClearTimer.is_stopped() || (isMarkedForInactiveClear && !activeChainMode)

func get_next_move_if_this_were_you(theoryTumbleDirection) -> Array:
	if theoryTumbleDirection == Direction.VERTICAL_POINT:
		# Dummy direction meant to represent our own actual direction
		theoryTumbleDirection = tumbleDirection
	var tumbleResult: int = theoryTumbleDirection
	var emptyCell: TriangleCell
	var direction: int
	if pointFacingUp:
		emptyCell = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL)
		direction = Direction.VERTICAL
		if emptyCell == null || !emptyCell.is_empty():
			emptyCell = null
	elif theoryTumbleDirection == Direction.LEFT || theoryTumbleDirection == Direction.RIGHT:
		# Inertia on precarious/tumbling pieces
		emptyCell = get_parent().get_neighbor(rowIndex, columnIndex, theoryTumbleDirection)
		if theoryTumbleDirection == Direction.LEFT:
			direction = Direction.RIGHT
		elif theoryTumbleDirection == Direction.RIGHT:
			direction = Direction.LEFT
		# If we can't roll, try to fall.
		if emptyCell == null || !emptyCell.is_empty():
			tumbleResult = Direction.VERTICAL
			emptyCell = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL_POINT)
			direction = Direction.VERTICAL_POINT
	else:
		# Look to see if we fall down
		emptyCell = get_parent().get_neighbor(rowIndex, columnIndex, Direction.VERTICAL_POINT)
		direction = Direction.VERTICAL_POINT
	if (emptyCell == null || !emptyCell.is_empty()) && !pointFacingUp:
		emptyCell = null
		# We can't fall there but we are on our point; try left/right
		var leftNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.LEFT)
		var rightNeighbor = get_parent().get_neighbor(rowIndex, columnIndex, Direction.RIGHT)
		var leftNeighborFilled = leftNeighbor == null || !leftNeighbor.is_empty()
		var rightNeighborFilled = rightNeighbor == null || !rightNeighbor.is_empty()
		# Don't tumble unless only one neighbor is filled, and it is not falling
		if (leftNeighborFilled != rightNeighborFilled):
			if leftNeighborFilled && (leftNeighbor == null || !leftNeighbor.is_falling()):
				emptyCell = rightNeighbor
				direction = Direction.LEFT
			elif rightNeighbor == null || !rightNeighbor.is_falling():
				emptyCell = leftNeighbor
				direction = Direction.RIGHT
	if direction == Direction.LEFT:
		tumbleResult = Direction.RIGHT
	elif direction == Direction.RIGHT:
		tumbleResult = Direction.LEFT
	return [emptyCell, direction, tumbleResult]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if inGrid && get_parent().get_parent().get_parent().has_chain([rowIndex, columnIndex]):
		if !$ClearTimer.is_stopped():
			# apply effect.
			$ChainTimerBar.show()
			$ChainTimerBar.value = $ClearTimer.time_left
		else:
			$ChainTimerBar.hide()
	else:
		$ChainTimerBar.hide()

func _on_ClearTimer_timeout():
	# visual effect
	$CPUParticles2D.emitting = true
	fallType = FallType.CLEAR
	clear(Direction.VERTICAL_POINT)

func _on_GravityTimer_timeout():
	if !is_empty():
		# Check neighbors to figure out where this triangle should go, and if it should go at all
		var moveInfo = get_next_move_if_this_were_you(Direction.VERTICAL_POINT)
		var emptyCell = moveInfo[0]
		var direction = moveInfo[1]
		if emptyCell != null && emptyCell.is_empty():
			# save info in temp variables
			var tempLeftColor = leftColor
			var tempRightColor = rightColor
			var tempVerticalColor = verticalColor
			var tempTumbleDirection = moveInfo[2]
			var tempFallType = fallType
			# clear self
			clear(Direction.VERTICAL_POINT)
			# copy to neighbor
			get_parent().grid[emptyCell.rowIndex][emptyCell.columnIndex].fill_from_neighbor(
				tempLeftColor, tempRightColor, tempVerticalColor,
				direction, tempTumbleDirection, tempFallType)
		else:
			# We have come to rest.
			tumbleDirection = Direction.VERTICAL
			# We may be the victim of a Zangimove
			check_for_clear([])
