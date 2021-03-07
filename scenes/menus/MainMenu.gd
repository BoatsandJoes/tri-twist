extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_escape"):
			get_tree().quit()
		elif event.is_action_pressed("ui_up"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text = "<"
		elif event.is_action_pressed("ui_down"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text = "<"
		elif event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text == "<":
				_on_Mode1_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text == "<":
				_on_Mode2_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text == "<":
				_on_Quit_pressed()

func _on_Quit_pressed():
	get_tree().quit()


func _on_Mode1_pressed():
	get_tree().change_scene("scenes/Mode1.tscn")


func _on_Mode2_pressed():
	get_tree().change_scene("scenes/Mode2.tscn")
