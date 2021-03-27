extends MarginContainer
class_name Settings

signal fullscreen
signal windowed
signal back_to_menu

var config: ConfigFile
var isConfigChanged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_config(config: ConfigFile):
	self.config = config
	$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/DAS.text = String(config.get_value("tuning", "das"))
	$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/ARR.text = String(config.get_value("tuning", "arr"))
	$VBoxContainer/TabContainer/Video/HBoxContainer/Fullscreen.pressed = config.get_value("video", "fullscreen")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			_on_Back_pressed()

func _on_Back_pressed():
	# save config
	config.save("user://settings.cfg")
	emit_signal("back_to_menu", isConfigChanged, config)

func _on_Fullscreen_toggled(button_pressed):
	isConfigChanged = true
	if button_pressed:
		print("fullscreen")
		emit_signal("fullscreen")
	else:
		print("windowed")
		emit_signal("windowed")

func _on_DecreaseDAS_pressed():
	var das = config.get_value("tuning", "das")
	if das > 2:
		isConfigChanged = true
		das = das - 1
		$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/DAS.text = String(das)
		config.set_value("tuning", "das", das)

func _on_IncreaseDAS_pressed():
	var das = config.get_value("tuning", "das")
	if das < 99:
		isConfigChanged = true
		das = das + 1
		$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/DAS.text = String(das)
		config.set_value("tuning", "das", das)

func _on_DecreaseARR_pressed():
	var arr = config.get_value("tuning", "arr")
	if arr > 1:
		isConfigChanged = true
		arr = arr - 1
		$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/ARR.text = String(arr)
		config.set_value("tuning", "arr", arr)

func _on_IncreaseARR_pressed():
	var arr = config.get_value("tuning", "arr")
	if arr < 9:
		isConfigChanged = true
		arr = arr + 1
		$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/ARR.text = String(arr)
		config.set_value("tuning", "arr", arr)