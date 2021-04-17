extends MarginContainer
class_name DeviceSelect

signal cancel
signal config_changed
signal everyone_ready

var p1Device = null
var p2Device = null
var p1Ready = false
var p2Ready = false
var config
var ButtonConfig = load("res://scenes/ui/mainMenu/settings/controls/ButtonConfig.tscn")
var p1ButtonConfig
var p2ButtonConfig

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(p1Device, p2Device, config: ConfigFile):
	Input.connect("joy_connection_changed", self, "_on_Input_joy_connection_changed")
	self.p1Device = p1Device
	self.p2Device = p2Device
	self.config = config
	update_device_list()

func update_device_list():
	var devices: Array = Input.get_connected_joypads()
	if "Keyboard" == p1Device:
		create_new_label($HBoxContainer/Player1Device, "Keyboard")
	elif "Keyboard" == p2Device:
		create_new_label($HBoxContainer/Player2Device, "Keyboard")
	else:
		create_new_label($HBoxContainer/AllDevices, "Keyboard")
	if "Keyboard&Mouse" == p1Device:
		create_new_label($HBoxContainer/Player1Device, "Keyboard&Mouse")
	elif "Keyboard&Mouse" == p2Device:
		create_new_label($HBoxContainer/Player2Device, "Keyboard&Mouse")
	else:
		create_new_label($HBoxContainer/AllDevices, "Keyboard&Mouse")
	for device in devices:
		var string: String = "Controller " + String(device + 1)
		if string == p1Device:
			create_new_label($HBoxContainer/Player1Device, string)
		elif string == p2Device:
			create_new_label($HBoxContainer/Player2Device, string)
		else:
			create_new_label($HBoxContainer/AllDevices, string)

func create_new_label(container, text):
	var label
	for child in container.get_children():
		if is_instance_valid(child) && child.has_node("Label") && child.get_node("Label").text == "Hacky":
			label = child.duplicate()
	label.get_node("Label").text = text
	label.visible = true
	container.add_child(label)
	var widthHeight = label.get_node("Label").get_rect().size
	if label.has_node("LeftArrow"):
		var leftPosition
		if (label.has_node("LeftSpacing")):
			leftPosition = Vector2(label.get_node("Label").rect_position[0] + 94,
			label.get_node("Label").rect_position[1])
		else:
			leftPosition = label.get_node("Label").rect_position
		label.get_node("LeftArrow").position = Vector2(leftPosition[0] - 50, leftPosition[1] + widthHeight[1] / 2 - 3)
	else:
		# We are on the left side. Move confirmation text to bottom
		$HBoxContainer/Player1Device.move_child($HBoxContainer/Player1Device/Confirm, 3)
		$HBoxContainer/Player1Device/Confirm.visible = true
	if label.has_node("RightArrow"):
		var rightPosition = label.get_node("RightArrow").position
		label.get_node("RightArrow").position = Vector2(rightPosition[0] + widthHeight[0] + 48,
		rightPosition[1] + widthHeight[1] / 2 - 3)
	else:
		# We are on the right side. Move confirmation text to bottom
		$HBoxContainer/Player2Device.move_child($HBoxContainer/Player2Device/Confirm, 3)
		$HBoxContainer/Player2Device/Confirm.visible = true

func has_specific_label(container, label: String):
	var hasLabel: bool = false
	for child in container.get_children():
		if (is_instance_valid(child) && child.has_node("Label") && child.visible && child.get_node("Label").text == label):
			hasLabel = true
			break
	return hasLabel

func has_label(container):
	var hasLabel: bool = false
	for child in container.get_children():
		if (is_instance_valid(child) && child.has_node("Label") && child.visible):
			hasLabel = true
			break
	return hasLabel

func delete_label(container, text: String) -> bool:
	var found: bool = false
	for child in container.get_children():
		if (is_instance_valid(child) && child.has_node("Label") && (text == null || child.get_node("Label").text == text)):
			child.queue_free()
			found = true
			break
	if found && container.has_node("Confirm"):
		container.get_node("Confirm").visible = false
	return found

func find_label(container, text: String) -> bool:
	var hasLabel: bool = false
	for child in container.get_children():
		if (is_instance_valid(child) && child.has_node("Label") && child.get_node("Label").text == text):
			hasLabel = true
			break
	return hasLabel

func move_label_left(text: String):
	if delete_label($HBoxContainer/Player2Device, text):
		p2Device = null
		create_new_label($HBoxContainer/AllDevices, text)
	elif !has_label($HBoxContainer/Player1Device) && delete_label($HBoxContainer/AllDevices, text):
		p1Device = text
		create_new_label($HBoxContainer/Player1Device, text)

func move_label_right(text: String):
	if delete_label($HBoxContainer/Player1Device, text):
		p1Device = null
		create_new_label($HBoxContainer/AllDevices, text)
	elif !has_label($HBoxContainer/Player2Device) && delete_label($HBoxContainer/AllDevices, text):
		p2Device = text
		create_new_label($HBoxContainer/Player2Device, text)

