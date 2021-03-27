extends MarginContainer
class_name Settings

signal fullscreen
signal windowed
signal back_to_menu
signal das_changed
signal arr_changed

var das: int = 12
var arr: int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_das(das: int):
	self.das = das
	$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/DAS.text = String(das)

func set_arr(arr: int):
	self.arr = arr
	$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/ARR.text = String(arr)

func set_fullscreen(fullscreen: bool):
	$VBoxContainer/TabContainer/Video/HBoxContainer/Fullscreen.pressed = fullscreen

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			_on_Back_pressed()

func _on_Back_pressed():
	emit_signal("back_to_menu")

func _on_Fullscreen_toggled(button_pressed):
	if button_pressed:
		print("fullscreen")
		emit_signal("fullscreen")
	else:
		print("windowed")
		emit_signal("windowed")

func _on_DecreaseDAS_pressed():
	if das > 2:
		das = das - 1
		$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/DAS.text = String(das)
		emit_signal("das_changed", das)

func _on_IncreaseDAS_pressed():
	if das < 99:
		das = das + 1
		$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/DAS.text = String(das)
		emit_signal("das_changed", das)

func _on_DecreaseARR_pressed():
	if arr > 1:
		arr = arr - 1
		$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/ARR.text = String(arr)
		emit_signal("arr_changed", arr)

func _on_IncreaseARR_pressed():
	if arr < 9:
		arr = arr + 1
		$VBoxContainer/TabContainer/Tuning/Tuning/VBoxContainer3/ARR.text = String(arr)
		emit_signal("arr_changed", arr)