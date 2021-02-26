extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (PackedScene) var Triangle
var grid: Array
var window: Rect2
const margin = 3
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	window = OS.get_window_safe_area()
	_initialize_grid()

func _initialize_grid():
	grid = [[null, null, null],
			[null, null, null, null, null],
			[null, null, null, null, null, null, null],
			[null, null, null, null, null, null, null, null, null],
			[null, null, null, null, null, null, null, null, null, null, null]]
	_fill_grid()

func _fill_grid():
	var emptyCell = _get_empty_cell()
	while (emptyCell != [-1, -1]):
		var triangle = Triangle.instance()
		# set position
		var position = Vector2((window.size[0]/2) - triangle.size/2 +
				((emptyCell[0] - (grid[emptyCell[1]].size()/2)) * ((triangle.size/2) + margin)),
				window.size[1] - triangle.size - (emptyCell[1] * ((triangle.size * sqrt(3) / 2) + margin)))
		triangle.position = position
		# flip every odd triangle
		if emptyCell[0] % 2 == 1:
			triangle.flip()
		# Place triangle in grid datastructure
		grid[emptyCell[1]][emptyCell[0]] = triangle
		# add triangle to scene tree
		add_child(triangle)
		# check empty cells again
		emptyCell = _get_empty_cell()

func _get_empty_cell():
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
		# fill grid, debug
		_fill_grid()
	elif event is InputEventKey && event.is_action_pressed("ui_escape"):
		get_tree().quit()

func handle_triangle_input(rowIndex: int, triangleIndex: int, event: InputEventMouseButton):
	if event.button_index == 3:
		# delete tile, debug
		grid[rowIndex][triangleIndex].free()
		# increment score, debug
		score = score + 1
		print(score)
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
		if grid[rowIndex][triangleIndex].upsideDown && rowIndex > 0 && grid[rowIndex - 1][triangleIndex - 1] != null:
			grid[rowIndex - 1][triangleIndex - 1].spin(rotation)
		elif !grid[rowIndex][triangleIndex].upsideDown && rowIndex < grid.size() - 1 && grid[rowIndex + 1][triangleIndex + 1] != null:
			grid[rowIndex + 1][triangleIndex + 1].spin(rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
