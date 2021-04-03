extends Control
class_name ModeSelect

signal back
signal take_your_time
signal gogogo
signal dig_mode
signal triathalon

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	select_exit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func select_take_your_time():
	$MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text = "<"
	$MarginContainer/HBoxContainer/VBoxContainer4/HowToPlayMode.set_text("If no colors match, all chains end",
	"60 moves to score big!")

func select_gogogo():
	$MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text = "<"
	$MarginContainer/HBoxContainer/VBoxContainer4/HowToPlayMode.set_text("4 seconds to extend chains",
	"2 minutes to score big!")

func select_dig_deep():
	$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = "<"
	$MarginContainer/HBoxContainer/VBoxContainer4/HowToPlayMode.set_text("Clear all pieces above the line for points",
	"2 minutes to score big!")

func select_triathalon():
	$MarginContainer/HBoxContainer/VBoxContainer2/TriathalonArrow.text = "<"
	$MarginContainer/HBoxContainer/VBoxContainer4/HowToPlayMode.set_text("Play all 3 modes back to back!", "")

func select_exit():
	$MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text = "<"
	$MarginContainer/HBoxContainer/VBoxContainer4/HowToPlayMode.set_text("Match colors to clear triangles",
	"Keep matching to make chains!")

func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			_on_Back_pressed()
		elif event.is_action_pressed("ui_up"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text = ""
				select_exit()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text = ""
				select_take_your_time()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = ""
				select_gogogo()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/TriathalonArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/TriathalonArrow.text = ""
				select_dig_deep()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text = ""
				select_triathalon()
		elif event.is_action_pressed("ui_down"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text = ""
				select_gogogo()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text = ""
				select_dig_deep()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = ""
				select_triathalon()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/TriathalonArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/TriathalonArrow.text = ""
				select_exit()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/BackArrow.text = ""
				select_take_your_time()
		elif event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/TakeYourTimeArrow.text == "<":
				_on_TakeYourTime_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/GoGoGoArrow.text == "<":
				_on_GoGoGo_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text == "<":
				_on_DigMode_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/TriathalonArrow.text == "<":
				_on_Triathalon_pressed()
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

func _on_Triathalon_pressed():
	emit_signal("triathalon")
