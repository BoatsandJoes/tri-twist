extends Node2D
class_name GameGrid


export (PackedScene) var TriangleCell
export var cellSize: int
export var margin: int
var grid: Array
var window: Rect2
var gravityTimer: Timer
enum Direction {LEFT, RIGHT, VERTICAL}
enum Rotation {CLOCKWISE, COUNTERCLOCKWISE}

# Called when the node enters the scene tree for the first time.
func _ready():
	window = OS.get_window_safe_area()
	gravityTimer = Timer.new()
	_initialize_grid()

func _initialize_grid():
	grid = [[null, null, null],
			[null, null, null, null, null],
			[null, null, null, null, null, null, null],
			[null, null, null, null, null, null, null, null, null],
			[null, null, null, null, null, null, null, null, null, null, null]]
	for rowIndex in grid.size():
		for columnIndex in grid[rowIndex].size():
			grid[rowIndex][columnIndex] = TriangleCell.instance()
			grid[rowIndex][columnIndex].init(cellSize, rowIndex, columnIndex, get_position_for_cell(rowIndex, columnIndex))
			grid[rowIndex][columnIndex].fill_randomly()
			add_child(grid[rowIndex][columnIndex])
	# Fill grid randomly; debug
	fill_grid()

func fill_grid():
	# fills all cells with random triangles
	for emptyCell in get_all_empty_cells():
		emptyCell.fill_randomly()

func get_position_for_cell(rowIndex: int, columnIndex: int) -> Vector2:
	return Vector2((window.size[0]/2) - cellSize/2 +
				((columnIndex - (grid[rowIndex].size()/2)) * ((cellSize/2) + margin)),
				window.size[1] - cellSize - (rowIndex * ((cellSize * sqrt(3) / 2) + margin)))

func get_all_empty_cells() -> Array:
	var results = []
	for rowIndex in grid.size():
		for columnIndex in grid[rowIndex].size():
			if grid[rowIndex][columnIndex].empty:
				results.append(grid[rowIndex][columnIndex])
	return results

func get_neighbor(rowIndex: int, columnIndex: int, direction: int) -> TriangleCell:
	if direction == Direction.LEFT && columnIndex > 0:
		return grid[rowIndex][columnIndex - 1]
	elif direction == Direction.RIGHT && columnIndex < grid[rowIndex].size() - 1:
		return grid[rowIndex][columnIndex + 1]
	elif direction == Direction.VERTICAL:
		if grid[rowIndex][columnIndex].pointFacingUp && rowIndex > 0:
			return grid[rowIndex - 1][columnIndex - 1]
		elif !grid[rowIndex][columnIndex].pointFacingUp && rowIndex < grid.size() - 1:
			return grid[rowIndex + 1][columnIndex + 1]
	return null

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			for rowIndex in grid.size():
				for columnIndex in grid[rowIndex].size():
					if grid[rowIndex][columnIndex].cellFocused:
						handle_cell_input(rowIndex, columnIndex, event)
						break
	elif event is InputEventKey && event.is_action_pressed("ui_accept"):
		# kick off gravity, debug
		$GravityTimer.start()

func handle_cell_input(rowIndex: int, columnIndex: int, event: InputEventMouseButton):
	if event.button_index == 3:
		# delete tile, debug
		grid[rowIndex][columnIndex].clear()
	if event.button_index == 1 || event.button_index == 2:
		# rotate
		var rotation
		if event.button_index == 1:
			rotation = Rotation.COUNTERCLOCKWISE
		else:
			rotation = Rotation.CLOCKWISE
		grid[rowIndex][columnIndex].spin(rotation)
		# Get and rotate neighbors opposite way
		for i in range(3):
			var neighbor = get_neighbor(rowIndex, columnIndex, i)
			if neighbor != null:
				neighbor.spin(-rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_GravityTimer_timeout():
	var floatingPieces = false
	# scan for floating pieces and move each one once
	for emptyCell in get_all_empty_cells():
		if !emptyCell.pointFacingUp:
			# Check cell above
			if get_neighbor(emptyCell.rowIndex, emptyCell.columnIndex, Direction.VERTICAL) != null:
				floatingPieces = true
				#TODO move_triangle_down_one_step(emptyCell[0] + 1, emptyCell[1] + 1)
		else:
			# Check left neighbor
			var leftNeighbor = get_neighbor(emptyCell.rowIndex, emptyCell.columnIndex, Direction.LEFT)
			if leftNeighbor != null && !leftNeighbor.empty:
				# Move piece right TODO
				floatingPieces = true
				#grid[emptyCell[0]][emptyCell[1]] = grid[emptyCell[0]][emptyCell[1] - 1]
				#grid[emptyCell[0]][emptyCell[1] - 1] = null
				#grid[emptyCell[0]][emptyCell[1]].topple(1)
			# Check right neighbor
			var rightNeighbor = get_neighbor(emptyCell.rowIndex, emptyCell.columnIndex, Direction.RIGHT)
			if rightNeighbor != null && !rightNeighbor.empty:
				# Move piece left TODO
				floatingPieces = true
				#grid[emptyCell[0]][emptyCell[1]] = grid[emptyCell[0]][emptyCell[1] + 1]
				#grid[emptyCell[0]][emptyCell[1] + 1] = null
				#grid[emptyCell[0]][emptyCell[1]].topple(-1)
	if !floatingPieces:
		# stop gravity and fill grid; debug
		$GravityTimer.stop()
		fill_grid()
