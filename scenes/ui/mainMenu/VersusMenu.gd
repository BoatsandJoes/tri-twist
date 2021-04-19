extends MarginContainer
class_name VersusMenu

signal back_to_menu
signal start

var DeviceSelect = load("res://scenes/ui/mainMenu/settings/controls/DeviceSelect.tscn")
var deviceSelect: DeviceSelect
var p1Device
var p2Device
var config: ConfigFile
var isConfigChanged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(p1Device, p2Device, config: ConfigFile):
	self.p1Device = p1Device
	self.p2Device = p2Device
	self.config = config
	create_device_select()

func create_device_select():
	deviceSelect = DeviceSelect.instance()
	$VBoxContainer/MainArea/ModeModal.visible = false
	$VBoxContainer/MainArea.add_child(deviceSelect)
	deviceSelect.init(p1Device, p2Device, config)
	deviceSelect.connect("cancel", self, "_on_DeviceSelect_cancel")
	deviceSelect.connect("config_changed", self, "_on_DeviceSelect_config_changed")
	deviceSelect.connect("everyone_ready", self, "_on_DeviceSelect_everyone_ready")

func initialize_mode_modal():
	$VBoxContainer/MainArea/ModeModal.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_DeviceSelect_cancel():
	emit_signal("back_to_menu", config, isConfigChanged, "CPU", "CPU")

func _on_DeviceSelect_config_changed(config: ConfigFile):
	self.config = config
	isConfigChanged = true

func _on_DeviceSelect_everyone_ready(p1Device, p2Device):
	self.p1Device = p1Device
	self.p2Device = p2Device
	deviceSelect.queue_free()
	deviceSelect.visible = false
	initialize_mode_modal()

func _on_Start_pressed():
	emit_signal("start", p1Device, p2Device, config, isConfigChanged)

func _on_Back_pressed():
	create_device_select()
