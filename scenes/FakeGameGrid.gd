extends Node2D
class_name FakeGameGrid

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cellSize: int
var cells: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_grid()

# create grid and fill it with cells
func initialize_grid():
	var margin = 3
	var gridHeight = 5
	var gridWidth = 11
	cellSize = ((1080 / (gridHeight + 2)) - margin) / (sqrt(3) / 2)
	for rowIndex in range(gridHeight):
		for columnIndex in range(gridWidth):
			var polygon = Polygon2D.new()
			var polygonVectorArray = PoolVector2Array()
			polygonVectorArray.append(Vector2((-1) * cellSize/2, (-1) * cellSize * sqrt(3) / 6))
			polygonVectorArray.append(Vector2(cellSize/2 + (-1) * cellSize/2, cellSize * sqrt(3) / 3))
			polygonVectorArray.append(Vector2(cellSize + (-1) * cellSize/2, (-1) * cellSize * sqrt(3) / 6))
			polygon.set_polygon(polygonVectorArray)
			polygon.position = Vector2(columnIndex * (cellSize/2 + margin) + 1920/5,
				1080 - cellSize - (rowIndex * ((cellSize * sqrt(3) / 2) + margin)))
			# Flip cell if needed
			if ((rowIndex + columnIndex) % 2 == 0):
				polygon.scale = Vector2(1,-1)
				polygon.position = Vector2(polygon.position[0], polygon.position[1] + cellSize * sqrt(3) / 6 )
			polygon.color = Color(0,0,0)
			cells.append(polygon)
			add_child(polygon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
