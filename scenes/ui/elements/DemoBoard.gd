extends Node2D
class_name DemoBoard

var TriangleDropper = load("res://scenes/TriangleDropper.tscn")
var triangleDropper: TriangleDropper
var Spinner = load("res://scenes/ui/elements/Spinner.tscn")
var spinner: Spinner
var chains: Dictionary = {}

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
	triangleDropper.screenHeight = 500
	triangleDropper.screenWidth = 500
	triangleDropper.init()
	triangleDropper.set_previews_visible(0)
	spinner.queue_free()

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
