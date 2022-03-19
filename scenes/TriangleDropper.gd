extends Node2D
class_name TriangleDropper

export (PackedScene) var GameGrid
export (PackedScene) var TriangleCell
signal piece_sequence_advanced
var gameGrid: GameGrid
var activePiece: TriangleCell
var ghostPiece: TriangleCell
var ghostLinePoints: PoolVector2Array
var dropTimer = false
var leftPressed = false
var rightPressed = false
var previews = []
var droppingAllowed = true
var AI = load("res://scenes/ai/AI.tscn")
var ai: AI
var aiTimer: Timer
var device: String
var gridWidth: int = 11
var gridHeight: int = 5
var screenHeight: int = 1080
var screenWidth: int = 1920
var pieceSequence: PoolIntArray
var currentPieceIndex: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pieceSequence = PoolIntArray()
	show_on_top = true

func init():
	gameGrid = GameGrid.instance()
	add_child(gameGrid)
	gameGrid.initialize_grid(gridWidth, gridHeight, screenHeight, screenWidth)
	activePiece = TriangleCell.instance()
	# draw active piece as though it were one row higher than the top row
	# Draw it on the left where it will always be oriented correctly, and then slide it into place.
	activePiece.init(gameGrid.cellSize, gameGrid.gridHeight, 0,
	gameGrid.get_position_for_cell(gameGrid.gridHeight, 0, true), false, false)
	activePiece.columnIndex = gameGrid.gridWidth / 2
	activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, activePiece.columnIndex, true)
	activePiece.fill_randomly()
	add_child(activePiece)
	if (device == "Mouse"):
		set_active_piece_position_based_on_mouse(get_global_mouse_position()[0])
	# Previews
	for i in range(3):
		var preview: TriangleCell = TriangleCell.instance()
		preview.init(activePiece.size, -1, -1, Vector2(gameGrid.grid[-1][-1].position[0] + (i + 1.1) * activePiece.size,
		activePiece.position[1]), false, false)
		preview.fill_randomly()
		previews.append(preview)
		add_child(preview)
	set_previews_visible(3)
	# Ghost
	ghostPiece = TriangleCell.instance()
	ghostPiece.set_modulate(Color(1,1,1,0.5))
	add_child(ghostPiece)

func set_multiplayer():
	for i in range(previews.size()):
		previews[i].init(activePiece.size, -1, -1, Vector2(gameGrid.grid[-1][-8].position[0] + (i + 1.1) * activePiece.size,
		activePiece.position[1] - activePiece.size * 1.5), false, false)
		if pieceSequence.size() == 0:
			previews[i].fill_randomly()
		else:
			previews[i].set_colors(pieceSequence[(i+1)*3], pieceSequence[(i+1)*3 + 1], pieceSequence[(i+1)*3 + 2])
	gameGrid.set_multiplayer()

func set_active_piece_position_based_on_mouse(horizontalMousePosition: int):
	for cell in gameGrid.grid[0]:
		#TODO remove horizontal areas between cells that neither the left nor right cell will claim, but only for game start/unpause
		if ((horizontalMousePosition < cell.position[0] + cell.size / 4
		&& horizontalMousePosition > cell.position[0] - cell.size / 4)
		|| (cell.columnIndex == 0 && horizontalMousePosition < cell.position[0])
		|| (cell.columnIndex == gameGrid.grid[0].size() - 1 && horizontalMousePosition > cell.position[0])):
			set_active_piece_position(cell.columnIndex)

func set_active_piece_position(positionIndex: int):
	activePiece.columnIndex = positionIndex
	activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, positionIndex, true)

func update_active_piece_position():
	if device == "Mouse":
		set_active_piece_position_based_on_mouse(get_global_mouse_position()[0])

func set_das(das: int):
	$DasTimer.wait_time = das / 60.0

func set_arr(arr: int):
	$ArrTimer.wait_time = arr / 60.0

func set_device(device: String):
	self.device = device
	if device == "CPU":
		ai = AI.instance()
		add_child(ai)
		aiTimer = Timer.new()
		add_child(aiTimer)
		aiTimer.one_shot = true
		aiTimer.connect("timeout", self, "_on_aiTimer_timeout")
		ask_ai_for_move()

func ask_ai_for_move():
	ai.find_best_move([activePiece.leftColor, activePiece.rightColor, activePiece.verticalColor,
	previews[0].leftColor, previews[0].rightColor, previews[0].verticalColor], serialize())
	aiTimer.start(1)

func enable_dropping():
	droppingAllowed = true

func disable_dropping():
	droppingAllowed = false

func set_previews_visible(value):
	for i in range(previews.size()):
		previews[i].visible = i < value

func serialize() -> Dictionary:
	var result: Dictionary = {}
	result["currentPieceIndex"] = currentPieceIndex
	result["activePieceColumnIndex"] = activePiece.columnIndex
	var colors: PoolIntArray = []
	for row in gameGrid.grid:
		for cell in row:
			colors.append(cell.leftColor)
			colors.append(cell.rightColor)
			colors.append(cell.verticalColor)
	result["boardColors"] = colors
	return result

