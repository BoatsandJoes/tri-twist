extends Control
class_name ModeSelect

signal back
signal take_your_time
signal gogogo
signal dig_mode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			_on_Back_pressed()
		elif event.is_action_pressed("ui_up"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = "<"
		elif event.is_action_pressed("ui_down"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text = "<"
		elif event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text == "<":
				_on_TakeYourTime_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text == "<":
				_on_GoGoGo_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text == "<":
				_on_DigMode_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text == "<":
				_on_Back_pressed()

func _on_Back_pressed():
	emit_signal("back")


func _on_TakeYourTime_pressed():
	emit_signal("take_your_time")


func _on_GoGoGo_pressed():
	emit_signal("gogogo")


func _on_DigMode_pressed():
	emit_signal("dig_mode")
