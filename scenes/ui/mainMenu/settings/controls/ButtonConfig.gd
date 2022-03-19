extends PanelContainer
class_name ButtonConfig

signal ready_pressed
signal back

var defaultDas: int = 12
var defaultArr: int = 2
var device: String
var isConfigChanged: bool = false
var config: ConfigFile
var SelectArrow = load("res://scenes/ui/elements/SelectArrow.tscn")
var selectArrow: SelectArrow

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(device: String, config: ConfigFile):
	self.device = device
	self.config = config
	$HBoxContainer/TuningMenu/Das/DasEdit.text = String(config.get_value("tuning", "das"))
	$HBoxContainer/TuningMenu/Arr/ArrEdit.text = String(config.get_value("tuning", "arr"))
	for child in $HBoxContainer/TopMenu.get_children():
		for innerChild in child.get_children():
			if innerChild.has_node("SelectArrow"):
				var widthHeight = innerChild.get_child(0).get_rect().size
				innerChild.get_node("SelectArrow").position = Vector2(widthHeight[0], widthHeight[1] / 2 - 3)
	for child in $HBoxContainer/TuningMenu.get_children():
		if child.has_node("SelectArrow"):
			var widthHeight = child.get_rect().size
			child.get_node("SelectArrow").position = Vector2(widthHeight[0], widthHeight[1] / 2 - 3)
		if child.has_node("LeftSelectArrow"):
			var widthHeight = child.get_rect().size
			child.get_node("LeftSelectArrow").position = Vector2(50, widthHeight[1] / 2)
		if child.has_node("RightSelectArrow"):
			var widthHeight = child.get_rect().size
			child.get_node("RightSelectArrow").position = Vector2(widthHeight[0] + 48, widthHeight[1] / 2)

func make_all_top_menu_arrows_invisible():
	for child in $HBoxContainer/TopMenu.get_children():
		for innerChild in child.get_children():
			if innerChild.has_node("SelectArrow"):
				innerChild.get_node("SelectArrow").visible = false

func make_all_tuning_menu_arrows_invisible():
	for child in $HBoxContainer/TuningMenu.get_children():
		if child.has_node("SelectArrow"):
			child.get_node("SelectArrow").visible = false
		if child.has_node("LeftSelectArrow"):
			child.get_node("LeftSelectArrow").visible = false
		if child.has_node("RightSelectArrow"):
			child.get_node("RightSelectArrow").visible = false