func deserialize(state: Dictionary):
	currentPieceIndex = state.get("currentPieceIndex")
	# Set active and preview colors
	var previousPieceIndex = currentPieceIndex - 1 - previews.size()
	if previousPieceIndex < 0:
		previousPieceIndex = pieceSequence.size() / 3 - 1 + previousPieceIndex
	activePiece.set_colors(pieceSequence[previousPieceIndex*3], pieceSequence[previousPieceIndex*3 + 1],
	pieceSequence[previousPieceIndex*3 + 2])
	for i in range(previews.size()):
		previousPieceIndex = previousPieceIndex + 1
		if previousPieceIndex >= pieceSequence.size():
			previousPieceIndex = 0
		previews[i].set_colors(pieceSequence[previousPieceIndex*3], pieceSequence[previousPieceIndex*3 + 1],
		pieceSequence[previousPieceIndex*3 + 2])
	set_active_piece_position(state.get("activePieceColumnIndex"))
	var colors: PoolIntArray = state.get("boardColors")
	for rowIndex in range(gameGrid.grid.size()):
		for columnIndex in range(gameGrid.gridWidth):
			gameGrid.grid[rowIndex][columnIndex].set_colors(colors[rowIndex*gameGrid.gridWidth*3 + columnIndex*3],
			colors[rowIndex*gameGrid.gridWidth*3 + columnIndex*3+1], colors[rowIndex*gameGrid.gridWidth*3 + columnIndex*3+2])

func move_piece_right():
	if activePiece.columnIndex < gameGrid.grid[-1].size() - 1:
				activePiece.columnIndex = activePiece.columnIndex + 1
				activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, activePiece.columnIndex, true)

func move_piece_left():
	if activePiece.columnIndex > 0:
				activePiece.columnIndex = activePiece.columnIndex - 1
				activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, activePiece.columnIndex, true)

func rotate_clockwise():
	activePiece.set_colors(activePiece.verticalColor, activePiece.leftColor, activePiece.rightColor)

func rotate_counterclockwise():
	activePiece.set_colors(activePiece.rightColor, activePiece.verticalColor, activePiece.leftColor)

func soft_drop():
	var accepted = gameGrid.drop_piece(activePiece, true)
	if accepted:
		advance_piece()

func hard_drop():
	gameGrid.hard_drop(ghostPiece)
	advance_piece()

func _input(event):
	if ((event is InputEventKey && device == "Keyboard")
	|| ((event is InputEventJoypadButton || event is InputEventJoypadMotion) && device.begins_with("Controller")
	&& int(device.substr(device.find(" ") + 1, 2)) - 1 == event.device)
	|| (event is InputEventMouseButton && device == "Mouse")):
		if device != "Mouse":
			if event.is_action_pressed("left"):
				leftPressed = true
				rightPressed = false
				$DasTimer.start()
				$ArrTimer.stop()
				move_piece_left()
			elif event.is_action_pressed("right"):
				rightPressed = true
				leftPressed = false
				$DasTimer.start()
				$ArrTimer.stop()
				move_piece_right()
			elif event.is_action_released("left"):
				leftPressed = false
				$DasTimer.stop()
				$ArrTimer.stop()
				if rightPressed:
					$DasTimer.start()
			elif event.is_action_released("right"):
				rightPressed = false
				$DasTimer.stop()
				$ArrTimer.stop()
				if leftPressed:
					$DasTimer.start()
		if event.is_action_pressed("clockwise"):
			rotate_clockwise()
		elif event.is_action_pressed("counterclockwise"):
			rotate_counterclockwise()
		elif droppingAllowed:
			if event.is_action_pressed("soft_drop"):
				soft_drop()
			elif event.is_action_pressed("hard_drop") && ghostPiece.visible:
				hard_drop()
	elif event is InputEventMouseMotion && device == "Mouse":
		set_active_piece_position_based_on_mouse(event.position[0])

func set_piece_sequence(pieceSequence: PoolIntArray):
	self.pieceSequence = pieceSequence
	activePiece.set_colors(pieceSequence[0], pieceSequence[1], pieceSequence[2])
	for i in range(previews.size()):
		previews[i].set_colors(pieceSequence[(i+1) * 3], pieceSequence[(i+1) * 3 + 1], pieceSequence[(i+1) * 3 + 2])
	currentPieceIndex = previews.size() + 1

func set_drop_timer(value):
	if value == 0:
		dropTimer = false
		$DropTimer.stop()
	else:
		dropTimer = true
		$DropTimer.wait_time = value
		$DropTimer.start()

