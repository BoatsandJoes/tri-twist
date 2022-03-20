extends MarginContainer
class_name Settings

signal fullscreen
signal windowed
signal back_to_menu
signal devices_set

var config: ConfigFile
var isConfigChanged: bool = false
var p1Device = "CPU"
var p2Device = "CPU"
var DeviceSelect = load("res://scenes/ui/mainMenu/settings/controls/DeviceSelect.tscn")
var deviceSelect: DeviceSelect

# Called when the node enters the scene tree for the first time.
func _ready():
	select_fullscreen()

func set_config(config: ConfigFile, p1Device, p2Device):
	self.config = config
	set_volume(config.get_value("audio", "volume"))
	self.p1Device = p1Device
	self.p2Device = p2Device
	var fullscreen = config.get_value("video", "fullscreen")
	if fullscreen:
		$VBoxContainer/MainArea/TopOptions/HBoxContainer/Fullscreen.text = "Fullscreen"

func select_fullscreen():
	var widthHeight = $VBoxContainer/MainArea/TopOptions/HBoxContainer/Fullscreen.get_rect().size
	$VBoxContainer/MainArea/TopOptions/HBoxContainer/SelectArrow.position = Vector2(widthHeight[0], widthHeight[1] / 2 - 3)
	$VBoxContainer/MainArea/TopOptions/HBoxContainer/SelectArrow.visible = true
	$VBoxContainer/MainArea/TopOptions/HBoxContainer2/SelectArrow.visible = false
	$VBoxContainer/MainArea/TopOptions/HBoxContainer3/SelectArrow.visible = false
	$VBoxContainer/MainArea/TopOptions/HBoxContainer4/SelectArrow.visible = false

func is_fullscreen_selected():
	return $VBoxContainer/MainArea/TopOptions/HBoxContainer/SelectArrow.visible

func select_controls():
	var widthHeight = $VBoxContainer/MainArea/TopOptions/HBoxContainer2/Controls.get_rect().size
	$VBoxContainer/MainArea/TopOptions/HBoxContainer2/SelectArrow.position = Vector2(widthHeight[0], widthHeight[1] / 2 - 3)
	$VBoxContainer/MainArea/TopOptions/HBoxContainer/SelectArrow.visible = false
	$VBoxContainer/MainArea/TopOptions/HBoxContainer2/SelectArrow.visible = true
	$VBoxContainer/MainArea/TopOptions/HBoxContainer3/SelectArrow.visible = false
	$VBoxContainer/MainArea/TopOptions/HBoxContainer4/SelectArrow.visible = false

func is_controls_selected():
	return $VBoxContainer/MainArea/TopOptions/HBoxContainer2/SelectArrow.visible

func select_volume():
	var widthHeight = $VBoxContainer/MainArea/TopOptions/HBoxContainer4/Volume.get_rect().size
	$VBoxContainer/MainArea/TopOptions/HBoxContainer4/SelectArrow.position = Vector2(widthHeight[0], widthHeight[1] / 2 - 3)
	$VBoxContainer/MainArea/TopOptions/HBoxContainer/SelectArrow.visible = false
	$VBoxContainer/MainArea/TopOptions/HBoxContainer2/SelectArrow.visible = false
	$VBoxContainer/MainArea/TopOptions/HBoxContainer3/SelectArrow.visible = false
	$VBoxContainer/MainArea/TopOptions/HBoxContainer4/SelectArrow.visible = true

func is_volume_selected():
	return $VBoxContainer/MainArea/TopOptions/HBoxContainer4/SelectArrow.visible

func select_back():
	var widthHeight = $VBoxContainer/MainArea/TopOptions/HBoxContainer3/Back.get_rect().size
	$VBoxContainer/MainArea/TopOptions/HBoxContainer3/SelectArrow.position = Vector2(widthHeight[0], widthHeight[1] / 2 - 3)
	$VBoxContainer/MainArea/TopOptions/HBoxContainer/SelectArrow.visible = false
	$VBoxContainer/MainArea/TopOptions/HBoxContainer2/SelectArrow.visible = false
	$VBoxContainer/MainArea/TopOptions/HBoxContainer3/SelectArrow.visible = true
	$VBoxContainer/MainArea/TopOptions/HBoxContainer4/SelectArrow.visible = false

func is_back_selected():
	return $VBoxContainer/MainArea/TopOptions/HBoxContainer3/SelectArrow.visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if ((event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton)
	&& $VBoxContainer/MainArea/TopOptions.visible):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			_on_Back_pressed()
		elif event.is_action_pressed("ui_accept"):
			if is_fullscreen_selected():
				_on_Fullscreen_pressed()
			elif is_controls_selected():
				_on_Controls_pressed()
			elif is_volume_selected():
				_on_Volume_pressed()
			elif is_back_selected():
				_on_Back_pressed()
		elif event.is_action_pressed("ui_down"):
			if is_fullscreen_selected():
				select_controls()
			elif is_controls_selected():
				select_volume()
			elif is_volume_selected():
				select_back()
			elif is_back_selected():
				select_fullscreen()
		elif event.is_action_pressed("ui_up"):
			if is_fullscreen_selected():
				select_back()
			elif is_controls_selected():
				select_fullscreen()
			elif is_volume_selected():
				select_controls()
			elif is_back_selected():
				select_volume()

func _on_Back_pressed():
	# save config
	emit_signal("back_to_menu", isConfigChanged, config)

func _on_Fullscreen_pressed():
	isConfigChanged = true
	if $VBoxContainer/MainArea/TopOptions/HBoxContainer/Fullscreen.text == "Windowed":
		$VBoxContainer/MainArea/TopOptions/HBoxContainer/Fullscreen.text = "Fullscreen"
		emit_signal("fullscreen")
	else:
		$VBoxContainer/MainArea/TopOptions/HBoxContainer/Fullscreen.text = "Windowed"
		emit_signal("windowed")

func _on_Controls_pressed():
	$VBoxContainer/MainArea/TopOptions.visible = false
	deviceSelect = DeviceSelect.instance()
	$VBoxContainer/MainArea.add_child(deviceSelect)
	deviceSelect.init(p1Device, p2Device, config)
	deviceSelect.connect("cancel", self, "_on_DeviceSelect_cancel")
	deviceSelect.connect("config_changed", self, "_on_DeviceSelect_config_changed")
	deviceSelect.connect("everyone_ready", self, "_on_DeviceSelect_everyone_ready")

func _on_Volume_pressed():
	isConfigChanged = true
	var volume = int($VBoxContainer/MainArea/TopOptions/HBoxContainer4/Volume.text.substr(8, 3))
	volume = volume - 10
	if volume < 0:
		volume = 100
	self.config.set_value("audio", "volume", volume)
	set_volume(volume)

func set_volume(volume):
	$VBoxContainer/MainArea/TopOptions/HBoxContainer4/Volume.text = $VBoxContainer/MainArea/TopOptions/HBoxContainer4/Volume.text.substr(0, 8) + String(volume)

func _on_DeviceSelect_cancel():
	deviceSelect.visible = false
	deviceSelect.queue_free()
	$VBoxContainer/MainArea/TopOptions.visible = true

func _on_DeviceSelect_config_changed(config: ConfigFile):
	self.config = config
	isConfigChanged = true

func _on_DeviceSelect_everyone_ready(p1Device, p2Device):
	self.p1Device = p1Device
	self.p2Device = p2Device
	emit_signal("devices_set", p1Device, p2Device)
	_on_DeviceSelect_cancel()
