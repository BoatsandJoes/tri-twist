extends PanelContainer
class_name ButtonConfig

signal ready_pressed
signal back

var defaultDas: int = 12
var defaultArr: int = 2
var device: String
var isConfigChanged: bool = false
var config: ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(device: String, config: ConfigFile):
	self.device = device
	self.config = config
	$HBoxContainer/TuningMenu/Das/DasEdit.text = String(config.get_value("tuning", "das"))
	$HBoxContainer/TuningMenu/Arr/ArrEdit.text = String(config.get_value("tuning", "arr"))

func _input(event: InputEvent):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Tuning_pressed():
	$HBoxContainer/TopMenu/VBoxContainer2/Ready.pressed = false
	emit_signal("ready_pressed", false, config, isConfigChanged)
	$HBoxContainer/TopMenu.visible = false
	$HBoxContainer/TuningMenu.visible = true

func _on_GameButtons_pressed():
	$HBoxContainer/TopMenu/VBoxContainer2/Ready.pressed = false
	emit_signal("ready_pressed", false, config, isConfigChanged)
	$HBoxContainer/TopMenu.visible = false
	$HBoxContainer/GameButtonConfig.visible = true

func _on_MenuButtons_pressed():
	$HBoxContainer/TopMenu/VBoxContainer2/Ready.pressed = false
	emit_signal("ready_pressed", false, config, isConfigChanged)
	$HBoxContainer/TopMenu.visible = false
	$HBoxContainer/MenuButtonConfig.visible = true

func _on_DasEdit_text_changed(new_text):
	var das: int = int(new_text)
	if das >= 1 && das <= 99:
		isConfigChanged = true
		config.set_value("tuning", "das", das)
	else:
		$HBoxContainer/TuningMenu/Das/DasEdit.text = String(config.get_value("tuning", "das", defaultDas))

func _on_ArrEdit_text_changed(new_text):
	var arr: int = int(new_text)
	if arr >= 1 && arr <= 9:
		isConfigChanged = true
		config.set_value("tuning", "arr", arr)
	else:
		$HBoxContainer/TuningMenu/Arr/ArrEdit.text = String(config.get_value("tuning", "arr", defaultArr))

func _on_Das_mouse_entered():
	pass # Replace with function body.

func _on_Arr_mouse_entered():
	pass # Replace with function body.

func _on_DasDecrease_pressed():
	var das = int($HBoxContainer/TuningMenu/Das/DasEdit.text)
	$HBoxContainer/TuningMenu/Das/DasEdit.text = String(das - 1)
	_on_DasEdit_text_changed(String(das - 1))

func _on_DasIncrease_pressed():
	var das = int($HBoxContainer/TuningMenu/Das/DasEdit.text)
	$HBoxContainer/TuningMenu/Das/DasEdit.text = String(das + 1)
	_on_DasEdit_text_changed(String(das + 1))

func _on_ArrDecrease_pressed():
	var arr = int($HBoxContainer/TuningMenu/Arr/ArrEdit.text)
	$HBoxContainer/TuningMenu/Arr/ArrEdit.text = String(arr - 1)
	_on_ArrEdit_text_changed(String(arr - 1))

func _on_ArrIncrease_pressed():
	var arr = int($HBoxContainer/TuningMenu/Arr/ArrEdit.text)
	$HBoxContainer/TuningMenu/Arr/ArrEdit.text = String(arr + 1)
	_on_ArrEdit_text_changed(String(arr + 1))

func _on_TuningDefault_pressed():
	$HBoxContainer/TuningMenu/Das/DasEdit.text = String(defaultDas)
	$HBoxContainer/TuningMenu/Arr/ArrEdit.text = String(defaultArr)

func _on_TuningBack_pressed():
	if int($HBoxContainer/TuningMenu/Das/DasEdit.text) < 2:
		$HBoxContainer/TuningMenu/Das/DasEdit.text = "2"
	$HBoxContainer/TuningMenu.visible = false
	$HBoxContainer/TopMenu.visible = true

func _on_TuningDefault_mouse_entered():
	pass # Replace with function body.

func _on_TuningBack_mouse_entered():
	pass # Replace with function body.

func _on_TopBack_pressed():
	$HBoxContainer/TopMenu/VBoxContainer2/Ready.pressed = false
	emit_signal("ready_pressed", false, config, isConfigChanged)
	emit_signal("back", config, isConfigChanged)

func _on_Ready_toggled(button_pressed):
	emit_signal("ready_pressed", button_pressed, config, isConfigChanged)

func _on_GameBack_pressed():
	$HBoxContainer/GameButtonConfig.visible = false
	$HBoxContainer/TopMenu.visible = true

func _on_MenuBack_pressed():
	$HBoxContainer/MenuButtonConfig.visible = false
	$HBoxContainer/TopMenu.visible = true
