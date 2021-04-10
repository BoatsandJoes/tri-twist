extends PanelContainer
class_name HowToPlay

var demoPosition: Vector2
var demoWidthHeight: Vector2
var DemoBoard = load("res://scenes/ui/elements/DemoBoard.tscn")
var demoBoard: DemoBoard

# Called when the node enters the scene tree for the first time.
func _ready():
	demoBoard = DemoBoard.instance()
	add_child(demoBoard)

func set_text(string1: String, string2: String):
	$VBoxContainer/Text1.text = string1
	$VBoxContainer/Text2.text = string2

func set_demo(boardState: Dictionary, instructions: Array, pieceSequence: PoolIntArray):
	demoBoard.set_demo_instructions(boardState, instructions, pieceSequence)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass