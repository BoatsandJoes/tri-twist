extends MarginContainer
class_name DeviceSelect

signal accept
signal cancel

var p1Device = null
var p2Device = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(p1Device, p2Device):
	Input.connect("joy_connection_changed", self, "_on_Input_joy_connection_changed")
	update_device_list()

func update_device_list():
	var devices: Array = Input.get_connected_joypads()
	for child in $HBoxContainer/AllDevices.get_children():
		if is_instance_valid(child):
			if child.get_node("Label").text == "Hacky":
				create_new_label(child, "Keyboard")
				create_new_label(child, "Keyboard&Mouse")
				for device in devices:
					create_new_label(child, "Controller " + String(device + 1))

func create_new_label(labelToDuplicate, text):
	var label = labelToDuplicate.duplicate()
	label.get_node("Label").text = text
	label.visible = true
	$HBoxContainer/AllDevices.add_child(label)
	var leftPosition = label.get_node("LeftArrow").position
	var rightPosition = label.get_node("RightArrow").position
	var widthHeight = label.get_node("Label").get_rect().size
	label.get_node("LeftArrow").position = Vector2(leftPosition[0] - 50, leftPosition[1] + widthHeight[1] / 2 - 3)
	label.get_node("RightArrow").position = Vector2(rightPosition[0] + widthHeight[0] + 48, rightPosition[1] + widthHeight[1] / 2 - 3)

func move_label_left(text: String):
	pass

func move_label_right(text: String):
	pass

func _input(event):
	if event.is_action_pressed("left"):
		# Move device left
		if event is InputEventKey:
			move_label_left("Keyboard")
		elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
			move_label_left("Controller " + event.device)
	elif event.is_action_pressed("right"):
		# Move device right
		if event is InputEventKey:
			move_label_right("Keyboard")
		elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
			move_label_right("Controller " + event.device)
	elif event.is_action_pressed("ui_accept"):
		if (false):
			# XXX Move device left if it is in the middle
			pass
		else:
			# Emit signal otherwise
			emit_signal("accept", p1Device, p2Device)
	elif event.is_action_pressed("ui_cancel"):
		if (false):
			# XXX Move device to middle if it is not in the middle
			pass
		else:
			# Emit signal otherwise
			emit_signal("cancel")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Input_joy_connection_changed(id,connected):
	if connected:
		var label
		for child in $HBoxContainer/AllDevices.get_children():
			if is_instance_valid(child):
				create_new_label(child, "Controller " + String(id + 1))
				break
	else:
		var found: bool = false
		for child in $HBoxContainer/AllDevices.get_children():
			if (is_instance_valid(child) &&
			child.get_node("Label").text.substr(child.get_node("Label").text.find_last(" ") + 1, 2).to_int() - 1 == id):
				child.queue_free()
				break
		if !found:
			for child in $HBoxContainer/Player1Device.get_children():
				if (is_instance_valid(child) &&
				child.get_node("Label").text.substr(child.get_node("Label").text.find_last(" ") + 1, 2).to_int() - 1 == id):
					child.queue_free()
					p1Device = null
					break
		if !found:
			for child in $HBoxContainer/Player2Device.get_children():
				if (is_instance_valid(child) &&
				child.get_node("Label").text.substr(child.get_node("Label").text.find_last(" ") + 1, 2).to_int() - 1 == id):
					child.queue_free()
					p2Device = null
					break