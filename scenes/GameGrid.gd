extends Node2D


export (PackedScene) var Triangle
export var triangleSize: int
export var margin: int
var grid: Array
var window: Rect2
var gravityTimer: Timer

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
	fill_grid()

func fill_grid():
	var emptyCell = get_empty_cell()
	while (emptyCell != [-1, -1]):
		var triangle = Triangle.instance()
		triangle.init(triangleSize)
		# set position
		triangle.position = get_triangle_position_for_cell(emptyCell[1], emptyCell[0])
		# flip every odd triangle
		if emptyCell[0] % 2 == 1:
			triangle.flip()
		# Place triangle in grid datastructure
		grid[emptyCell[1]][emptyCell[0]] = triangle
		# add triangle to scene tree
		add_child(triangle)
		# check empty cells again
		emptyCell = get_empty_cell()

func get_triangle_position_for_cell(rowIndex: int, triangleIndex: int) -> Vector2:
	return Vector2((window.size[0]/2) - triangleSize/2 +
				((triangleIndex - (grid[rowIndex].size()/2)) * ((triangleSize/2) + margin)),
				window.size[1] - triangleSize - (rowIndex * ((triangleSize * sqrt(3) / 2) + margin)))

func get_empty_cell():
	for rowIndex in grid.size():
		for triangleIndex in grid[rowIndex].size():
			if grid[rowIndex][triangleIndex] == null:
				return [triangleIndex,rowIndex]
	return [-1, -1]

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			for rowIndex in grid.size():
				for triangleIndex in grid[rowIndex].size():
					if grid[rowIndex][triangleIndex] != null && grid[rowIndex][triangleIndex].triangleFocused:
						handle_triangle_input(rowIndex, triangleIndex, event)
	elif event is InputEventKey && event.is_action_pressed("ui_accept"):
		# kick off gravity, debug
		$GravityTimer.start()
	elif event is InputEventKey && event.is_action_pressed("ui_escape"):
		get_tree().quit()

func handle_triangle_input(rowIndex: int, triangleIndex: int, event: InputEventMouseButton):
	if event.button_index == 3:
		# delete tile, debug
		grid[rowIndex][triangleIndex].free()
	if event.button_index == 1 || event.button_index == 2:
		# rotate
		var rotation
		if event.button_index == 1:
			rotation = -1
		else:
			rotation = 1
		grid[rowIndex][triangleIndex].spin(rotation)
		# Get and rotate neighbors opposite way
		rotation = -rotation
		if triangleIndex > 0 && grid[rowIndex][triangleIndex - 1] != null:
			grid[rowIndex][triangleIndex - 1].spin(rotation)
		if triangleIndex < grid[rowIndex].size() - 1 && grid[rowIndex][triangleIndex + 1] != null:
			grid[rowIndex][triangleIndex + 1].spin(rotation)
		if grid[rowIndex][triangleIndex].pointFacingUp && rowIndex > 0 && grid[rowIndex - 1][triangleIndex - 1] != null:
			grid[rowIndex - 1][triangleIndex - 1].spin(rotation)
		elif !grid[rowIndex][triangleIndex].pointFacingUp && rowIndex < grid.size() - 1 && grid[rowIndex + 1][triangleIndex + 1] != null:
			grid[rowIndex + 1][triangleIndex + 1].spin(rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func move_triangle_down_one_step(rowIndex: int, triangleIndex: int):
	#TODO
	pass

func _on_GravityTimer_timeout():
	var floatingPieces = false
	# scan for floating pieces
	var emptyCell = get_empty_cell()
	if emptyCell != [-1, -1]:
		if emptyCell[0]%2 != 1:
			# Check cell above
			if emptyCell[1] < grid.size() - 1 && grid[emptyCell[1] + 1][emptyCell[0] + 1] != null:
				floatingPieces = true
				move_triangle_down_one_step(emptyCell[1] + 1, emptyCell[0] + 1)
		else:
			# Check left neighbor
			if emptyCell[0] > 0 && grid[emptyCell[1]][emptyCell[0] - 1] != null:
				# Move piece right
				grid[emptyCell[1]][emptyCell[0]] = grid[emptyCell[1]][emptyCell[0] - 1]
				grid[emptyCell[1]][emptyCell[0] - 1] = null
				grid[emptyCell[1]][emptyCell[0]].topple(1)
			# Check right neighbor
			elif emptyCell[0] < grid[emptyCell[1]].size() - 1 && grid[emptyCell[1]][emptyCell[0] + 1] != null:
				# Move piece left
				grid[emptyCell[1]][emptyCell[0]] = grid[emptyCell[1]][emptyCell[0] + 1]
				grid[emptyCell[1]][emptyCell[0] + 1] = null
				grid[emptyCell[1]][emptyCell[0]].topple(-1)
	if !floatingPieces:
		# stop gravity and fill grid; debug
		$GravityTimer.stop()
		fill_grid()