func ready_check():
	if (p1Ready && p2Ready) || (p1Ready && p2Device == null) || (p2Ready && p1Device == null):
		emit_signal("everyone_ready", p1Device, p2Device)

func _input(event):
	if event.is_action_pressed("left"):
		# Move device left
		if event is InputEventKey:
			move_label_left("Keyboard")
		elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
			move_label_left("Controller " + String(event.device + 1))
	elif event.is_action_pressed("right"):
		# Move device right
		if event is InputEventKey:
			move_label_right("Keyboard")
		elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
			move_label_right("Controller " + String(event.device + 1))
	elif event.is_action_pressed("ui_accept"):
		var labelText: String = ""
		if (event is InputEventJoypadButton || event is InputEventJoypadMotion):
			labelText = "Controller " + String(event.device + 1)
		elif (event is InputEventKey):
			labelText = "Keyboard"
		
		if find_label($HBoxContainer/AllDevices, labelText):
			# Try to move device left if it is in the middle
			move_label_left(labelText)
		else:
			# Open button config
			if has_specific_label($HBoxContainer/Player1Device, labelText):
				for child in $HBoxContainer/Player1Device.get_children():
					if !child is Label:
						child.visible = false
				p1ButtonConfig = ButtonConfig.instance()
				$HBoxContainer/Player1Device.add_child(p1ButtonConfig)
				p1ButtonConfig.init(p1Device, config)
				p1ButtonConfig.connect("ready_pressed", self, "_on_p1ButtonConfig_ready_pressed")
				p1ButtonConfig.connect("back", self, "_on_p1ButtonConfig_back")

			elif has_specific_label($HBoxContainer/Player2Device, labelText):
				for child in $HBoxContainer/Player2Device.get_children():
					if !child is Label:
						child.visible = false
				p2ButtonConfig = ButtonConfig.instance()
				$HBoxContainer/Player2Device.add_child(p2ButtonConfig)
				p2ButtonConfig.init(p2Device, config)
				p2ButtonConfig.connect("ready_pressed", self, "_on_p2ButtonConfig_ready_pressed")
				p2ButtonConfig.connect("back", self, "_on_p2ButtonConfig_back")
			
	elif event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		var labelText: String = ""
		if (event is InputEventJoypadButton || event is InputEventJoypadMotion):
			labelText = "Controller " + String(event.device + 1)
		elif (event is InputEventKey):
			labelText = "Keyboard"
		elif event is InputEventMouseButton:
			labelText = "Keyboard&Mouse"
		if (find_label($HBoxContainer/Player1Device, labelText)):
			# Move device to middle if it is not in the middle
			move_label_right(labelText)
		elif (find_label($HBoxContainer/Player2Device, labelText)):
			# Move device to middle if it is not in the middle
			move_label_left(labelText)
		else:
			# Emit signal otherwise
			emit_signal("cancel")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Input_joy_connection_changed(id,connected):
	if connected:
		create_new_label($HBoxContainer/AllDevices, "Controller " + String(id + 1))
	elif !delete_label($HBoxContainer/AllDevices, "Controller " + String(id + 1)):
		if delete_label($HBoxContainer/Player1Device, "Controller " + String(id + 1)):
			p1Device = null
		elif delete_label($HBoxContainer/Player2Device, "Controller " + String(id + 1)):
			p2Device = null

func _on_p1ButtonConfig_ready_pressed(isReadyPressed: bool, config: ConfigFile, isConfigChanged: bool):
	if isConfigChanged:
		self.config = config
		emit_signal("config_changed", config)
	p1Ready = isReadyPressed
	ready_check()

func _on_p1ButtonConfig_back(config: ConfigFile, isConfigChanged: bool):
	p1ButtonConfig.queue_free()
	for child in $HBoxContainer/Player1Device.get_children():
		if is_instance_valid(child) && !(child.has_node("Label") && child.get_node("Label").text == "Hacky"):
			child.visible = true
	if isConfigChanged:
		self.config = config
		emit_signal("config_changed", config)

func _on_p2ButtonConfig_ready_pressed(isReadyPressed:bool, config: ConfigFile, isConfigChanged: bool):
	if isConfigChanged:
		self.config = config
		emit_signal("config_changed", config)
	p2Ready = isReadyPressed
	ready_check()

func _on_p2ButtonConfig_back(config: ConfigFile, isConfigChanged: bool):
	p2ButtonConfig.queue_free()
	for child in $HBoxContainer/Player2Device.get_children():
		if is_instance_valid(child) && !(child.has_node("Label") && child.get_node("Label").text == "Hacky"):
			child.visible = true
	if isConfigChanged:
		self.config = config
		emit_signal("config_changed", config)