func _input(event: InputEvent):
	if ((event is InputEventKey && device == "Keyboard") || (event is InputEventMouseButton && device == "Mouse")
	|| (((event is InputEventJoypadButton || event is InputEventJoypadMotion) && device.begins_with("Controller"))
	&& event.device == int(device.substr(device.find(" ") + 1, 2)) - 1)):
		if !(event is InputEventMouseButton) || device != "Mouse":
			get_tree().set_input_as_handled()
		if $HBoxContainer/TopMenu.visible:
			if event.is_action_pressed("ui_up"):
				if $HBoxContainer/TopMenu/VBoxContainer/Tuning/SelectArrow.visible:
					make_all_top_menu_arrows_invisible()
					$HBoxContainer/TopMenu/VBoxContainer2/Ready/SelectArrow.visible = true
				elif $HBoxContainer/TopMenu/VBoxContainer2/TopBack/SelectArrow.visible:
					make_all_top_menu_arrows_invisible()
					$HBoxContainer/TopMenu/VBoxContainer/Tuning/SelectArrow.visible = true
				elif $HBoxContainer/TopMenu/VBoxContainer2/Ready/SelectArrow.visible:
					make_all_top_menu_arrows_invisible()
					$HBoxContainer/TopMenu/VBoxContainer2/TopBack/SelectArrow.visible = true
			elif event.is_action_pressed("ui_down"):
				if $HBoxContainer/TopMenu/VBoxContainer/Tuning/SelectArrow.visible:
					make_all_top_menu_arrows_invisible()
					$HBoxContainer/TopMenu/VBoxContainer2/TopBack/SelectArrow.visible = true
				elif $HBoxContainer/TopMenu/VBoxContainer2/TopBack/SelectArrow.visible:
					make_all_top_menu_arrows_invisible()
					$HBoxContainer/TopMenu/VBoxContainer2/Ready/SelectArrow.visible = true
				elif $HBoxContainer/TopMenu/VBoxContainer2/Ready/SelectArrow.visible:
					make_all_top_menu_arrows_invisible()
					$HBoxContainer/TopMenu/VBoxContainer/Tuning/SelectArrow.visible = true
			elif event.is_action_pressed("ui_accept"):
				if $HBoxContainer/TopMenu/VBoxContainer/Tuning/SelectArrow.visible:
					_on_Tuning_pressed()
				elif $HBoxContainer/TopMenu/VBoxContainer2/TopBack/SelectArrow.visible:
					_on_TopBack_pressed()
				elif $HBoxContainer/TopMenu/VBoxContainer2/Ready/SelectArrow.visible:
					$HBoxContainer/TopMenu/VBoxContainer2/Ready/Ready.pressed = (
					!$HBoxContainer/TopMenu/VBoxContainer2/Ready/Ready.pressed)
					_on_Ready_toggled($HBoxContainer/TopMenu/VBoxContainer2/Ready/Ready.pressed)
			elif event.is_action_pressed("ui_cancel"):
				_on_TopBack_pressed()
		elif $HBoxContainer/TuningMenu.visible:
			if event.is_action_pressed("ui_up"):
				if $HBoxContainer/TuningMenu/Das/RightSelectArrow.visible:
					make_all_tuning_menu_arrows_invisible()
					$HBoxContainer/TuningMenu/TuningBack/SelectArrow.visible = true
				elif $HBoxContainer/TuningMenu/Arr/RightSelectArrow.visible:
					make_all_tuning_menu_arrows_invisible()
					$HBoxContainer/TuningMenu/Das/LeftSelectArrow.visible = true
					$HBoxContainer/TuningMenu/Das/RightSelectArrow.visible = true
				elif $HBoxContainer/TuningMenu/TuningDefault/SelectArrow.visible:
					make_all_tuning_menu_arrows_invisible()
					$HBoxContainer/TuningMenu/Arr/LeftSelectArrow.visible = true
					$HBoxContainer/TuningMenu/Arr/RightSelectArrow.visible = true
				elif $HBoxContainer/TuningMenu/TuningBack/SelectArrow.visible:
					make_all_tuning_menu_arrows_invisible()
					$HBoxContainer/TuningMenu/TuningDefault/SelectArrow.visible = true
			elif event.is_action_pressed("ui_down"):
				if $HBoxContainer/TuningMenu/Das/RightSelectArrow.visible:
					make_all_tuning_menu_arrows_invisible()
					$HBoxContainer/TuningMenu/Arr/LeftSelectArrow.visible = true
					$HBoxContainer/TuningMenu/Arr/RightSelectArrow.visible = true
				elif $HBoxContainer/TuningMenu/Arr/RightSelectArrow.visible:
					make_all_tuning_menu_arrows_invisible()
					$HBoxContainer/TuningMenu/TuningDefault/SelectArrow.visible = true
				elif $HBoxContainer/TuningMenu/TuningDefault/SelectArrow.visible:
					make_all_tuning_menu_arrows_invisible()
					$HBoxContainer/TuningMenu/TuningBack/SelectArrow.visible = true
				elif $HBoxContainer/TuningMenu/TuningBack/SelectArrow.visible:
					make_all_tuning_menu_arrows_invisible()
					$HBoxContainer/TuningMenu/Das/LeftSelectArrow.visible = true
					$HBoxContainer/TuningMenu/Das/RightSelectArrow.visible = true
			if event.is_action_pressed("left"):
				if $HBoxContainer/TuningMenu/Arr/LeftSelectArrow.visible:
					_on_ArrDecrease_pressed()
				elif $HBoxContainer/TuningMenu/Das/LeftSelectArrow.visible:
					_on_DasDecrease_pressed()
			elif event.is_action_pressed("right"):
				if $HBoxContainer/TuningMenu/Arr/RightSelectArrow.visible:
					_on_ArrIncrease_pressed()
				elif $HBoxContainer/TuningMenu/Das/RightSelectArrow.visible:
					_on_DasIncrease_pressed()
			elif event.is_action_pressed("ui_accept"):
				if $HBoxContainer/TuningMenu/TuningDefault/SelectArrow.visible:
					_on_TuningDefault_pressed()
				elif $HBoxContainer/TuningMenu/TuningBack/SelectArrow.visible:
					_on_TuningBack_pressed()
			elif event.is_action_pressed("ui_cancel"):
				_on_TuningBack_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Tuning_pressed():
	$HBoxContainer/TopMenu/VBoxContainer2/Ready/Ready.pressed = false
	emit_signal("ready_pressed", false, config, isConfigChanged)
	$HBoxContainer/TopMenu.visible = false
	make_all_tuning_menu_arrows_invisible()
	$HBoxContainer/TuningMenu/Das/LeftSelectArrow.visible = true
	$HBoxContainer/TuningMenu/Das/RightSelectArrow.visible = true
	$HBoxContainer/TuningMenu.visible = true

func _on_GameButtons_pressed():
	$HBoxContainer/TopMenu/VBoxContainer2/Ready/Ready.pressed = false
	emit_signal("ready_pressed", false, config, isConfigChanged)
	$HBoxContainer/TopMenu.visible = false
	$HBoxContainer/GameButtonConfig.visible = true

func _on_MenuButtons_pressed():
	$HBoxContainer/TopMenu/VBoxContainer2/Ready/Ready.pressed = false
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
	make_all_tuning_menu_arrows_invisible()
	$HBoxContainer/TuningMenu/Das/LeftSelectArrow.visible = true
	$HBoxContainer/TuningMenu/Das/RightSelectArrow.visible = true

func _on_Arr_mouse_entered():
	make_all_tuning_menu_arrows_invisible()
	$HBoxContainer/TuningMenu/Arr/LeftSelectArrow.visible = true
	$HBoxContainer/TuningMenu/Arr/RightSelectArrow.visible = true

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
	make_all_tuning_menu_arrows_invisible()
	$HBoxContainer/TuningMenu/TuningDefault/SelectArrow.visible = true

func _on_TuningBack_mouse_entered():
	make_all_tuning_menu_arrows_invisible()
	$HBoxContainer/TuningMenu/TuningBack/SelectArrow.visible = true

func _on_TopBack_pressed():
	$HBoxContainer/TopMenu/VBoxContainer2/Ready/Ready.pressed = false
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

func _on_Tuning_mouse_entered():
	make_all_top_menu_arrows_invisible()
	$HBoxContainer/TopMenu/VBoxContainer/Tuning/SelectArrow.visible = true

func _on_TopBack_mouse_entered():
	make_all_top_menu_arrows_invisible()
	$HBoxContainer/TopMenu/VBoxContainer2/TopBack/SelectArrow.visible = true

func _on_Ready_mouse_entered():
	make_all_top_menu_arrows_invisible()
	$HBoxContainer/TopMenu/VBoxContainer2/Ready/SelectArrow.visible = true
