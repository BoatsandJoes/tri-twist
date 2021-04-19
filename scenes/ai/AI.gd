extends Node2D
class_name AI

enum Direction {LEFT, RIGHT, VERT}
var best_move_column: int = 5
var best_move_rotation: int = Direction.VERT
var best_move_rating: int = 0
var threads: Array
var semaphore: Semaphore
var threadcount: int = 1
var exitThreads: bool = false
var exitThreadsMutex: Mutex
var bestMoveMutex: Mutex

# Called when the node enters the scene tree for the first time.
func _ready():
	exitThreadsMutex = Mutex.new()
	bestMoveMutex = Mutex.new()
	semaphore = Semaphore.new()
	for i in range(threadcount):
		threads.append(Thread.new())
		threads[i].start(self, "_thread_function")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func find_possible_moves(nextFewPieceEdgeColors: Array, boardStateDictionary):
	boardStateDictionary["activePieceColumnIndex"]
	#for row in gameGrid.grid:
	#	for cell in row:
	#		colors.append(cell.leftColor)
	#		colors.append(cell.rightColor)
	#		colors.append(cell.verticalColor)
	boardStateDictionary["boardColors"]

func find_best_move():
	semaphore.post()

func get_best_move():
	bestMoveMutex.lock()
	var column = best_move_column
	var rotation = best_move_rotation
	bestMoveMutex.unlock()
	return [column, rotation]

# Run here and exit.
# The argument is the userdata passed from start().
# If no argument was passed, this one still needs to
# be here and it will be null.
func _thread_function(userdata):
	while true:
		semaphore.wait() # Wait until posted.
		exitThreadsMutex.lock()
		var should_exit = exitThreads # Protect with Mutex.
		exitThreadsMutex.unlock()
		if should_exit:
			break
		bestMoveMutex.lock()
		best_move_column = randi() % 11
		best_move_rotation = randi() % 3
		bestMoveMutex.unlock()

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	exitThreadsMutex.lock()
	exitThreads = true
	exitThreadsMutex.unlock()
	semaphore.post()
	for thread in threads:
		thread.wait_to_finish()