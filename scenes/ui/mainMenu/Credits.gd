extends Control
class_name Credits

signal back_to_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton) && event.is_pressed():
		if (event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_down") || event.is_action_pressed("ui_right") || 
		event.is_action_pressed("ui_select") || event.is_action_pressed("hard_drop")):
			advance()
		elif (event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel") || event.is_action_pressed("ui_left") ||
		event.is_action_pressed("ui_up")):
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
