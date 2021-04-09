extends Node2D
class_name FakeGameGrid

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cellSize: int
var cells: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# create grid and fill it with cells
func initialize_grid(horizontalPixels:int, verticalPixels:int):
	var margin = 3
	var gridHeight = 5
	var gridWidth = 11
	cellSize = ((verticalPixels / (gridHeight + 2)) - margin) / (sqrt(3) / 2)
	for rowIndex in range(gridHeight):
		cells.append([])
		for columnIndex in range(gridWidth):
			var polygon = Polygon2D.new()
			var polygonVectorArray = PoolVector2Array()
			polygonVectorArray.append(Vector2(-cellSize/2, -cellSize * sqrt(3) / 6))
			polygonVectorArray.append(Vector2(0, cellSize * sqrt(3) / 3))
			polygonVectorArray.append(Vector2(cellSize/2, (-1) * cellSize * sqrt(3) / 6))
			polygon.set_polygon(polygonVectorArray)
			polygon.position = Vector2(columnIndex * (cellSize/2 + margin) + horizontalPixels/5,
				verticalPixels - cellSize - (rowIndex * ((cellSize * sqrt(3) / 2) + margin)))
			# Flip cell if needed
			if ((rowIndex + columnIndex) % 2 == 0):
				polygon.scale = Vector2(1,-1)
				polygon.position = Vector2(polygon.position[0], polygon.position[1] + cellSize * sqrt(3) / 6 )
			cells[rowIndex].append(polygon)
			add_child(polygon)
			polygon.color = Color(0,0,0)

func set_cells_visible(number: int):
	var cutoff: int = number
	var degree: int = 0
	while cutoff > 55:
		cutoff = cutoff - 55
		degree = degree + 1
	for rowIndex in range(cells.size()):
		for columnIndex in range(cells[rowIndex].size()):
			cells[rowIndex][columnIndex].visible = number > rowIndex * cells[rowIndex].size() + columnIndex
			var innerDegree = degree
			if cutoff <= rowIndex * cells[rowIndex].size() + columnIndex:
				innerDegree = innerDegree - 1
			if innerDegree == 0:
				cells[rowIndex][columnIndex].set_color(Color(1, 1, 1))
			elif innerDegree == 1:
				cells[rowIndex][columnIndex].set_color(Color(0.870588, 0.4, 0.117647))
			elif innerDegree == 2:
				cells[rowIndex][columnIndex].set_color(Color.darkorchid)
			elif innerDegree == 3:
				cells[rowIndex][columnIndex].set_color(Color.yellow)
			elif innerDegree == 4:
				cells[rowIndex][columnIndex].set_color(Color.crimson)
			else:
				cells[rowIndex][columnIndex].set_color(Color(0, 0.75, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
