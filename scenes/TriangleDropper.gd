extends Node2D
class_name TriangleDropper

export (PackedScene) var GameGrid
export (PackedScene) var TriangleCell
var gameGrid: GameGrid
var activePiece: TriangleCell
var ghostPiece: TriangleCell
var ghostLinePoints: PoolVector2Array
const colors = [Color.royalblue, Color.crimson, Color.goldenrod, Color.webgreen, Color.orchid, Color.black]
const focusColors = [Color.dodgerblue, Color.indianred, Color.orange, Color.seagreen, Color.magenta, Color.darkslategray]
const highlightColors = [Color.deepskyblue, Color.deeppink, Color.gold, Color.green, Color.fuchsia]
var dropTimer = false

# Called when the node enters the scene tree for the first time.
func _ready():
	show_on_top = true
	gameGrid = GameGrid.instance()
	add_child(gameGrid)
	activePiece = TriangleCell.instance()
	# draw active piece as though it were one row higher than the top row
	# Draw it on the left where it will always be oriented correctly, and then slide it into place.
	activePiece.init(gameGrid.cellSize, gameGrid.gridHeight, 1,
	gameGrid.get_position_for_cell(gameGrid.gridHeight, 1, true), false, false)
	activePiece.columnIndex = gameGrid.gridBase / 2 + gameGrid.gridHeight
	activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, activePiece.columnIndex, true)
	activePiece.fill_randomly()
	activePiece.cellFocused = true
	activePiece.update_colors_visually()
	add_child(activePiece)
	ghostPiece = TriangleCell.instance()
	ghostPiece.set_modulate(Color(1,1,1,0.5))
	add_child(ghostPiece)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("left") && activePiece.columnIndex > 1:
			activePiece.columnIndex = activePiece.columnIndex - 1
			activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, activePiece.columnIndex, true)
		elif event.is_action_pressed("right") && activePiece.columnIndex < gameGrid.grid[-1].size():
			activePiece.columnIndex = activePiece.columnIndex + 1
			activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, activePiece.columnIndex, true)
		elif (event.is_action_pressed("ui_accept") ||
		event.is_action_pressed("ui_down") || event.is_action_pressed("ui_up")):
			var accepted = gameGrid.drop_piece(activePiece, true)
			if accepted:
				activePiece.fill_randomly()
		elif (event.is_action_pressed("ui_focus_next")):
			$Label.visible = false

func set_drop_timer(value):
	if value == 0:
		dropTimer = false
		$DropTimer.stop()
	else:
		dropTimer = true
		$DropTimer.wait_time = value
		$DropTimer.start()

func set_color_count(value):
	var tempColors = []
	var tempFocusColors = []
	var tempHighlightColors = []
	for i in range(value):
		tempColors.append(colors[i])
		tempFocusColors.append(focusColors[i])
		tempHighlightColors.append(highlightColors[i])
	tempColors.append(colors[-1])
	tempFocusColors.append(focusColors[-1])
	activePiece.colors = tempColors
	activePiece.focusColors = tempFocusColors
	activePiece.highlightColors = tempHighlightColors
	activePiece.set_colors(tempColors.size() - 1,tempColors.size() - 1,tempColors.size() - 1)
	ghostPiece.colors = tempColors
	ghostPiece.focusColors = tempFocusColors
	ghostPiece.highlightColors = tempHighlightColors
	ghostPiece.set_colors(tempColors.size() - 1,tempColors.size() - 1,tempColors.size() - 1)
	for row in gameGrid.grid:
		for cell in row:
			cell.colors = tempColors
			cell.focusColors = focusColors
			cell.highlightColors = highlightColors
			cell.clear(tempColors.size() - 1)

func draw_ghost_pieces():
	ghostLinePoints = PoolVector2Array()
	ghostLinePoints.append(activePiece.position)
	if gameGrid.drop_piece(activePiece, false):
		ghostPiece.init(gameGrid.cellSize, activePiece.rowIndex - 1, activePiece.columnIndex - 1,
			gameGrid.get_position_for_cell(activePiece.rowIndex - 1, activePiece.columnIndex - 1,
			(activePiece.columnIndex - 1) % 2 != 0), false, true)
		var move = gameGrid.grid[ghostPiece.rowIndex][ghostPiece.columnIndex].get_next_move_if_this_were_you(
			ghostPiece.tumbleDirection)
		var lastMove = [ghostPiece, ghostPiece.Direction.VERTICAL]
		var ghostLeftColor = activePiece.leftColor
		var ghostRightColor = activePiece.rightColor
		var ghostVerticalColor = activePiece.verticalColor
		while true:
			if move[0] != null:
				if move[1] != ghostPiece.Direction.VERTICAL && move[1] != ghostPiece.Direction.VERTICAL_POINT:
					# Make point for ghost line
					ghostLinePoints.append(gameGrid.get_position_for_cell(lastMove[0].rowIndex, lastMove[0].columnIndex,
						(lastMove[0].columnIndex) % 2 != 0))
				# Rotate colors if needed
				if ((move[2] == ghostPiece.Direction.RIGHT && !move[0].pointFacingUp) ||
				(move[2] == ghostPiece.Direction.LEFT && move[0].pointFacingUp)):
					var tempRightColor = ghostRightColor
					ghostRightColor = ghostVerticalColor
					ghostVerticalColor = tempRightColor
				elif ((move[2] == ghostPiece.Direction.RIGHT && move[0].pointFacingUp) ||
				(move[2] == ghostPiece.Direction.LEFT && !move[0].pointFacingUp)):
					var tempLeftColor = ghostLeftColor
					ghostLeftColor = ghostVerticalColor
					ghostVerticalColor = tempLeftColor
				lastMove = move
				move = move[0].get_next_move_if_this_were_you(move[2])
			else:
				# We are done
				ghostPiece.init(gameGrid.cellSize, lastMove[0].rowIndex, lastMove[0].columnIndex,
						gameGrid.get_position_for_cell(lastMove[0].rowIndex, lastMove[0].columnIndex,
						(lastMove[0].columnIndex) % 2 != 0), false, true)
				ghostLinePoints.append(ghostPiece.position)
				break
		ghostPiece.set_colors(ghostLeftColor, ghostRightColor, ghostVerticalColor)
		ghostPiece.visible = true
		$GhostLine.points = ghostLinePoints
		$GhostLine.visible = true
	else:
		# We can't drop into the grid from here.
		ghostPiece.visible = false
		$GhostLine.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	draw_ghost_pieces()

func _on_DropTimer_timeout():
	if dropTimer:
		var accepted = gameGrid.drop_piece(activePiece, true)
		if accepted:
			activePiece.fill_randomly()
		else:
			$Label.visible = true
