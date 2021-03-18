extends Control
class_name TitleScreen

signal start
signal exit

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton) && event.is_pressed():
		get_tree().set_input_as_handled()
		if event.is_action_pressed("ui_escape"):
			emit_signal("exit")
		else:
			emit_signal("start")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
