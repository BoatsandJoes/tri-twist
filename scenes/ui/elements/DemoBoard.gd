extends Node2D
class_name DemoBoard

var TriangleDropper = load("res://scenes/TriangleDropper.tscn")
var triangleDropper: TriangleDropper
var Spinner = load("res://scenes/ui/elements/Spinner.tscn")
var spinner: Spinner
var chains: Dictionary = {}
var startingBoardState = null
var instructions: Array
var pieceSequence: PoolIntArray
var instructionTimer: Timer
var instructionIndex: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	spinner = Spinner.instance()
	add_child(spinner)
	spinner.init(40)
	spinner.position = Vector2(250, 175)
	triangleDropper = TriangleDropper.instance()
	add_child(triangleDropper)
	triangleDropper.position = Vector2(triangleDropper.position[0] - 30, triangleDropper.position[1])
	show_dropper()

func show_dropper():
	triangleDropper.gridHeight = 3
	triangleDropper.gridWidth = 7
	triangleDropper.screenHeight = 700
	triangleDropper.screenWidth = 700
	triangleDropper.init()
	triangleDropper.set_previews_visible(0)
	triangleDropper.mute()
	spinner.queue_free()
	if startingBoardState != null:
		set_up_demo_internal()

func set_demo_instructions(startingBoardState: Dictionary, instructions: Array, pieceSequence: PoolIntArray):
	self.instructions = instructions
	self.startingBoardState = startingBoardState
	self.pieceSequence = pieceSequence
	if is_instance_valid(triangleDropper):
		set_up_demo_internal()

func set_up_demo_internal():
	# Set up initial state
	instructionIndex = 0
	chains = {}
	triangleDropper.set_piece_sequence(pieceSequence)
	triangleDropper.deserialize(startingBoardState)
	if !is_instance_valid(instructionTimer):
		instructionTimer = Timer.new()
		add_child(instructionTimer)
		instructionTimer.one_shot = true
		instructionTimer.connect("timeout", self, "_on_instructionTimer_timeout")
	# Begin instruction execution
	instructionTimer.start(instructions[0][0])

func _on_instructionTimer_timeout():
	if instructions[instructionIndex][1] == "restart":
		set_up_demo_internal()
	elif instructionIndex < instructions.size():
		instructionTimer.start(instructions[instructionIndex + 1][0])
		triangleDropper.call(instructions[instructionIndex][1])
		instructionIndex = instructionIndex + 1

func get_chains():
	return chains

func has_chain(chainKey):
	return chains.has(chainKey)

func get_chain(chainKey) -> Dictionary:
	if chains.has(chainKey):
		return chains.get(chainKey)
	else:
		return {}

func upsert_chain(chainKey, chainValue, isLucky: bool):
	chains[chainKey] = chainValue

func delete_chain(chainKey):
	chains.erase(chainKey)

func end_combo_if_exists(comboKey):
	chains.erase(comboKey)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
