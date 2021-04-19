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
	pass

func set_config(config: ConfigFile, p1Device, p2Device):
	self.config = config
	self.p1Device = p1Device
	self.p2Device = p2Device
	var fullscreen = config.get_value("video", "fullscreen")
	if !fullscreen:
		$VBoxContainer/MainArea/TopOptions/Fullscreen.text = "Windowed"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			_on_Back_pressed()

func _on_Back_pressed():
	# save config
	emit_signal("back_to_menu", isConfigChanged, config)

func _on_Fullscreen_pressed():
	isConfigChanged = true
	if $VBoxContainer/MainArea/TopOptions/Fullscreen.text == "Windowed":
		$VBoxContainer/MainArea/TopOptions/Fullscreen.text = "Fullscreen"
		emit_signal("fullscreen")
	else:
		$VBoxContainer/MainArea/TopOptions/Fullscreen.text = "Windowed"
		emit_signal("windowed")

func _on_Controls_pressed():
	$VBoxContainer/MainArea/TopOptions.visible = false
	deviceSelect = DeviceSelect.instance()
	$VBoxContainer/MainArea.add_child(deviceSelect)
	deviceSelect.init(p1Device, p2Device, config)
	deviceSelect.connect("cancel", self, "_on_DeviceSelect_cancel")
	deviceSelect.connect("config_changed", self, "_on_DeviceSelect_config_changed")
	deviceSelect.connect("everyone_ready", self, "_on_DeviceSelect_everyone_ready")

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