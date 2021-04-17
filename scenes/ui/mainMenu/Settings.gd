extends MarginContainer
class_name Settings

signal fullscreen
signal windowed
signal back_to_menu

var config: ConfigFile
var isConfigChanged: bool = false
var DeviceSelect = load("res://scenes/ui/mainMenu/settings/controls/DeviceSelect.tscn")
var deviceSelect: DeviceSelect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_config(config: ConfigFile):
	self.config = config
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
	deviceSelect.init(null, null, config)
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

func _on_DeviceSelect_everyone_ready():
	_on_DeviceSelect_cancel()