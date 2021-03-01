extends Node2D
class_name TriangleDropper

export (PackedScene) var GameGrid
export (PackedScene) var TriangleCell
var gameGrid: GameGrid
var activePiece: TriangleCell


# Called when the node enters the scene tree for the first time.
func _ready():
	gameGrid = GameGrid.instance()
	add_child(gameGrid)
	activePiece = TriangleCell.instance()
	# draw active piece as though it were one row higher than the top row
	# Draw it on the left where it will always be oriented correctly, and then slide it into place.
	activePiece.init(gameGrid.cellSize, gameGrid.gridHeight, 1,
	gameGrid.get_position_for_cell(gameGrid.gridHeight, 1, true), false)
	activePiece.columnIndex = gameGrid.gridBase / 2 + gameGrid.gridHeight
	activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, activePiece.columnIndex, true)
	activePiece.fill_randomly()
	activePiece.cellFocused = true
	activePiece.update_colors_visually()
	add_child(activePiece)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_left") && activePiece.columnIndex > 1:
			activePiece.columnIndex = activePiece.columnIndex - 1
			activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, activePiece.columnIndex, true)
		elif event.is_action_pressed("ui_right") && activePiece.columnIndex < gameGrid.grid[-1].size():
			activePiece.columnIndex = activePiece.columnIndex + 1
			activePiece.position = gameGrid.get_position_for_cell(gameGrid.gridHeight, activePiece.columnIndex, true)
		elif (event.is_action_pressed("ui_accept") ||
		event.is_action_pressed("ui_down") || event.is_action_pressed("ui_up")):
			var accepted: bool = gameGrid.drop_piece(activePiece)
			if accepted:
				activePiece.fill_randomly()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass