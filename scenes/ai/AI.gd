extends Node2D
class_name AI

enum Direction {LEFT, RIGHT, VERT}
var best_move_column: int = 5
var best_move_rotation: int = Direction.VERT
var best_move_rating: int = 0
var boardColors: Array
var columnCounter: int = 0
var activePieceColors: PoolIntArray

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func find_best_move(nextFewPieceEdgeColors: Array, boardState: Dictionary):
	boardColors = boardState["boardColors"]
	activePieceColors = [nextFewPieceEdgeColors[0], nextFewPieceEdgeColors[1], nextFewPieceEdgeColors[2]]
	best_move_column = randi() % 11
	best_move_rotation = randi() % 3
	_thread_function(null)

func get_best_move():
	var column = best_move_column
	var rotation = best_move_rotation
	return [column, rotation]

# Run here and exit.
# The argument is the userdata passed from start().
# If no argument was passed, this one still needs to
# be here and it will be null.
func _thread_function(userdata):
	var column: int = 0
	while column < 11:
		column = columnCounter
		if column < 11:
			columnCounter = columnCounter + 1
			var topCellInColumnIndex: int = 132 + column * 3
			if boardColors[topCellInColumnIndex] == 4:
				while topCellInColumnIndex > 32:
					if boardColors[topCellInColumnIndex - 33] == 4:
						topCellInColumnIndex = topCellInColumnIndex - 33
					else:
						if ((column + (topCellInColumnIndex / 3) / 11) % 2 == 0):
							if (activePieceColors[2] == boardColors[topCellInColumnIndex - 31]):
								best_move_column = column
								best_move_rotation = Direction.VERT
							elif (activePieceColors[1] == boardColors[topCellInColumnIndex - 31]):
								best_move_column = column
								best_move_rotation = Direction.RIGHT
							elif (activePieceColors[1] == boardColors[topCellInColumnIndex - 31]):
								best_move_column = column
								best_move_rotation = Direction.LEFT
						else:
							if((column == 0 || boardColors[topCellInColumnIndex - 3] != 4)
							&& (column == 10 || boardColors[topCellInColumnIndex + 3] != 4)):
								if column != 0:
									if boardColors[topCellInColumnIndex - 2] == activePieceColors[1]:
										best_move_column = column
										best_move_rotation = Direction.VERT
									elif boardColors[topCellInColumnIndex - 2] == activePieceColors[0]:
										best_move_column = column
										best_move_rotation = Direction.LEFT
									elif boardColors[topCellInColumnIndex - 2] == activePieceColors[2]:
										best_move_column = column
										best_move_rotation = Direction.RIGHT
								elif column != 10:
									if boardColors[topCellInColumnIndex + 3] == activePieceColors[1]:
										best_move_column = column
										best_move_rotation = Direction.VERT
									elif boardColors[topCellInColumnIndex + 3] == activePieceColors[2]:
										best_move_column = column
										best_move_rotation = Direction.LEFT
									elif boardColors[topCellInColumnIndex + 3] == activePieceColors[0]:
										best_move_column = column
										best_move_rotation = Direction.RIGHT
						topCellInColumnIndex = -1
		else:
			columnCounter = 0