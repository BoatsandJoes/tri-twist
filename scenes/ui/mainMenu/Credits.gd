extends Control
class_name Credits

signal back_to_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	get_tree().set_input_as_handled()
	if (event is InputEventScreenTouch) && event.is_pressed():
		advance()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		retreat()

func advance():
	if $Page1.visible:
		$Page1.visible = false
		$License.visible = true
	else:
		emit_signal("back_to_menu")

func retreat():
	if $License.visible:
		$Page1.visible = true
		$License.visible = false
	else:
		emit_signal("back_to_menu")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