func draw_ghost_pieces():
	ghostLinePoints = PoolVector2Array()
	ghostLinePoints.append(Vector2(activePiece.position[0], activePiece.position[1] + activePiece.size * sqrt(3) / 6))
	if gameGrid.drop_piece(activePiece, false):
		ghostPiece.init(gameGrid.cellSize, activePiece.rowIndex - 1, activePiece.columnIndex,
			gameGrid.get_position_for_cell(activePiece.rowIndex - 1, activePiece.columnIndex,
			(activePiece.columnIndex) % 2 != 0), false, true)
		var move = gameGrid.grid[ghostPiece.rowIndex][ghostPiece.columnIndex].get_next_move_if_this_were_you(
			ghostPiece.tumbleDirection)
		var lastMove = [ghostPiece, ghostPiece.Direction.VERTICAL, ghostPiece.Direction.VERTICAL]
		var ghostLeftColor
		var ghostRightColor
		var ghostVerticalColor
		if lastMove[0].pointFacingUp:
			ghostLeftColor = activePiece.leftColor
			ghostRightColor = activePiece.rightColor
			ghostVerticalColor = activePiece.verticalColor
		else:
			ghostLeftColor = activePiece.rightColor
			ghostRightColor = activePiece.leftColor
			ghostVerticalColor = activePiece.verticalColor
		while true:
			if move[0] != null:
				if move[1] != ghostPiece.Direction.VERTICAL && move[1] != ghostPiece.Direction.VERTICAL_POINT:
					# Make point for ghost line
					ghostLinePoints.append(gameGrid.get_position_for_cell(lastMove[0].rowIndex, lastMove[0].columnIndex,
						(lastMove[0].columnIndex) % 2 != 0))
				# Rotate colors
				if ((move[2] == ghostPiece.Direction.RIGHT && move[0].pointFacingUp) ||
				(move[2] == ghostPiece.Direction.LEFT && !move[0].pointFacingUp)):
					var tempRightColor = ghostRightColor
					ghostRightColor = ghostVerticalColor
					ghostVerticalColor = tempRightColor
				elif ((move[2] == ghostPiece.Direction.RIGHT && !move[0].pointFacingUp) ||
				(move[2] == ghostPiece.Direction.LEFT && move[0].pointFacingUp)):
					var tempLeftColor = ghostLeftColor
					ghostLeftColor = ghostVerticalColor
					ghostVerticalColor = tempLeftColor
				else:
					var tempLeftColor = ghostLeftColor
					ghostLeftColor = ghostRightColor
					ghostRightColor = tempLeftColor
				lastMove = move
				move = move[0].get_next_move_if_this_were_you(move[2])
			else:
				# We are done
				ghostPiece.init(gameGrid.cellSize, lastMove[0].rowIndex, lastMove[0].columnIndex,
						gameGrid.get_position_for_cell(lastMove[0].rowIndex, lastMove[0].columnIndex,
						(lastMove[0].columnIndex + lastMove[0].rowIndex) % 2 == 0), false, true)
				ghostLinePoints.append(ghostPiece.position)
				break
		ghostPiece.set_colors(ghostLeftColor, ghostRightColor, ghostVerticalColor)
		ghostPiece.visible = true
		$GhostLine.points = ghostLinePoints
		$GhostLine.visible = true
		gameGrid.ghostRow = ghostPiece.rowIndex
		gameGrid.ghostColumn = ghostPiece.columnIndex
	else:
		# We can't drop into the grid from here.
		ghostPiece.visible = false
		$GhostLine.visible = false
		gameGrid.ghostColumn = null
		gameGrid.ghostRow = null

func advance_piece():
	activePiece.set_colors(previews[0].leftColor, previews[0].rightColor, previews[0].verticalColor)
	for i in range(previews.size() - 1):
		previews[i].set_colors(previews[i+1].leftColor, previews[i+1].rightColor, previews[i+1].verticalColor)
	previews[-1].set_colors(pieceSequence[currentPieceIndex * 3], pieceSequence[currentPieceIndex * 3 + 1],
	pieceSequence[currentPieceIndex * 3 + 2])
	currentPieceIndex = currentPieceIndex + 1
	if currentPieceIndex >= pieceSequence.size() / 3:
		currentPieceIndex = 0
	if dropTimer:
		$DropTimer.start()
	emit_signal("piece_sequence_advanced")

func perform_best_ai_move():
	var bestMove = ai.get_best_move()
	set_active_piece_position(bestMove[0])
	if bestMove[1] == ai.Direction.LEFT:
		rotate_counterclockwise()
	if bestMove[1] == ai.Direction.RIGHT:
		rotate_clockwise()
	$DropTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	draw_ghost_pieces()

func _on_aiTimer_timeout():
	perform_best_ai_move()

func _on_DropTimer_timeout():
	if ghostPiece.visible:
		hard_drop()
	ask_ai_for_move()

func _on_DasTimer_timeout():
	if rightPressed:
		move_piece_right()
	elif leftPressed:
		move_piece_left()
	$ArrTimer.start()

func _on_ArrTimer_timeout():
	if rightPressed:
		move_piece_right()
	elif leftPressed:
		move_piece_left()
