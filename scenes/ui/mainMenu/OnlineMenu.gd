extends Control
class_name OnlineMenu

signal back
signal start

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if ($MarginContainer.visible && (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton)):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel") || event.is_action_pressed("ui_accept"):
			_on_Back_pressed()


func _on_Back_pressed():
	emit_signal("back")

func _on_Join_pressed():
	pass # Replace with function body.

func _on_Host_pressed():
	pass # Replace with function body.
