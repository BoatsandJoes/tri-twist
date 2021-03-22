extends PanelContainer
class_name HowToPlay

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_text(string1: String, string2: String):
	$VBoxContainer/Text1.text = string1
	$VBoxContainer/Text2.text = string2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass